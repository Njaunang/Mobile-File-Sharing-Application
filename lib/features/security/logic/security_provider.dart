import 'package:flutter/material.dart';
import 'package:local_sharer/services/security_service.dart';

class SecurityProvider extends ChangeNotifier with WidgetsBindingObserver {
  final SecurityService _service = SecurityService();

  bool _isLocked = false;
  bool _isAppLockEnabled = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  bool _hasPINSet = false;
  bool _isLoading = true;

  // Getters
  bool get isLocked => _isLocked;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get hasPINSet => _hasPINSet;
  bool get isLoading => _isLoading;

  SecurityProvider() {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    _isAppLockEnabled = await _service.isAppLockEnabled();
    _isBiometricEnabled = await _service.isBiometricEnabled();
    _isBiometricAvailable = await _service.isBiometricAvailable();
    _hasPINSet = await _service.hasPIN();

    if (_isAppLockEnabled) {
      _isLocked = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_isAppLockEnabled) {
        _isLocked = true;
        notifyListeners();
      }
    }
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    _isAppLockEnabled = enabled;
    await _service.setAppLockEnabled(enabled);
    if (!enabled) {
      _isLocked = false;
    }
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _isBiometricEnabled = enabled;
    await _service.setBiometricEnabled(enabled);
    notifyListeners();
  }

  Future<void> setPIN(String pin) async {
    await _service.savePIN(pin);
    _hasPINSet = true;
    notifyListeners();
  }

  Future<bool> authenticateWithPIN(String pin) async {
    final success = await _service.verifyPIN(pin);
    if (success) {
      _isLocked = false;
      notifyListeners();
    }
    return success;
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!_isBiometricAvailable || !_isBiometricEnabled) return false;
    
    final success = await _service.authenticateWithBiometrics();
    if (success) {
      _isLocked = false;
      notifyListeners();
    }
    return success;
  }

  void lockApp() {
    if (_isAppLockEnabled) {
      _isLocked = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
