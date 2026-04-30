import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nsd/nsd.dart' as nsd_plugin;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class Peer {
  final String name;
  final String ip;
  final int port;

  Peer({required this.name, required this.ip, required this.port});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Peer &&
          runtimeType == other.runtimeType &&
          ip == other.ip &&
          port == other.port;

  @override
  int get hashCode => ip.hashCode ^ port.hashCode;
}

class TransferProgress {
  final String fileName;
  final double progress;
  final int totalBytes;
  final int transferredBytes;
  final bool isUploading;

  TransferProgress({
    required this.fileName,
    required this.progress,
    required this.totalBytes,
    required this.transferredBytes,
    this.isUploading = true,
  });
}

class CompletedFile {
  final String name;
  final String path;
  final int size;
  final bool isIncoming;
  final String peerName;

  CompletedFile({
    required this.name,
    required this.path,
    required this.size,
    required this.isIncoming,
    required this.peerName,
  });
}

class TransferService {
  nsd_plugin.Registration? _registration;
  nsd_plugin.Discovery? _discovery;
  ServerSocket? _serverSocket;

  final _peerController = StreamController<List<Peer>>.broadcast();
  Stream<List<Peer>> get peersStream => _peerController.stream;

  final _progressController = StreamController<TransferProgress>.broadcast();
  Stream<TransferProgress> get progressStream => _progressController.stream;

  final _completedController = StreamController<CompletedFile>.broadcast();
  Stream<CompletedFile> get completedStream => _completedController.stream;

  final Set<Peer> _discoveredPeers = {};
  final String _serviceType = '_localsharer._tcp';

  int get serverPort => _serverSocket?.port ?? 0;

  Future<String?> getLocalIPAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );

      for (var interface in interfaces) {
        if (interface.name.contains('wlan') || interface.name.contains('ap')) {
          for (var addr in interface.addresses) {
            if (!addr.isLoopback) return addr.address;
          }
        }
      }

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return null;
  }

  String? _serverUsername;
  String? _serverPassword;

  Future<void> startBroadcasting(
    String deviceName,
    String username,
    String password,
  ) async {
    _serverUsername = username;
    _serverPassword = password;

    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 42360);
    _serverSocket!.listen(_handleIncomingConnection);

    _registration = await nsd_plugin.register(
      nsd_plugin.Service(name: deviceName, type: _serviceType, port: 42360),
    );
    _log("Broadcasting as $deviceName on port 42360");
  }

  Future<void> startDiscovery() async {
    _discoveredPeers.clear();
    _peerController.add(_discoveredPeers.toList());

    _discovery = await nsd_plugin.startDiscovery(_serviceType);
    _discovery!.addServiceListener((service, status) {
      if (status == nsd_plugin.ServiceStatus.found) {
        final ip = service.addresses?.isNotEmpty == true
            ? service.addresses!.first.address
            : null;
        final port = service.port;
        if (ip != null && port != null) {
          final peer = Peer(
            name: service.name ?? "Unknown",
            ip: ip,
            port: port,
          );
          if (_discoveredPeers.add(peer)) {
            _peerController.add(_discoveredPeers.toList());
          }
        }
      }
    });
  }

  Future<void> stopAll() async {
    try {
      if (_registration != null) {
        final reg = _registration!;
        _registration = null;
        await nsd_plugin.unregister(reg);
      }
    } catch (e) {
      _log("Error unregistering: $e");
    }

    try {
      if (_discovery != null) {
        final disc = _discovery!;
        _discovery = null;
        await nsd_plugin.stopDiscovery(disc);
      }
    } catch (e) {
      _log("Error stopping discovery: $e");
    }

    try {
      await _serverSocket?.close();
      _serverSocket = null;
    } catch (_) {}

    _discoveredPeers.clear();
    _peerController.add([]);
  }

  // --- SENDER LOGIC ---

  Future<bool> sendFiles(
    Peer peer,
    List<File> files,
    String username,
    String password,
    String deviceName,
  ) async {
    Socket? socket;
    try {
      _log("Connecting to ${peer.name} at ${peer.ip}:${peer.port}...");
      socket = await Socket.connect(
        peer.ip,
        peer.port,
        timeout: const Duration(seconds: 15),
      );
      _log("Connected successfully.");

      final reader = _SocketReader(StreamIterator(socket));

      // 1. Auth Handshake
      _log("Sending authentication...");
      socket.write(
        "${jsonEncode({"type": "auth", "username": username, "password": password, "deviceName": deviceName})}\n",
      );

      // 2. Wait for Auth Response
      final responseStr = await reader.readLine();
      if (responseStr == null || responseStr.isEmpty) {
        throw Exception("Authentication timeout or empty response.");
      }

      final response = jsonDecode(responseStr);
      if (response["status"] != "success") {
        _log("Authentication failed: ${response["message"]}");
        return false;
      }

      _log("Auth successful, preparing to send ${files.length} files.");

      // 3. Send Files
      for (var file in files) {
        if (!await file.exists()) {
          _log("File not found: ${file.path}");
          continue;
        }

        final name = p.basename(file.path);
        final size = await file.length();
        _log("Sending metadata for $name ($size bytes)...");

        // Send Metadata
        socket.write(
          "${jsonEncode({"type": "file_meta", "name": name, "size": size})}\n",
        );

        // Wait for READY
        final readySignal = await reader.readLine();
        if (readySignal == null || !readySignal.contains("READY")) {
          throw Exception("Receiver did not send READY signal.");
        }
        _log("Receiver is READY, streaming bytes...");

        // Stream Bytes
        int sent = 0;
        final stream = file.openRead();
        await for (var chunk in stream) {
          socket.add(chunk);
          sent += chunk.length;
          _progressController.add(
            TransferProgress(
              fileName: name,
              progress: sent / size,
              totalBytes: size,
              transferredBytes: sent,
              isUploading: true,
            ),
          );
        }

        _log("File $name sent successfully.");
        await socket.flush();
        // A short delay to ensure receiver processes the current file completely
        await Future.delayed(const Duration(milliseconds: 200));
      }

      _log("All transfers complete.");
      await reader.close();
      return true;
    } catch (e) {
      _log("Send error: $e");
      rethrow; // Throw to show in UI
    } finally {
      await socket?.close();
    }
  }

  // --- RECEIVER LOGIC ---

  void _handleIncomingConnection(Socket socket) async {
    _log("Incoming connection from ${socket.remoteAddress.address}");
    final reader = _SocketReader(StreamIterator(socket));

    try {
      // 1. Authenticate
      final authStr = await reader.readLine();
      if (authStr == null || authStr.isEmpty) {
        _log("No auth received, closing.");
        return;
      }

      final authData = jsonDecode(authStr);
      if (authData["username"] != _serverUsername ||
          authData["password"] != _serverPassword) {
        _log("Invalid credentials from client.");
        socket.write(
          "${jsonEncode({"type": "auth_response", "status": "fail", "message": "Invalid credentials"})}\n",
        );
        await socket.flush();
        return;
      }

      socket.write(
        "${jsonEncode({"type": "auth_response", "status": "success"})}\n",
      );
      await socket.flush();
      _log("Client authenticated.");

      final String peerName = authData["deviceName"] ?? "Remote Device";

      // 2. Receive Files
      final downloadDir = await _getDownloadDirectory();

      while (true) {
        _log("Waiting for next file metadata...");
        final metaStr = await reader.readLine();
        if (metaStr == null || metaStr.isEmpty) {
          _log("Connection closed by sender or timeout.");
          break;
        }

        final meta = jsonDecode(metaStr);
        final name = meta["name"];
        final size = meta["size"];
        _log("Receiving $name ($size bytes)...");

        final file = File(p.join(downloadDir, name));
        final sink = file.openWrite();

        socket.write("READY\n");
        await socket.flush();

        await reader.readToSink(sink, size, (received) {
          _progressController.add(
            TransferProgress(
              fileName: name,
              progress: received / size,
              totalBytes: size,
              transferredBytes: received,
              isUploading: false,
            ),
          );
        });

        await sink.close();
        _log("File $name received and saved.");

        // Notify completion
        _completedController.add(
          CompletedFile(
            name: name,
            path: file.path,
            size: size,
            isIncoming: true,
            peerName: peerName,
          ),
        );
      }
    } catch (e) {
      _log("Receiver error: $e");
    } finally {
      await reader.close();
      await socket.close();
    }
  }

  Future<String> _getDownloadDirectory() async {
    Directory? dir;
    if (Platform.isAndroid) {
      const String phoneStorageRoot = "/storage/emulated/0";
      dir = Directory("$phoneStorageRoot/Download/LocalSharer");
    } else {
      dir = await getDownloadsDirectory();
    }
    if (dir != null && !await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir?.path ?? (await getTemporaryDirectory()).path;
  }

  void _log(String msg) => debugPrint("[TransferService] $msg");
}

