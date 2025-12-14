import 'dart:collection';

/// Simple in-memory log storage for debugging cloud sync
class DebugLogger {
  static final DebugLogger _instance = DebugLogger._internal();
  factory DebugLogger() => _instance;
  DebugLogger._internal();

  final _logs = Queue<String>();
  static const _maxLogs = 200;

  void log(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19); // HH:MM:SS
    _logs.add('[$timestamp] $message');
    
    if (_logs.length > _maxLogs) {
      _logs.removeFirst();
    }
    
    // Also print to console
    print(message);
  }

  List<String> getLogs() => _logs.toList();

  void clear() => _logs.clear();
}
