import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/services/listening_statistics_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:beats_music/services/cloud_sync_service.dart';

class WrappedView extends StatefulWidget {
  const WrappedView({super.key});

  @override
  State<WrappedView> createState() => _WrappedViewState();
}

class _WrappedViewState extends State<WrappedView> {
  final PageController _pageController = PageController();
  final ListeningStatisticsService _statsService = ListeningStatisticsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _loadAllStats(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: Default_Theme.successAccent),
                        );
                      }
                      
                      final data = snapshot.data!;
                      return PageView(
                        controller: _pageController,
                        children: [
                          _buildIntroSlide(),
                          _buildTotalTimeSlide(data['totalStats']),
                          _buildTopSongsSlide(data['topSongs']),
                          _buildTopArtistSlide(data['topArtists']),
                          _buildGenreSlide(data['topGenres']),
                          _buildSummarySlide(data),
                        ],
                      );
                    },
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _loadAllStats() async {
    final totalStats = await _statsService.getTotalListeningStats();
    final topSongs = await _statsService.getTopSongs(limit: 5);
    final topArtists = await _statsService.getTopArtists(limit: 3);
    final topGenres = await _statsService.getTopGenres(limit: 3);
    
    return {
      'totalStats': totalStats,
      'topSongs': topSongs,
      'topArtists': topArtists,
      'topGenres': topGenres,
    };
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(MingCute.close_line, color: Colors.white, size: 28),
            onPressed: () => context.pop(),
          ),
          Text(
            'BEATS WRAPPED',
            style: Default_Theme.primaryTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildIntroSlide() {
    return _buildSlideContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Default_Theme.successAccent.withValues(alpha: 0.1),
            ),
            child: const Icon(MingCute.music_2_fill, size: 80, color: Default_Theme.successAccent),
          ),
          const SizedBox(height: 40),
          Text(
            'Ready to see your\nmusical journey?',
            textAlign: TextAlign.center,
            style: Default_Theme.primaryTextStyle.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Swipe to reveal your stats for this month',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTimeSlide(Map<String, dynamic> stats) {
    final minutes = (stats['totalSeconds'] as int) ~/ 60;
    return _buildSlideContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "You've been active!",
            style: Default_Theme.secondoryTextStyle.copyWith(fontSize: 20, color: Default_Theme.successAccent),
          ),
          const SizedBox(height: 20),
          Text(
            '$minutes',
            style: Default_Theme.primaryTextStyle.copyWith(fontSize: 100, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Minutes Listened',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 40),
          Text(
            "That's like flying around the world twice! ✈️",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSongsSlide(List<dynamic> songs) {
    return _buildSlideContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Your absolute\nfavorites',
            style: Default_Theme.primaryTextStyle.copyWith(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ...songs.asMap().entries.map((entry) {
            final i = entry.key;
            final song = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                   Text(
                    '${i + 1}',
                    style: TextStyle(fontSize: 32, color: Default_Theme.successAccent.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.songTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
                        Text(song.artist, style: const TextStyle(fontSize: 14, color: Colors.white60)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopArtistSlide(List<dynamic> artists) {
    if (artists.isEmpty) return const SizedBox();
    final top = artists.first;
    return _buildSlideContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Your Top Artist is',
            style: TextStyle(fontSize: 20, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Text(
            top.artistName,
            textAlign: TextAlign.center,
            style: Default_Theme.primaryTextStyle.copyWith(fontSize: 48, fontWeight: FontWeight.bold, color: Default_Theme.successAccent),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              '${top.playCount} Plays',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreSlide(Map<String, int> genres) {
    return _buildSlideContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(MingCute.palette_line, size: 60, color: Default_Theme.successAccent),
          const SizedBox(height: 30),
          const Text(
            'Your musical mix is',
            style: TextStyle(fontSize: 20, color: Colors.white70),
          ),
          const SizedBox(height: 30),
          ...genres.keys.take(3).map((g) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              g,
              style: Default_Theme.primaryTextStyle.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          )),
        ],
      ),
    );
  }

  bool _isSyncing = false;

  Widget _buildSummarySlide(Map<String, dynamic> data) {
    return _buildSlideContainer(
       child: Center(
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Container(
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(
                 color: Colors.white.withValues(alpha: 0.05),
                 borderRadius: BorderRadius.circular(24),
                 border: Border.all(color: Colors.white10),
               ),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Text('MY BEATS STORY', style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, color: Default_Theme.successAccent)),
                   const SizedBox(height: 20),
                   _buildSummaryRow(MingCute.time_line, '${(data['totalStats']['totalSeconds'] as int) ~/ 60} Mins'),
                   _buildSummaryRow(MingCute.music_2_line, '${data['topSongs'].isNotEmpty ? data['topSongs'][0].songTitle : 'None'}'),
                   _buildSummaryRow(MingCute.user_3_line, '${data['topArtists'].isNotEmpty ? data['topArtists'][0].artistName : 'None'}'),
                   const SizedBox(height: 30),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton.icon(
                       onPressed: _isSyncing ? null : () async {
                         setState(() => _isSyncing = true);
                         final month = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";
                         
                         // Prepare serializable stats
                         final serializableStats = {
                           'minutes': (data['totalStats']['totalSeconds'] as int) ~/ 60,
                           'topSong': data['topSongs'].isNotEmpty ? data['topSongs'][0].songTitle : 'None',
                           'topArtist': data['topArtists'].isNotEmpty ? data['topArtists'][0].artistName : 'None',
                         };

                         await CloudSyncService().saveWrappedSnapshot(
                           monthId: month,
                           stats: serializableStats,
                         );

                         if (mounted) {
                           setState(() => _isSyncing = false);
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(
                               content: Text('Stats synced to your cloud account! ☁️'),
                               backgroundColor: Default_Theme.successAccent,
                             ),
                           );
                         }
                       },
                       icon: _isSyncing 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Icon(MingCute.upload_2_line),
                       label: Text(_isSyncing ? 'Syncing...' : 'Save to Cloud'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Default_Theme.successAccent,
                         foregroundColor: Colors.black,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
             const SizedBox(height: 20),
             TextButton.icon(
                onPressed: () {}, // Future: actual share image
                icon: const Icon(MingCute.share_forward_line, color: Colors.white70),
                label: const Text('Share Card', style: TextStyle(color: Colors.white70)),
             ),
           ],
         ),
       ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.white60),
          const SizedBox(width: 12),
          Flexible(child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildSlideContainer({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: child,
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          Icon(MingCute.down_line, color: Colors.white24),
          SizedBox(height: 8),
          Text('Swipe through', style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}
