import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:local_sharer/services/web_service.dart';

class WebProvider extends ChangeNotifier {
  final WebService _webService = WebService();
  final List<File> _basketFiles = [];
  bool _isLoading = false;
  String _pin = '';

  // Getters
  bool get isRunning => _webService.isRunning;
  bool get isLoading => _isLoading;
  List<File> get basketFiles => _basketFiles;
  String get serverAddress => _webService.address;
  String get pin => _pin;

  void addFile(File file) {
    if (!_basketFiles.any((f) => f.path == file.path)) {
      _basketFiles.add(file);
      if (isRunning) {
        _webService.updateSharedFiles(_basketFiles);
      }
      notifyListeners();
    }
  }

  void removeFile(File file) {
    _basketFiles.removeWhere((f) => f.path == file.path);
    if (isRunning) {
      _webService.updateSharedFiles(_basketFiles);
    }
    notifyListeners();
  }

  void clearBasket() {
    _basketFiles.clear();
    if (isRunning) {
      _webService.updateSharedFiles(_basketFiles);
    }
    notifyListeners();
  }

  Future<void> toggleServer() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isRunning) {
        await _webService.stopServer();
      } else {
        final ip = await _getLocalIPAddress();
        if (ip != null) {
          _pin = _generatePin();
          _webService.updateSharedFiles(_basketFiles);
          await _webService.startServer(ip, pin: _pin);
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generatePin() {
    return (Random().nextInt(9000) + 1000).toString();
  }

  Future<String?> _getLocalIPAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );

      for (var interface in interfaces) {
        // Prefer Wi-Fi interfaces
        if (interface.name.contains('wlan') || interface.name.contains('ap')) {
          for (var addr in interface.addresses) {
            if (!addr.isLoopback) return addr.address;
          }
        }
      }

      // Fallback to any non-loopback
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _webService.stopServer();
    super.dispose();
  }
}
