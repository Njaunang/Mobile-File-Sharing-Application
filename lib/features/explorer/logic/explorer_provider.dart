import 'dart:io';
import 'package:flutter/material.dart';
import 'package:local_sharer/features/explorer/models/file_item.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ExplorerProvider extends ChangeNotifier {
  static const String internalStorageRoot = "/storage/emulated/0";
  
  List<FileItem> _files = [];
  final List<FileItem> _selectedFiles = [];
  String _currentPath = "";
  FileType? _currentCategory;
  bool _isLoading = false;

  List<FileItem> get files => _files;
  List<FileItem> get selectedFiles => _selectedFiles;
  String get currentPath => _currentPath;
  FileType? get currentCategory => _currentCategory;
  bool get isLoading => _isLoading;

  Future<void> initialize({FileType? initialCategory}) async {
    _selectedFiles.clear(); 
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        _currentPath = internalStorageRoot;
      } else {
        final docDir = await getApplicationDocumentsDirectory();
        _currentPath = docDir.path;
      }
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      _currentPath = docDir.path;
    }

    if (initialCategory != null) {
      if (initialCategory == FileType.folder) {
        await scanDirectory(_currentPath);
      } else {
        setCategory(initialCategory);
      }
    } else {
      _currentCategory = null;
      _files = [];
      notifyListeners();
    }
  }

  void setCategory(FileType? category) {
    _currentCategory = category;
    if (category != null) {
      scanCategory(category);
    } else {
      _files = [];
      notifyListeners();
    }
  }

  Future<void> scanCategory(FileType type) async {
    _isLoading = true;
    _files = [];
    notifyListeners();

    try {
      final root = Directory(internalStorageRoot);
      if (!await root.exists()) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // We use a list to collect files. Recursive scanning can be slow.
      // Optimization: Only scan common folders for specific types.
      List<String> searchPaths = [internalStorageRoot];
      
      switch (type) {
        case FileType.image:
          searchPaths = [
            "$internalStorageRoot/DCIM",
            "$internalStorageRoot/Pictures",
            "$internalStorageRoot/Download"
          ];
          break;
        case FileType.video:
          searchPaths = [
            "$internalStorageRoot/DCIM",
            "$internalStorageRoot/Movies",
            "$internalStorageRoot/Download",
            "$internalStorageRoot/WhatsApp/Media/WhatsApp Video"
          ];
          break;
        case FileType.audio:
          searchPaths = [
            "$internalStorageRoot/Music",
            "$internalStorageRoot/Download",
            "$internalStorageRoot/Notifications",
            "$internalStorageRoot/Ringtones"
          ];
          break;
        case FileType.document:
          searchPaths = [
            "$internalStorageRoot/Documents",
            "$internalStorageRoot/Download"
          ];
          break;
        case FileType.apk:
          searchPaths = [
            "$internalStorageRoot/Download",
            "$internalStorageRoot/Bluetooth"
          ];
          break;
        default:
          break;
      }

      List<FileItem> foundFiles = [];
      
      for (var path in searchPaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          await for (final entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              final item = FileItem.fromFileSystemEntity(entity);
              if (item.type == type) {
                // Restore selection state if already selected
                if (_selectedFiles.any((s) => s.path == item.path)) {
                  item.isSelected = true;
                }
                foundFiles.add(item);
              }
            }
          }
        }
      }

      _files = foundFiles;
      _files.sort((a, b) => b.modified.compareTo(a.modified)); // Newest first
    } catch (e) {
      debugPrint("Error scanning category: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> scanDirectory(String path) async {
    _isLoading = true;
    _currentPath = path;
    _currentCategory = FileType.folder; // Special marker for "File Browser" mode
    _files.clear();
    notifyListeners();

    try {
      final dir = Directory(path);
      final List<FileSystemEntity> entities = await dir.list().toList();
      
      _files = entities.map((e) => FileItem.fromFileSystemEntity(e)).toList();
      
      // Update selection state from _selectedFiles
      for (var file in _files) {
        if (_selectedFiles.any((s) => s.path == file.path)) {
          file.isSelected = true;
        }
      }
      
      // Sort: Folders first, then files by name
      _files.sort((a, b) {
        if (a.type == FileType.folder && b.type != FileType.folder) return -1;
        if (a.type != FileType.folder && b.type == FileType.folder) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    } catch (e) {
      debugPrint("Error scanning directory: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSelection(FileItem item) {
    item.isSelected = !item.isSelected;
    if (item.isSelected) {
      _selectedFiles.add(item);
    } else {
      _selectedFiles.removeWhere((element) => element.path == item.path);
    }
    notifyListeners();
  }

  void clearSelection() {
    for (var file in _files) {
      file.isSelected = false;
    }
    _selectedFiles.clear();
    notifyListeners();
  }

  void navigateBack() {
    if (_currentPath == internalStorageRoot || _currentPath == "/") return;
    final parentPath = p.dirname(_currentPath);
    scanDirectory(parentPath);
  }
}
