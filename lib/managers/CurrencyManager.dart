import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Singleton class to manage the in-game currency (Beans)
class CurrencyManager {
  static final CurrencyManager _instance = CurrencyManager._internal();
  factory CurrencyManager() => _instance;
  CurrencyManager._internal();

  static const String _balanceKey = 'bean_balance';
  int _balance = 0;

  final StreamController<int> _balanceController = StreamController<int>.broadcast();
  Stream<int> get balanceStream => _balanceController.stream;

  int get balance => _balance;

  /// Initialize and load saved balance
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getInt(_balanceKey) ?? 0;
    _balanceController.add(_balance);
  }

  /// Add beans to the balance
  Future<void> addBeans(int amount) async {
    _balance += amount;
    await _saveBalance();
    _balanceController.add(_balance);
  }

  /// Spend beans (returns true if successful)
  Future<bool> spendBeans(int amount) async {
    if (_balance >= amount) {
      _balance -= amount;
      await _saveBalance();
      _balanceController.add(_balance);
      return true;
    }
    return false;
  }

  /// Save balance to persistent storage
  Future<void> _saveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_balanceKey, _balance);
  }

  void dispose() {
    _balanceController.close();
  }
}
