import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;
  bool _wasConnected = true;

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  void initialize(BuildContext context) {
    _subscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      // ignore: use_build_context_synchronously
      _handleConnectivityChange(result, context);
    });

    // Check initial connection state
    _connectivity.checkConnectivity().then((result) {
      _wasConnected = result != ConnectivityResult.none;
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  void _handleConnectivityChange(
      ConnectivityResult result, BuildContext context) {
    bool isConnected = result != ConnectivityResult.none;

    // Only show notification when connection is lost
    if (_wasConnected && !isConnected) {
      _showNoConnectionSnackBar(context);
    }
    // Show reconnected message when connection is restored
    else if (!_wasConnected && isConnected) {
      _showReconnectedSnackBar(context);
    }

    _wasConnected = isConnected;
  }

  void _showNoConnectionSnackBar(BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No internet connection',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(
            days: 365), // Keep showing until connection is restored
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showReconnectedSnackBar(BuildContext context) {
    if (!context.mounted) return;

    // Hide the no connection snackbar if it's showing
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Connection restored',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
