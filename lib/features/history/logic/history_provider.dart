import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_sharer/features/history/models/transfer_history.dart';

class HistoryProvider extends ChangeNotifier {
  static const String _storageKey = 'transfer_history';
  List<TransferHistoryItem> _history = [];
  bool _isLoading = false;

  List<TransferHistoryItem> get history => _history;
  bool get isLoading => _isLoading;

  HistoryProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_storageKey) ?? [];
      _history = historyJson
          .map((item) => TransferHistoryItem.fromJson(item))
          .toList();

      // Sort by newest first
      _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry(TransferHistoryItem item) async {
    _history.insert(0, item);
    notifyListeners();
    await _saveToDisk();
  }

  Future<void> deleteEntry(String id) async {
    _history.removeWhere((item) => item.id == id);
    notifyListeners();
    await _saveToDisk();
  }

  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _history.map((item) => item.toJson()).toList();
      await prefs.setStringList(_storageKey, historyJson);
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }
}
