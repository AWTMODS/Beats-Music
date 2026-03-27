import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beats_music/blocs/media_player/beats_player_cubit.dart';
import 'package:beats_music/blocs/mini_player/mini_player_cubit.dart';
import 'package:beats_music/screens/widgets/play_pause_widget.dart';
import 'package:beats_music/utils/load_image.dart';

class CarouselCardView extends StatelessWidget {
  final String coverImageUrl;
  // final ImageProvider<Object> placeHolder =
  //     const AssetImage("assets/sample/album_cover_sam1.jpg");
  const CarouselCardView({super.key, required this.coverImageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox(
        width: MediaQuery.of(context).size.width / 1.5,
        height: MediaQuery.of(context).size.height / 1.5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: LoadImageCached(imageUrl: coverImageUrl),
        ),
      ),
      Positioned(
        bottom: 15,
        right: 20,
        child: BlocBuilder<MiniPlayerCubit, MiniPlayerState>(
          builder: (context, state) {
            final player = context.read<BeatsPlayerCubit>().BeatsPlayer;
            return PlayPauseButton(
              size: 45,
              isPlaying: state.isPlaying,
              onPlay: player.play,
              onPause: player.pause,
            );
          },
        ),
      ),
    ]);
  }
}


