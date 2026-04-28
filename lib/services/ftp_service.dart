import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LogEntry {
  final String message;
  final bool isError;
  final DateTime timestamp;

  LogEntry(this.message, {this.isError = false}) : timestamp = DateTime.now();
}

class FtpService {
  ServerSocket? _serverSocket;
  bool _isRunning = false;
  String _serverAddress = '';
  final String _username = 'android';
  final String _password = 'android';
  String _rootDir = '';

  // Data connection management
  Socket? _dataSocket;
  ServerSocket? _passiveServer;

  // Stream for logging to UI
  final _logController = StreamController<LogEntry>.broadcast();
  Stream<LogEntry> get logStream => _logController.stream;

  bool get isRunning => _isRunning;
  String get serverAddress => _serverAddress;
  String get username => _username;
  String get password => _password;

  void _log(String message, {bool isError = false}) {
    final entry = LogEntry(message, isError: isError);
    _logController.add(entry);
    developer.log(message);
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      var status = await Permission.storage.request();
      return status.isGranted || await Permission.manageExternalStorage.isGranted;
    }
    return true;
  }

  Future<String?> getLocalIPAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      _log('Error getting local IP: $e', isError: true);
    }
    return null;
  }

  Future<String> getRootDirectory() async {
    if (Platform.isAndroid) {
      try {
        const String phoneStorageRoot = "/storage/emulated/0";
        Directory internalStorage = Directory(phoneStorageRoot);
        if (await internalStorage.exists()) return internalStorage.path;
      } catch (_) {}
    }
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir != null) return externalDir.path;
    
    Directory appDir = await getApplicationDocumentsDirectory();
    return appDir.path;
  }

  Future<bool> startServer() async {
    if (_isRunning) return true;

    try {
      bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        _log("Storage permission not granted", isError: true);
        return false;
      }

      String? ip = await getLocalIPAddress();
      if (ip == null) {
        _log("Could not get local IP address", isError: true);
        return false;
      }

      _rootDir = await getRootDirectory();
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 2121);
      _isRunning = true;
      _serverAddress = '$ip:2121';

      _log("FTP Server started at $_serverAddress");
      _serverSocket!.listen(_handleClient);

      return true;
    } catch (e) {
      _log("Error starting FTP server: $e", isError: true);
      return false;
    }
  }

  void _handleClient(Socket client) {
    _log("Client connected: ${client.remoteAddress.address}");
    client.write('220 Local Sharer FTP Server ready\r\n');
    
    bool authenticated = false;
    String? expectedPassword;

    client.listen(
      (List<int> data) {
        String commandStr = utf8.decode(data).trim();
        if (commandStr.isEmpty) return;

        // Take only the first command if multiple are received
        String command = commandStr.split('\r\n')[0];
        List<String> parts = command.split(' ');
        String cmd = parts[0].toUpperCase();
        String args = parts.length > 1 ? parts.sublist(1).join(' ') : '';

        switch (cmd) {
          case 'USER':
            if (args.toLowerCase() == "anonymous" || args == _username) {
              expectedPassword = _password;
              client.write("331 Password required for $args\r\n");
            } else {
              client.write("530 Invalid username\r\n");
            }
            break;

          case "PASS":
            if (expectedPassword != null && args == expectedPassword) {
              authenticated = true;
              client.write("230 Login successful\r\n");
              _log("User authenticated");
            } else {
              client.write("530 Authentication failed\r\n");
            }
            expectedPassword = null;
            break;

          case "PWD":
            if (!authenticated) {
              client.write("530 Not logged in\r\n");
              return;
            }
            client.write('257 "/" is current directory\r\n');
            break;

          case "LIST":
          case "NLST":
            if (!authenticated) {
              client.write('530 Not logged in\r\n');
              return;
            }
            _sendDirectoryListing(client);
            break;

          case 'RETR':
            if (!authenticated) {
              client.write('530 Not logged in\r\n');
              return;
            }
            _sendFile(client, args);
            break;

          case 'STOR':
            if (!authenticated) {
              client.write('530 Not logged in\r\n');
              return;
            }
            _receiveFile(client, args);
            break;

          case 'TYPE':
            client.write('200 Type set to I\r\n');
            break;

          case 'PASV':
            if (!authenticated) {
              client.write('530 Not logged in\r\n');
              return;
            }
            _handlePassiveMode(client);
            break;

          case 'SYST':
            client.write('215 UNIX Type: L8\r\n');
            break;

          case 'FEAT':
            client.write('211-Features:\r\n MDTM\r\n SIZE\r\n211 END\r\n');
            break;

          case 'QUIT':
            client.write('221 Goodbye\r\n');
            client.close();
            break;

          default:
            client.write('200 Command $cmd okay\r\n');
            break;
        }
      },
      onDone: () => client.close(),
      onError: (e) => _log("Client error: $e", isError: true),
    );
  }

  Completer<Socket>? _dataCompleter;

  void _handlePassiveMode(Socket client) async {
    try {
      await _passiveServer?.close();
      _passiveServer = await ServerSocket.bind(InternetAddress.anyIPv4, 2122);
      _dataCompleter = Completer<Socket>();

      String serverIP = "127.0.0.1";
      List<String> ipParts = serverIP.split('.');
      
      int portHigh = 2122 ~/ 256;
      int portLow = 2122 % 256;

      client.write('227 Entering Passive Mode (${ipParts.join(',')},$portHigh,$portLow)\r\n');

      _passiveServer!.first.then((Socket dataSocket) {
        _dataSocket = dataSocket;
        if (_dataCompleter != null && !_dataCompleter!.isCompleted) {
          _dataCompleter!.complete(dataSocket);
        }
        _log("Data connection established on port 2122");
      }).catchError((e) {
        _log("Passive data connection error: $e", isError: true);
      });
    } catch (e) {
      _log("Error in PASV: $e", isError: true);
      client.write('500 Passive mode error\r\n');
    }
  }

  Future<bool> _waitForDataConnection(Socket client) async {
    if (_dataSocket != null) return true;
    if (_dataCompleter == null) return false;

    try {
      _log("Waiting for data connection...");
      await _dataCompleter!.future.timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      _log("Data connection timeout", isError: true);
      client.write('425 No data connection established in time\r\n');
      return false;
    }
  }

  void _sendDirectoryListing(Socket client) async {
    if (!await _waitForDataConnection(client)) return;

    client.write('150 Opening data connection\r\n');
    try {
      Directory dir = Directory(_rootDir);
      // Check if directory exists and is accessible
      if (!await dir.exists()) {
        _log("Root directory does not exist: $_rootDir", isError: true);
        client.write('550 Directory not found\r\n');
        return;
      }

      var entities = await dir.list().toList();
      
      for (var entity in entities) {
        String name = path.basename(entity.path);
        String type = entity is Directory ? 'drwxr-xr-x' : '-rw-r--r--';
        int size = 0;
        try {
          size = entity is File ? await entity.length() : 4096;
        } catch (_) {}
        _dataSocket!.write('$type 1 owner group $size Jan 1 2026 $name\r\n');
      }
      
      await _dataSocket!.flush();
      await _dataSocket!.close();
      _dataSocket = null;
      _dataCompleter = null;
      client.write('226 Transfer complete\r\n');
    } catch (e) {
      _log("Listing failed: $e", isError: true);
      client.write('550 Listing failed\r\n');
    }
  }

  void _sendFile(Socket client, String filename) async {
    if (!await _waitForDataConnection(client)) return;

    File file = File(path.join(_rootDir, filename));
    if (!await file.exists()) {
      client.write('550 File not found\r\n');
      return;
    }

    client.write('150 Opening data connection for $filename\r\n');
    try {
      await _dataSocket!.addStream(file.openRead());
      await _dataSocket!.close();
      _dataSocket = null;
      _dataCompleter = null;
      client.write('226 Transfer complete\r\n');
    } catch (e) {
      client.write('550 Transfer failed\r\n');
    }
  }

  void _receiveFile(Socket client, String filename) async {
    if (!await _waitForDataConnection(client)) return;

    client.write('150 Opening data connection for upload\r\n');
    try {
      File file = File(path.join(_rootDir, filename));
      IOSink sink = file.openWrite();
      await sink.addStream(_dataSocket!);
      await sink.close();
      await _dataSocket!.close();
      _dataSocket = null;
      _dataCompleter = null;
      client.write('226 Transfer complete\r\n');
      _log("File received: $filename");
    } catch (e) {
      _log("Upload failed: $e", isError: true);
      client.write('550 Upload failed\r\n');
    }
  }

  Future<void> stopServer() async {
    await _serverSocket?.close();
    await _passiveServer?.close();
    await _dataSocket?.close();
    _isRunning = false;
    _log("Server stopped");
  }

  void dispose() {
    stopServer();
    _logController.close();
  }
}
