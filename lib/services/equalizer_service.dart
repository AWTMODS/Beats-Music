import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Equalizer preset definitions
class EqualizerPreset {
  final String name;
  final List<double> gains; // 5 bands: 60Hz, 230Hz, 910Hz, 3.6kHz, 14kHz
  
  const EqualizerPreset(this.name, this.gains);
  
  static const List<EqualizerPreset> presets = [
    EqualizerPreset('Flat', [0.0, 0.0, 0.0, 0.0, 0.0]),
    EqualizerPreset('Rock', [5.0, 3.0, -1.0, 0.5, 3.0]),
    EqualizerPreset('Pop', [1.0, 3.0, 4.0, 3.0, 1.0]),
    EqualizerPreset('Jazz', [4.0, 2.0, 1.0, 2.0, 4.0]),
    EqualizerPreset('Classical', [4.0, 3.0, -2.0, 2.0, 3.0]),
    EqualizerPreset('Hip-Hop', [5.0, 3.0, 0.0, 1.0, 3.0]),
    EqualizerPreset('Electronic', [4.0, 3.0, 1.0, 0.0, 4.0]),
    EqualizerPreset('Bass Boost', [6.0, 4.0, 0.0, 0.0, 0.0]),
    EqualizerPreset('Treble Boost', [0.0, 0.0, 0.0, 4.0, 6.0]),
    EqualizerPreset('Vocal Boost', [0.0, 2.0, 4.0, 3.0, 0.0]),
  ];
}


/// Service to manage equalizer settings
/// Real EQ on Android, visual-only on other platforms
class EqualizerService extends ChangeNotifier {
  // Singleton pattern
  static final EqualizerService _instance = EqualizerService._internal();
  factory EqualizerService() => _instance;
  EqualizerService._internal() {
    _loadSettings();
  }
  
  static const String _enabledKey = 'equalizer_enabled';
  static const String _presetKey = 'equalizer_preset';
  static const String _customGainsKey = 'equalizer_custom_gains';
  
  bool _isEnabled = false;
  String _currentPreset = 'Flat';
  List<double> _customGains = [0.0, 0.0, 0.0, 0.0, 0.0];
  AndroidEqualizer? _androidEqualizer;
  bool _isInitialized = false;
  
  bool get isEnabled => _isEnabled;
  String get currentPreset => _currentPreset;
  List<double> get customGains => List.unmodifiable(_customGains);
  bool get isAndroid => Platform.isAndroid;
  bool get hasRealEQ => Platform.isAndroid && _isInitialized;
  AndroidEqualizer? get androidEqualizer => _androidEqualizer;
  
  /// Get AndroidEqualizer instance for AudioPipeline (must be called BEFORE creating AudioPlayer)
  AndroidEqualizer? createAndroidEqualizer() {
    if (!Platform.isAndroid) {
      return null;
    }
    
    if (_androidEqualizer != null) {
      // DebugLogger().log('Equalizer: Already created');
      return _androidEqualizer;
    }
    
    try {
      _androidEqualizer = AndroidEqualizer();
      // DebugLogger().log('Equalizer: Created Android EQ instance');
      return _androidEqualizer;
    } catch (e) {
      return null;
    }
  }
  
  /// Initialize equalizer after player is created
  Future<void> initializeAfterPlayerCreated() async {
    if (!Platform.isAndroid || _androidEqualizer == null) {
      return;
    }
    
    if (_isInitialized) {
      // DebugLogger().log('Equalizer: Already initialized');
      return;
    }
    
    try {
      await _androidEqualizer!.setEnabled(_isEnabled);
      
      // Apply saved settings if enabled
      if (_isEnabled) {
        await _applyCurrentSettings();
      }
      
      _isInitialized = true;
      notifyListeners();
      // DebugLogger().log('Equalizer: Initialized successfully with saved settings');
    } catch (e) {
      _isInitialized = false;
    }
  }
  
  /// Load saved settings from preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_enabledKey) ?? false;
      _currentPreset = prefs.getString(_presetKey) ?? 'Flat';
      
