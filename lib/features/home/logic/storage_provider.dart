import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_sharer/services/storage_service.dart';

class StorageProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  StorageInfo? _storageInfo;

  // Getters

  StorageInfo? get storageInfo => _storageInfo;

  StorageProvider() {
    // Listen to logs from the service

    refreshStorageInfo();
  }

  Future<void> refreshStorageInfo() async {
    _storageInfo = await _storageService.getStorageInfo();
    notifyListeners();
  }
}
