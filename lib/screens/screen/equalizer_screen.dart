import 'dart:async';
import 'package:flutter/material.dart';

import 'package:beats_music/services/equalizer_service.dart';
import 'package:beats_music/theme_data/default.dart';

/// Equalizer screen with presets and manual controls
class EqualizerScreen extends StatefulWidget {
  final EqualizerService equalizerService;
  
  const EqualizerScreen({
    super.key,
    required this.equalizerService,
  });

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  static const List<String> bandLabels = ['60Hz', '230Hz', '910Hz', '3.6kHz', '14kHz'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        title: const Text(
          'Equalizer',
          style: TextStyle(
            color: Default_Theme.primaryColor1,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.equalizerService,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Platform indicator
              if (!widget.equalizerService.hasRealEQ)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Visual-only mode: Real equalizer is only available on Android',
                          style: TextStyle(
                            color: Default_Theme.primaryColor1,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Enable/Disable Toggle
              SwitchListTile(
                title: Text(
                  'Enable Equalizer',
                  style: TextStyle(
                    color: Default_Theme.primaryColor1,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  widget.equalizerService.hasRealEQ
                      ? 'Modify audio output in real-time'
                      : 'Save your preferred settings',
                  style: TextStyle(
                    color: Default_Theme.primaryColor1.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                value: widget.equalizerService.isEnabled,
                activeColor: Default_Theme.accentColor2,
                activeTrackColor: Default_Theme.accentColor2.withOpacity(0.5),
                onChanged: (value) async {
                  await widget.equalizerService.setEnabled(value);
                },
              ),
              
              const SizedBox(height: 24),
              
              // Presets Section
              Text(
                'Presets',
                style: TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Preset chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: EqualizerPreset.presets.map((preset) {
                  final isSelected = widget.equalizerService.currentPreset == preset.name;
                  return ChoiceChip(
                    label: Text(
                      preset.name,
                      style: TextStyle(
                        color: isSelected
                            ? Default_Theme.primaryColor2
                            : Default_Theme.primaryColor1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Default_Theme.accentColor2,
                    backgroundColor: Default_Theme.themeColor,
                    onSelected: (selected) async {
                      if (selected) {
                        await widget.equalizerService.setPreset(preset.name);
                      }
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Manual Controls Section
              Text(
                'Manual Controls',
                style: TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.equalizerService.currentPreset == 'Custom'
                    ? 'Custom settings'
                    : 'Adjust sliders to create custom preset',
                style: TextStyle(
                  color: Default_Theme.primaryColor1.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              
              // Frequency band sliders
              ...List.generate(5, (index) {
                return _BandSlider(
                  label: bandLabels[index],
                  value: widget.equalizerService.customGains[index],
                  onChanged: (value) async {
                    await widget.equalizerService.setBandGain(index, value);
                  },
                  enabled: widget.equalizerService.isEnabled,
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _BandSlider extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final bool enabled;
  
  const _BandSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  @override
  State<_BandSlider> createState() => _BandSliderState();
}

class _BandSliderState extends State<_BandSlider> {
  late double _localValue;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value;
  }

  @override
  void didUpdateWidget(_BandSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update local value from parent if we're not currently dragging/debouncing
    // or if the change is significant (e.g. preset change)
    if (_debounceTimer == null && (widget.value - _localValue).abs() > 0.1) {
      _localValue = widget.value;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handleChanged(double newValue) {
    setState(() {
      _localValue = newValue;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      widget.onChanged(newValue);
      _debounceTimer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.enabled
                      ? Default_Theme.primaryColor1
                      : Default_Theme.primaryColor1.withOpacity(0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_localValue.toStringAsFixed(1)} dB',
                style: TextStyle(
                  color: widget.enabled
                      ? Default_Theme.accentColor2
                      : Default_Theme.primaryColor1.withOpacity(0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: widget.enabled
                  ? Default_Theme.accentColor2
                  : Default_Theme.primaryColor1.withOpacity(0.2),
              inactiveTrackColor: Default_Theme.primaryColor1.withOpacity(0.1),
              thumbColor: widget.enabled
                  ? Default_Theme.accentColor2
                  : Default_Theme.primaryColor1.withOpacity(0.3),
              overlayColor: Default_Theme.accentColor2.withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _localValue,
              min: -15.0,
              max: 15.0,
              divisions: 60,
              label: '${_localValue.toStringAsFixed(1)} dB',
              onChanged: widget.enabled ? _handleChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}
