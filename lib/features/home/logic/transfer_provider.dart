import 'dart:io';
import 'package:flutter/material.dart';
import 'package:local_sharer/services/transfer_service.dart';
import 'package:permission_handler/permission_handler.dart';

enum TransferMode { idle, sending, receiving }
enum TransferStatus { idle, connecting, transferring, success, error }

class TransferProvider extends ChangeNotifier {
  final TransferService _service = TransferService();
  
  TransferMode _mode = TransferMode.idle;
  TransferStatus _status = TransferStatus.idle;
  List<Peer> _discoveredPeers = [];
  TransferProgress? _currentProgress;
  bool _isBroadcasting = false;
  String _qrData = "";
  String _errorMessage = "";

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
  }

  Future<void> startDiscovery() async {
    _mode = TransferMode.sending;
    _status = TransferStatus.idle;
    await _service.startDiscovery();
    notifyListeners();
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.storage,
        Permission.nearbyWifiDevices,
      ].request();
      
      // On Android 11+, we might need MANAGE_EXTERNAL_STORAGE for some directories
      // but Downloads should be okay with standard permissions or scoped storage.
      // However, for maximum compatibility with the current path:
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      
      return statuses[Permission.storage]!.isGranted;
    }
    return true;
  }

  Future<void> startReceiving(String deviceName, String user, String pass) async {
    if (!await _requestPermissions()) {
      _status = TransferStatus.error;
      _errorMessage = "Storage permissions are required to receive files.";
      notifyListeners();
      return;
    }

    _mode = TransferMode.receiving;
    _status = TransferStatus.idle;
    _isBroadcasting = true;
    await _service.startBroadcasting(deviceName, user, pass);
    
    final ip = await _service.getLocalIPAddress() ?? "0.0.0.0";
    final port = _service.serverPort;
    _qrData = "ls://$ip:$port|$user|$pass";
    
    notifyListeners();
  }

  Future<void> sendToPeer(Peer peer, List<File> files, String user, String pass) async {
    _status = TransferStatus.connecting;
    _errorMessage = "";
    notifyListeners();

    try {
      final success = await _service.sendFiles(peer, files, user, pass);
      if (success) {
        _status = TransferStatus.success;
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
