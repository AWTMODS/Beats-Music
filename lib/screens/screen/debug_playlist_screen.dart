import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:beats_music/services/debug_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebugPlaylistScreen extends StatefulWidget {
  const DebugPlaylistScreen({super.key});

  @override
  State<DebugPlaylistScreen> createState() => _DebugPlaylistScreenState();
}

class _DebugPlaylistScreenState extends State<DebugPlaylistScreen> {
  String _debugOutput = '';
  bool _isLoading = false;
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    setState(() {
      _logs = DebugLogger().getLogs();
    });
  }

  Future<void> _checkDatabase() async {
    setState(() {
      _isLoading = true;
      _debugOutput = 'Checking database...';
    });

    try {
      final playlists = await BeatsMusicDBService.getPlaylists4Library();
      
      StringBuffer output = StringBuffer();
      output.writeln('=== DATABASE CHECK ===\n');
      output.writeln('Total playlists: ${playlists.length}\n');
      
      for (var playlist in playlists) {
        output.writeln('📁 ${playlist.playlistName}');
        output.writeln('   Songs: ${playlist.mediaItems.length}');
        if (playlist.mediaItems.isNotEmpty) {
          output.writeln('   First: ${playlist.mediaItems.first.title}');
        }
        output.writeln('');
      }
      
      setState(() {
        _debugOutput = output.toString();
        _isLoading = false;
      });
      
    } catch (e, stack) {
      setState(() {
        _debugOutput = 'ERROR:\n$e\n\nStack:\n$stack';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Debug Playlist Sync', style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.white,
            tabs: [
              Tab(text: 'Database', icon: Icon(Icons.storage)),
              Tab(text: 'Sync Logs', icon: Icon(Icons.list)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                _loadLogs();
                _checkDatabase();
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Database Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkDatabase,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isLoading ? 'Checking...' : 'Check Database'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _debugOutput.isEmpty ? 'Tap "Check Database" to start...' : _debugOutput,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Logs Tab
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF1C1C1E),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_logs.length} log entries',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          DebugLogger().clear();
                          _loadLogs();
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          final text = _logs.join('\n');
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to clipboard')),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _logs.isEmpty
                        ? const Center(
                            child: Text(
                              'No logs yet.\nSign in to see CloudSync logs!',
                              style: TextStyle(color: Colors.white54),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              final log = _logs[_logs.length - 1 - index]; // Reverse order (newest first)
                              final isError = log.contains('❌') || log.contains('ERROR');
                              final isSuccess = log.contains('✅');
                              final isWarning = log.contains('⚠️');
                              
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: SelectableText(
                                  log,
                                  style: TextStyle(
                                    color: isError
                                        ? Colors.red.shade300
                                        : isSuccess
                                            ? Colors.green.shade300
                                            : isWarning
                                                ? Colors.orange.shade300
                                                : Colors.white,
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
