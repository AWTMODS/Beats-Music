import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beats_music/blocs/mediaPlayer/beats_player_cubit.dart';
import 'package:beats_music/services/playback_speed_service.dart';
import 'package:beats_music/theme_data/default.dart';

/// Compact speed control button for player screen
class SpeedControlButton extends StatelessWidget {
  final PlaybackSpeedService speedService;
  
  const SpeedControlButton({
    super.key,
    required this.speedService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: speedService,
      builder: (context, _) {
        return GestureDetector(
          onTap: () => _showSpeedDialog(context),
          onLongPress: () => _cycleSpeed(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: speedService.currentSpeed != 1.0
                  ? Default_Theme.accentColor2.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: speedService.currentSpeed != 1.0
                    ? Default_Theme.accentColor2
                    : Default_Theme.primaryColor1.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.speed,
                  size: 18,
                  color: speedService.currentSpeed != 1.0
                      ? Default_Theme.accentColor2
                      : Default_Theme.primaryColor1,
                ),
                const SizedBox(width: 4),
                Text(
                  speedService.getSpeedLabel(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: speedService.currentSpeed != 1.0
                        ? Default_Theme.accentColor2
                        : Default_Theme.primaryColor1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _cycleSpeed(BuildContext context) async {
    await speedService.cycleSpeed();
    final player = context.read<BeatsPlayerCubit>().beatsMusicPlayer;
    await player.audioPlayer.setSpeed(speedService.currentSpeed);
  }

  void _showSpeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SpeedDialog(speedService: speedService),
    );
  }
}

class _SpeedDialog extends StatelessWidget {
  final PlaybackSpeedService speedService;

  const _SpeedDialog({required this.speedService});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Default_Theme.themeColor,
      title: const Text(
        'Playback Speed',
        style: TextStyle(
          color: Default_Theme.primaryColor1,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Speed presets
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PlaybackSpeedService.speedPresets.map((speed) {
              return ListenableBuilder(
                listenable: speedService,
                builder: (context, _) {
                  final isSelected = speedService.currentSpeed == speed;
                  return ChoiceChip(
                    label: Text(
                      speed == 1.0 ? '1x' : '${speed}x',
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
                        await speedService.setSpeed(speed);
                        final player = context.read<BeatsPlayerCubit>().beatsMusicPlayer;
                        await player.audioPlayer.setSpeed(speed);
                      }
                    },
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Custom speed slider
          ListenableBuilder(
            listenable: speedService,
            builder: (context, _) {
              return Column(
                children: [
                  const Text(
                    'Custom Speed',
                    style: TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontSize: 12,
                    ),
                  ),
                  Slider(
                    value: speedService.currentSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 30,
                    activeColor: Default_Theme.accentColor2,
                    inactiveColor: Default_Theme.primaryColor1.withOpacity(0.3),
                    label: speedService.getSpeedLabel(),
                    onChanged: (value) async {
                      await speedService.setSpeed(value);
                      final player = context.read<BeatsPlayerCubit>().beatsMusicPlayer;
                      await player.audioPlayer.setSpeed(value);
                    },
                  ),
                  Text(
                    speedService.getSpeedLabel(),
                    style: const TextStyle(
                      color: Default_Theme.accentColor2,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await speedService.resetSpeed();
            final player = context.read<BeatsPlayerCubit>().beatsMusicPlayer;
            await player.audioPlayer.setSpeed(1.0);
          },
          child: const Text(
            'Reset',
            style: TextStyle(color: Default_Theme.primaryColor1),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(color: Default_Theme.accentColor2),
          ),
        ),
      ],
    );
  }
}
