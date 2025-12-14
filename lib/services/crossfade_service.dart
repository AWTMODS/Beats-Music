import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage crossfade settings
class CrossfadeService extends ChangeNotifier {
  static const String _enabledKey = 'crossfade_enabled';
  static const String _durationKey = 'crossfade_duration';
  
  bool _isEnabled = false;
  int _durationSeconds = 3; // Default 3 seconds
  
  bool get isEnabled => _isEnabled;
  int get durationSeconds => _durationSeconds;
  Duration get duration => Duration(seconds: _durationSeconds);
  
  CrossfadeService() {
    _loadSettings();
  }
  
  /// Load saved settings from preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_enabledKey) ?? false;
      _durationSeconds = prefs.getInt(_durationKey) ?? 3;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading crossfade settings: $e');
    }
  }
  
  /// Enable or disable crossfade
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, enabled);
    } catch (e) {
      debugPrint('Error saving crossfade enabled state: $e');
    }
  }
  
  /// Set crossfade duration (1-12 seconds)
  Future<void> setDuration(int seconds) async {
    if (seconds < 1 || seconds > 12) {
      debugPrint('Invalid crossfade duration: $seconds. Must be between 1 and 12');
      return;
    }
    
    _durationSeconds = seconds;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_durationKey, seconds);
    } catch (e) {
      debugPrint('Error saving crossfade duration: $e');
    }
  }
  
  /// Toggle crossfade on/off
  Future<void> toggle() async {
    await setEnabled(!_isEnabled);
  }
}
