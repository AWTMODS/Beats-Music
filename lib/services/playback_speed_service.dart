import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage playback speed settings
class PlaybackSpeedService extends ChangeNotifier {
  static const String _speedKey = 'playback_speed';
  static const List<double> speedPresets = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  
  double _currentSpeed = 1.0;
  
  double get currentSpeed => _currentSpeed;
  
  PlaybackSpeedService() {
    _loadSpeed();
  }
  
  /// Load saved speed from preferences
  Future<void> _loadSpeed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentSpeed = prefs.getDouble(_speedKey) ?? 1.0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading playback speed: $e');
    }
  }
  
  /// Set playback speed and save to preferences
  Future<void> setSpeed(double speed) async {
    if (speed < 0.5 || speed > 2.0) {
      debugPrint('Invalid speed: $speed. Must be between 0.5 and 2.0');
      return;
    }
    
    _currentSpeed = speed;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_speedKey, speed);
    } catch (e) {
      debugPrint('Error saving playback speed: $e');
    }
  }
  
  /// Cycle to next speed preset
  Future<void> cycleSpeed() async {
    final currentIndex = speedPresets.indexOf(_currentSpeed);
    final nextIndex = (currentIndex + 1) % speedPresets.length;
    await setSpeed(speedPresets[nextIndex]);
  }
  
  /// Reset to normal speed (1.0x)
  Future<void> resetSpeed() async {
    await setSpeed(1.0);
  }
  
  /// Get formatted speed string (e.g., "1.5x")
  String getSpeedLabel() {
    if (_currentSpeed == 1.0) {
      return '1x';
    }
    return '${_currentSpeed.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}x';
  }
}