      final savedGains = prefs.getString(_customGainsKey);
      if (savedGains != null) {
        _customGains = savedGains.split(',').map((e) => double.parse(e)).toList();
      }
      
      // key fix: Apply settings after loading if enabled
      if (_isEnabled && _isInitialized) {
        await _applyCurrentSettings();
      }
      
      notifyListeners();
      // DebugLogger().log('Equalizer: Settings loaded (Enabled: $_isEnabled)');
    } catch (e) {
      // DebugLogger().log('Error loading equalizer settings: $e');
    }
  }
  
  /// Enable or disable equalizer
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    
    if (Platform.isAndroid && _androidEqualizer != null) {
      try {
        await _androidEqualizer!.setEnabled(enabled);
        if (enabled) {
          await _applyCurrentSettings();
        }
        // DebugLogger().log('Equalizer: Set enabled to $enabled');
      } catch (e) {
        // DebugLogger().log('Error setting equalizer enabled state: $e');
      }
    }
    
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, enabled);
    } catch (e) {
      // ignore pref error
    }
  }
  
  /// Set equalizer preset
  Future<void> setPreset(String presetName) async {
    final preset = EqualizerPreset.presets.firstWhere(
      (p) => p.name == presetName,
      orElse: () => EqualizerPreset.presets[0],
    );
    
    _currentPreset = presetName;
    _customGains = List.from(preset.gains);
    
    // Notify immediate UI update
    notifyListeners();
    
    if (_isEnabled) {
      _applyCurrentSettings();
    }
    
    // DebugLogger().log('Equalizer: Applied preset $presetName');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_presetKey, presetName);
      await prefs.setString(_customGainsKey, _customGains.join(','));
    } catch (e) {
       // ignore
    }
  }
  
  /// Set custom band gain
  Future<void> setBandGain(int bandIndex, double gain) async {
    if (bandIndex < 0 || bandIndex >= 5) return;
    
    _customGains[bandIndex] = gain.clamp(-15.0, 15.0);
    _currentPreset = 'Custom';
    
    // Notify immediate UI update (responsiveness)
    notifyListeners();
    
    if (_isEnabled) {
      // Fire and forget - don't await platform call to block UI
      _applyBandGain(bandIndex, gain);
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_presetKey, 'Custom');
      await prefs.setString(_customGainsKey, _customGains.join(','));
    } catch (e) {
       // ignore
    }
  }
  
  /// Apply current settings to Android EQ
  Future<void> _applyCurrentSettings() async {
    if (!Platform.isAndroid || _androidEqualizer == null) return;
    
    try {
      final parameters = await _androidEqualizer!.parameters;
      final bands = parameters.bands;
      
      // Apply gains to each band
      for (int i = 0; i < bands.length && i < _customGains.length; i++) {
        final band = bands[i];
        final minGain = parameters.minDecibels;
        final maxGain = parameters.maxDecibels;
        
        // Calculate gain
        double targetGain = _customGains[i]; 
        
        // Clamp to ensure we never exceed device capabilities
        double safeGain = targetGain.clamp(minGain, maxGain);
        
        await band.setGain(safeGain);
      }
      
      // log('Equalizer: Applied all bands');
    } catch (e) {
      // log('Error applying equalizer settings: $e');
    }
  }
  
  /// Apply single band gain to Android EQ
  Future<void> _applyBandGain(int bandIndex, double gain) async {
    if (!Platform.isAndroid || _androidEqualizer == null) return;
    
    try {
      final parameters = await _androidEqualizer!.parameters;
      final bands = parameters.bands;
      final minGain = parameters.minDecibels;
      final maxGain = parameters.maxDecibels;
      
      if (bandIndex < bands.length) {
        final band = bands[bandIndex];
        
        double safeGain = gain.clamp(minGain, maxGain);
        await band.setGain(safeGain);
      }
    } catch (e) {
      // DebugLogger().log('Error applying band gain: $e');
    }
  }
  
  /// Reset to flat
  Future<void> reset() async {
    await setPreset('Flat');
  }
  
  /// Dispose resources
  @override
  void dispose() {
    // AndroidEqualizer doesn't have a dispose method
    super.dispose();
  }
}
