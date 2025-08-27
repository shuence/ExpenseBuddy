import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionStatus {
  connected,
  disconnected,
  unknown,
}

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectionStatus> _connectionStatusController = 
      StreamController<ConnectionStatus>.broadcast();

  Stream<ConnectionStatus> get connectionStatusStream => 
      _connectionStatusController.stream;

  ConnectionStatus _currentStatus = ConnectionStatus.connected; // Assume connected by default
  ConnectionStatus get currentStatus => _currentStatus;

  bool get isConnected {
    final connected = _currentStatus == ConnectionStatus.connected;
    debugPrint('🌐 [CONNECTIVITY] isConnected called: $connected (status: $_currentStatus)');
    return connected;
  }

  Future<void> initialize() async {
    try {
      // Check initial connection status
      await _checkConnectionStatus();

      // Listen to connectivity changes
      _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
        _updateConnectionStatus(results.first);
      });
    } catch (e) {
      // If connectivity plugin fails, assume connected
      _updateConnectionStatus(ConnectivityResult.wifi);
    }
  }

  Future<void> _checkConnectionStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results.first);
    } catch (e) {
      // If connectivity check fails, assume connected
      _updateConnectionStatus(ConnectivityResult.wifi);
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    ConnectionStatus newStatus;
    
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        newStatus = ConnectionStatus.connected;
        break;
      case ConnectivityResult.none:
        newStatus = ConnectionStatus.disconnected;
        break;
      default:
        newStatus = ConnectionStatus.unknown;
    }

    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _connectionStatusController.add(newStatus);
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.first != ConnectivityResult.none;
    } catch (e) {
      // If connectivity check fails, assume connected
      return true;
    }
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
