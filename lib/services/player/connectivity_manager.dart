import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class ConnectivityManager {
  final BehaviorSubject<bool> isConnected = BehaviorSubject<bool>.seeded(true);
  Timer? _connectivityTimer;

  // Callbacks
  Function()? onNetworkReconnected;

  ConnectivityManager() {
    _startConnectivityMonitoring();
  }

  void _startConnectivityMonitoring() {
    _connectivityTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkNetworkConnectivity();
    });
  }

  Future<void> _checkNetworkConnectivity() async {
    try {
      bool nowConnected = false;

      // First try a lightweight socket connect to a reliable DNS server.
      // This avoids DNS resolution issues on some Android emulators/networks
      // where InternetAddress.lookup may fail even when network is available.
      try {
        final socket = await Socket.connect('8.8.8.8', 53,
            timeout: const Duration(seconds: 3));
        socket.destroy();
        nowConnected = true;
      } catch (_) {
        // Fallback to DNS lookup if socket connect failed
        try {
          final result = await InternetAddress.lookup('google.com');
          nowConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        } catch (e2) {
          debugPrint('DNS lookup fallback failed: $e2');
          nowConnected = false;
        }
      }

      final wasConnected = isConnected.value;
      isConnected.add(nowConnected);

      if (!wasConnected && nowConnected) {
        debugPrint('Network reconnected');
        onNetworkReconnected?.call();
      }
    } catch (e) {
      isConnected.add(false);
      debugPrint('Network connectivity check failed: $e');
    }
  }

  Future<bool> checkConnectivity() async {
    await _checkNetworkConnectivity();
    return isConnected.value;
  }

  void dispose() {
    _connectivityTimer?.cancel();
    isConnected.close();
  }
}
