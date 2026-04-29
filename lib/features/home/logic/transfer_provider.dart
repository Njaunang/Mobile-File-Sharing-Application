import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:local_sharer/features/history/logic/history_provider.dart';
import 'package:local_sharer/features/history/models/transfer_history.dart';
import 'package:local_sharer/services/transfer_service.dart';
import 'package:permission_handler/permission_handler.dart';

enum TransferMode { idle, sending, receiving }

enum TransferStatus { idle, connecting, transferring, success, error }

class TransferProvider extends ChangeNotifier {
  final TransferService _service = TransferService();
  HistoryProvider? _historyProvider;

  TransferMode _mode = TransferMode.idle;
  TransferStatus _status = TransferStatus.idle;
  List<Peer> _discoveredPeers = [];
  TransferProgress? _currentProgress;
  bool _isBroadcasting = false;
  String _qrData = "";
  String _errorMessage = "";
  String _deviceName = "";

  TransferMode get mode => _mode;
  TransferStatus get status => _status;
  List<Peer> get discoveredPeers => _discoveredPeers;
  TransferProgress? get currentProgress => _currentProgress;
  bool get isBroadcasting => _isBroadcasting;
  String get qrData => _qrData;
  String get errorMessage => _errorMessage;

  TransferProvider() {
    _service.peersStream.listen((peers) {
      _discoveredPeers = peers;
      notifyListeners();
    });

    _service.progressStream.listen((progress) {
      _currentProgress = progress;
      _status = TransferStatus.transferring;
      notifyListeners();
    });

    _service.completedStream.listen((completed) {
      _historyProvider?.addEntry(
        TransferHistoryItem(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              completed.path.hashCode.toString(),
          fileName: completed.name,
          filePath: completed.path,
          fileSize: completed.size,
          timestamp: DateTime.now(),
          type: completed.isIncoming ? TransferType.receive : TransferType.send,
          status: HistoryStatus.success,
          peerName: completed.peerName,
        ),
      );
    });
  }

  void updateHistoryProvider(HistoryProvider history) {
    _historyProvider = history;
  }

  Future<String> _getBestDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return "${androidInfo.manufacturer} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      }
    } catch (e) {
      debugPrint("Error getting device info: $e");
    }
    return "Mobile Device";
  }

  Future<void> startDiscovery() async {
    _mode = TransferMode.sending;
    _status = TransferStatus.idle;
    _deviceName = await _getBestDeviceName();
    await _service.startDiscovery();
    notifyListeners();
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.storage,
        Permission.nearbyWifiDevices,
      ].request();

      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }

      return statuses[Permission.storage]!.isGranted;
    }
    return true;
  }

  Future<void> startReceiving(
    String deviceName,
    String user,
    String pass,
  ) async {
    if (!await _requestPermissions()) {
      _status = TransferStatus.error;
      _errorMessage = "Storage permissions are required to receive files.";
      notifyListeners();
      return;
    }

    _deviceName = deviceName;
    _mode = TransferMode.receiving;
    _status = TransferStatus.idle;
    _isBroadcasting = true;
    await _service.startBroadcasting(deviceName, user, pass);

    final ip = await _service.getLocalIPAddress() ?? "0.0.0.0";
    final port = _service.serverPort;
    _qrData = "ls://$ip:$port|$user|$pass";

    notifyListeners();
  }

  Future<void> sendToPeer(
    Peer peer,
    List<File> files,
    String user,
    String pass,
  ) async {
    _status = TransferStatus.connecting;
    _errorMessage = "";
    notifyListeners();

    try {
      final success = await _service.sendFiles(
        peer,
        files,
        user,
        pass,
        _deviceName,
      );
      if (success) {
        _status = TransferStatus.success;
        // The sender logging is handled here, while receiver logging is handled via completedStream
        for (var file in files) {
          _historyProvider?.addEntry(
            TransferHistoryItem(
              id:
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  file.path.hashCode.toString(),
              fileName: file.path.split(Platform.pathSeparator).last,
              filePath: file.path,
              fileSize: await file.length(),
              timestamp: DateTime.now(),
              type: TransferType.send,
              status: HistoryStatus.success,
              peerName: peer.name,
            ),
          );
        }
      } else {
        _status = TransferStatus.error;
        _errorMessage = "Connection failed or authentication denied.";
      }
    } catch (e) {
      _status = TransferStatus.error;
      _errorMessage = e.toString();
    }

    _currentProgress = null;
    notifyListeners();
  }

  Future<void> stop() async {
    await _service.stopAll();
    _mode = TransferMode.idle;
    _status = TransferStatus.idle;
    _isBroadcasting = false;
    _discoveredPeers.clear();
    _currentProgress = null;
    _qrData = "";
    _errorMessage = "";
    notifyListeners();
  }

  @override
  void dispose() {
    _service.stopAll();
    super.dispose();
  }
}
