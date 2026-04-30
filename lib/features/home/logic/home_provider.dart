import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_sharer/services/ftp_service.dart';
import 'package:local_sharer/services/storage_service.dart';

class HomeProvider extends ChangeNotifier {
  final FtpService _ftpService = FtpService();
  final StorageService _storageService = StorageService();
  
  bool _isLoading = false;
  final List<LogEntry> _logs = [];
  StreamSubscription<LogEntry>? _logSubscription;
  StorageInfo? _storageInfo;

  // Getters
  bool get isRunning => _ftpService.isRunning;
  bool get isLoading => _isLoading;
  List<LogEntry> get logs => _logs;
  String get serverAddress => _ftpService.serverAddress;
  String get username => _ftpService.username;
  String get password => _ftpService.password;
  StorageInfo? get storageInfo => _storageInfo;

  HomeProvider() {
    // Listen to logs from the service
    _logSubscription = _ftpService.logStream.listen((entry) {
      _logs.add(entry);
      if (_logs.length > 100) _logs.removeAt(0);
      notifyListeners();
    });
    refreshStorageInfo();
  }

  Future<void> refreshStorageInfo() async {
    _storageInfo = await _storageService.getStorageInfo();
    notifyListeners();
  }

  Future<void> toggleServer() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isRunning) {
        await _ftpService.stopServer();
      } else {
        bool success = await _ftpService.startServer();
        if (!success) {
          // Handle failure (e.g., set error message)
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _ftpService.dispose();
    super.dispose();
  }
}
