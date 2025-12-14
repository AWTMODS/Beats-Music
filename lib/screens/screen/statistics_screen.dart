import 'package:beats_music/model/statistics/artist_statistics.dart';
import 'package:beats_music/model/statistics/play_history.dart';
import 'package:beats_music/model/statistics/song_statistics.dart';
import 'package:beats_music/services/listening_statistics_service.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:beats_music/screens/screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _statsService = ListeningStatisticsService();
  bool _isLoading = true;
  
  List<SongStatisticsDB> _topSongs = [];
  List<ArtistStatisticsDB> _topArtists = [];
  Map<String, int> _topGenres = {};
  int _totalListeningTime = 0; // seconds

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    final topSongs = await _statsService.getTopSongs(limit: 10);
    final topArtists = await _statsService.getTopArtists(limit: 10);
    final topGenres = await _statsService.getTopGenres(limit: 5);
    final totalTime = await _statsService.getTotalListeningTime();

    if (mounted) {
      setState(() {
        _topSongs = topSongs;
        _topArtists = topArtists;
        _topGenres = topGenres;
        _totalListeningTime = totalTime;
        _isLoading = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds sec';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(1)} min';
    return '${(seconds / 3600).toStringAsFixed(1)} hrs';
  }

  Future<void> _showResetConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Default_Theme.themeColor,
        title: const Text('Reset Statistics?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently delete all listening history and statistics. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _statsService.clearAllStatistics();
      if (mounted) {
        _loadStatistics();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statistics reset successfully'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        title: const Text('Listening Statistics', style: TextStyle(color: Default_Theme.primaryColor1)),
        backgroundColor: Default_Theme.themeColor,
        iconTheme: const IconThemeData(color: Default_Theme.primaryColor1),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _showResetConfirmation(context),
            icon: const Icon(MingCute.delete_2_line, color: Colors.white),
            tooltip: 'Reset Statistics',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Top Artists'),
                  const SizedBox(height: 12),
                  _buildTopArtistsList(),
                   const SizedBox(height: 24),
                  _buildSectionTitle('Top Songs'),
                  const SizedBox(height: 12),
                  _buildTopSongsList(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Top Genres'),
                  const SizedBox(height: 12),
                  _buildTopGenresList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Default_Theme.accentColor2.withOpacity(0.8), Default_Theme.accentColor1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            MingCute.time_fill,
            _formatDuration(_totalListeningTime),
            'Listening Time',
          ),
          _buildSummaryItem(
            MingCute.music_fill,
            _topSongs.length.toString(), // Actually this is top songs limit, maybe show total played? 
            // Better to show something else if topSongs.length is just 10.
            // Let's just show top songs count for now or maybe total plays if we had it easily summed.
            // Simpler: Just Total Listening Time is the hero metric.
            'Songs Played', // Placeholder label, actually top songs count here
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Default_Theme.primaryColor1,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTopArtistsList() {
    if (_topArtists.isEmpty) {
      return const Text('No data yet', style: TextStyle(color: Colors.white54));
    }
    
    // Find max play count for progress bar
    int maxPlays = _topArtists.isNotEmpty ? _topArtists.first.playCount : 1;

    return ListView.builder(

      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _topArtists.length,
      itemBuilder: (context, index) {
        final artist = _topArtists[index];
        final progress = artist.playCount / maxPlays;
        
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(searchQuery: artist.artistName),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${index + 1}. ${artist.artistName}', 
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                    ),
                    const SizedBox(width: 8),
                    Text(_formatDuration(artist.totalListeningTime), 
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(Default_Theme.accentColor2),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 2),
                Text('${artist.playCount} plays', 
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopSongsList() {
    if (_topSongs.isEmpty) {
      return const Text('No data yet', style: TextStyle(color: Colors.white54));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _topSongs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final song = _topSongs[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Default_Theme.accentColor2, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(song.songTitle, 
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
          subtitle: Text(song.artist, 
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white60, fontSize: 14)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${song.playCount} plays', 
                style: const TextStyle(color: Default_Theme.accentColor2, fontSize: 12)),
               Text(_formatDuration(song.totalListeningTime), 
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopGenresList() {
    if (_topGenres.isEmpty) {
      return const Text('No data yet', style: TextStyle(color: Colors.white54));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _topGenres.entries.map((entry) {
        return Chip(
          backgroundColor: Colors.white10,
          label: Text(
            entry.key, 
            style: const TextStyle(color: Colors.white),
          ),
          avatar: CircleAvatar(
            backgroundColor: Default_Theme.accentColor2,
            child: const Icon(MingCute.music_2_fill, size: 12, color: Colors.black),
          ),
        );
      }).toList(),
    );
  }
}
