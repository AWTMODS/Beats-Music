import 'package:flutter/material.dart';
import 'package:beats_music/services/crossfade_service.dart';
import 'package:beats_music/theme_data/default.dart';

/// Crossfade settings widget for settings screen
class CrossfadeSettings extends StatelessWidget {
  final CrossfadeService crossfadeService;
  
  const CrossfadeSettings({
    super.key,
    required this.crossfadeService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: crossfadeService,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enable/Disable Toggle
            SwitchListTile(
              title: const Text(
                'Crossfade',
                style: TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                crossfadeService.isEnabled
                    ? 'Smooth transitions between tracks'
                    : 'Disabled',
                style: TextStyle(
                  color: Default_Theme.primaryColor1.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              value: crossfadeService.isEnabled,
              activeColor: Default_Theme.accentColor2,
              activeTrackColor: Default_Theme.accentColor2.withOpacity(0.5),
              onChanged: (value) async {
                await crossfadeService.setEnabled(value);
              },
            ),
            
            // Duration Slider (only visible when enabled)
            if (crossfadeService.isEnabled) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Crossfade Duration',
                          style: TextStyle(
                            color: Default_Theme.primaryColor1.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${crossfadeService.durationSeconds}s',
                          style: const TextStyle(
                            color: Default_Theme.accentColor2,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: crossfadeService.durationSeconds.toDouble(),
                      min: 1,
                      max: 12,
                      divisions: 11,
                      activeColor: Default_Theme.accentColor2,
                      inactiveColor: Default_Theme.primaryColor1.withOpacity(0.2),
                      label: '${crossfadeService.durationSeconds}s',
                      onChanged: (value) async {
                        await crossfadeService.setDuration(value.toInt());
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '1s',
                            style: TextStyle(
                              color: Default_Theme.primaryColor1.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '12s',
                            style: TextStyle(
                              color: Default_Theme.primaryColor1.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
