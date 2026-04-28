import 'dart:io';
import 'package:path/path.dart' as p;

enum FileType {
  image,
  video,
  audio,
  document,
  apk,
  other,
  folder,
}

class FileItem {
  final String name;
  final String path;
  final int size;
  final DateTime modified;
  final FileType type;
  bool isSelected;

  FileItem({
    required this.name,
    required this.path,
    required this.size,
    required this.modified,
    required this.type,
    this.isSelected = false,
  });

  factory FileItem.fromFileSystemEntity(FileSystemEntity entity) {
    final name = p.basename(entity.path);
    final stat = entity.statSync();
    
    if (entity is Directory) {
      return FileItem(
        name: name,
        path: entity.path,
        size: 0,
        modified: stat.modified,
        type: FileType.folder,
      );
    } else {
      final ext = p.extension(entity.path).toLowerCase();
      return FileItem(
        name: name,
        path: entity.path,
        size: stat.size,
        modified: stat.modified,
        type: _getFileType(ext),
      );
    }
  }

  static FileType _getFileType(String ext) {
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'].contains(ext)) {
      return FileType.image;
    } else if (['.mp4', '.mkv', '.mov', '.avi', '.wmv', '.flv'].contains(ext)) {
      return FileType.video;
    } else if (['.mp3', '.wav', '.m4a', '.flac', '.ogg'].contains(ext)) {
      return FileType.audio;
    } else if (['.pdf', '.doc', '.docx', '.txt', '.xls', '.xlsx', '.ppt', '.pptx'].contains(ext)) {
      return FileType.document;
    } else if (ext == '.apk') {
      return FileType.apk;
    } else {
      return FileType.other;
    }
  }
}
