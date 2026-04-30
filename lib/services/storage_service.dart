import 'package:flutter/foundation.dart';
import 'package:storage_space/storage_space.dart';

class StorageInfo {
  final int totalBytes;
  final int freeBytes;
  final int usedBytes;
  final double usedPercentage;

  StorageInfo({
    required this.totalBytes,
    required this.freeBytes,
    required this.usedBytes,
    required this.usedPercentage,
  });

  String get totalSize => _formatBytes(totalBytes);
  String get freeSize => _formatBytes(freeBytes);
  String get usedSize => _formatBytes(usedBytes);

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    double size = bytes.toDouble();
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < suffixes.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return "${size.toStringAsFixed(1)} ${suffixes[unitIndex]}";
  }
}

class StorageService {
  Future<StorageInfo> getStorageInfo() async {
    try {
      final storage = await getStorageSpace(
        lowOnSpaceThreshold: 2 * 1024 * 1024 * 1024,
        fractionDigits: 1,
      );

      return StorageInfo(
        totalBytes: storage.total,
        freeBytes: storage.free,
        usedBytes: storage.used,
        usedPercentage: storage.usageValue / 100,
      );
    } catch (e) {
      debugPrint("[StorageService] Error: $e");
      // Fallback for non-Android or errors
      return StorageInfo(
        totalBytes: 128 * 1024 * 1024 * 1024, // 128 GB fallback
        freeBytes: 20 * 1024 * 1024 * 1024,
        usedBytes: 108 * 1024 * 1024 * 1024,
        usedPercentage: 0.85,
      );
    }
  }
}