/// Helper class to read from a single-subscription Socket stream sequentially
class _SocketReader {
  final StreamIterator<Uint8List> _it;
  List<int> _buffer = [];

  _SocketReader(this._it);

  /// Reads a line terminated by \n
  Future<String?> readLine() async {
    try {
      while (true) {
        int newlineIndex = _buffer.indexOf(10); // \n
        if (newlineIndex != -1) {
          final line = utf8.decode(_buffer.sublist(0, newlineIndex)).trim();
          _buffer = _buffer.sublist(newlineIndex + 1);
          return line;
        }

        if (await _it.moveNext().timeout(const Duration(seconds: 20))) {
          _buffer.addAll(_it.current);
        } else {
          if (_buffer.isNotEmpty) {
            final line = utf8.decode(_buffer).trim();
            _buffer = [];
            return line;
          }
          return null;
        }
      }
    } catch (e) {
      debugPrint("[_SocketReader] Read error: $e");
      return null;
    }
  }

  /// Reads exactly [size] bytes and writes them to [sink]
  Future<void> readToSink(
    IOSink sink,
    int size,
    Function(int received) onProgress,
  ) async {
    int received = 0;

    // 1. Consume from buffer first
    if (_buffer.isNotEmpty) {
      int toWrite = _buffer.length;
      if (toWrite > size - received) toWrite = size - received;

      sink.add(_buffer.sublist(0, toWrite));
      received += toWrite;
      _buffer = _buffer.sublist(toWrite);
      onProgress(received);
    }

    // 2. Read from stream iterator
    while (received < size) {
      if (await _it.moveNext().timeout(const Duration(seconds: 30))) {
        final chunk = _it.current;
        int toWrite = chunk.length;
        if (toWrite > size - received) toWrite = size - received;

        sink.add(chunk.sublist(0, toWrite));

        if (toWrite < chunk.length) {
          // Keep leftover for next read (e.g. next file metadata)
          _buffer.addAll(chunk.sublist(toWrite));
        }

        received += toWrite;
        onProgress(received);
      } else {
        throw Exception("Connection closed before receiving full file");
      }
    }
  }

  Future<void> close() async {
    await _it.cancel();
  }
}
