import 'dart:convert';

enum TransferType { send, receive, web }
enum HistoryStatus { success, failed, cancelled }

class TransferHistoryItem {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final DateTime timestamp;
  final TransferType type;
  final HistoryStatus status;
  final String peerName;

  TransferHistoryItem({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.timestamp,
    required this.type,
    required this.status,
    required this.peerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'timestamp': timestamp.toIso8601String(),
      'type': type.index,
      'status': status.index,
      'peerName': peerName,
    };
  }

  factory TransferHistoryItem.fromMap(Map<String, dynamic> map) {
    return TransferHistoryItem(
      id: map['id'] ?? '',
      fileName: map['fileName'] ?? '',
      filePath: map['filePath'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      timestamp: DateTime.parse(map['timestamp']),
      type: TransferType.values[map['type'] ?? 0],
      status: HistoryStatus.values[map['status'] ?? 0],
      peerName: map['peerName'] ?? 'Unknown',
    );
  }

  String toJson() => json.encode(toMap());

  factory TransferHistoryItem.fromJson(String source) =>
      TransferHistoryItem.fromMap(json.decode(source));
}
