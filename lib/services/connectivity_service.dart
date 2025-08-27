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

  ConnectionStatus _currentStatus = ConnectionStatus.unknown; // Start with unknown status
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
      
      // Emit initial status to stream
      debugPrint('🌐 [CONNECTIVITY] Emitting initial status: $_currentStatus');
      _connectionStatusController.add(_currentStatus);

      // Listen to connectivity changes
      _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
        _updateConnectionStatus(results.first);
      });
    } catch (e) {
      // If connectivity plugin fails, assume disconnected for safety
      debugPrint('🌐 [CONNECTIVITY] Plugin failed, assuming disconnected: $e');
      _updateConnectionStatus(ConnectivityResult.none);
    }
  }

  Future<void> _checkConnectionStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results.first);
    } catch (e) {
      // If connectivity check fails, assume disconnected for safety
      debugPrint('🌐 [CONNECTIVITY] Check failed, assuming disconnected: $e');
      _updateConnectionStatus(ConnectivityResult.none);
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    ConnectionStatus newStatus;
    
    switch (result) {
      case ConnectivityResult.wifi:
        newStatus = ConnectionStatus.connected;
        debugPrint('🌐 [CONNECTIVITY] WiFi detected -> Connected');
        break;
      case ConnectivityResult.mobile:
        newStatus = ConnectionStatus.connected;
        debugPrint('🌐 [CONNECTIVITY] Mobile data detected -> Connected');
        break;
      case ConnectivityResult.ethernet:
        newStatus = ConnectionStatus.connected;
        debugPrint('🌐 [CONNECTIVITY] Ethernet detected -> Connected');
        break;
      case ConnectivityResult.none:
        newStatus = ConnectionStatus.disconnected;
        debugPrint('🌐 [CONNECTIVITY] No connection detected -> Disconnected');
        break;
      default:
        newStatus = ConnectionStatus.unknown;
        debugPrint('🌐 [CONNECTIVITY] Unknown connection type -> Unknown');
    }

    if (_currentStatus != newStatus) {
      debugPrint('🌐 [CONNECTIVITY] Status changed: $_currentStatus -> $newStatus');
      _currentStatus = newStatus;
      _connectionStatusController.add(newStatus);
    } else {
      debugPrint('🌐 [CONNECTIVITY] Status unchanged: $_currentStatus');
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final isConnected = results.first != ConnectivityResult.none;
      debugPrint('🌐 [CONNECTIVITY] checkConnectivity result: ${results.first} -> $isConnected');
      
      // Update current status based on check result
      _updateConnectionStatus(results.first);
      
      return isConnected;
    } catch (e) {
      // If connectivity check fails, assume disconnected for safety
      debugPrint('🌐 [CONNECTIVITY] checkConnectivity failed, assuming disconnected: $e');
      _updateConnectionStatus(ConnectivityResult.none);
      return false;
    }
  }

  // Force refresh connectivity status
  Future<void> refreshConnectivityStatus() async {
    debugPrint('🌐 [CONNECTIVITY] Refreshing connectivity status...');
    await _checkConnectionStatus();
  }

  // Test connectivity with a simple network request
  Future<bool> testNetworkConnectivity() async {
    try {
      debugPrint('🌐 [CONNECTIVITY] Testing network connectivity...');
      // Try to check connectivity status
      final result = await checkConnectivity();
      debugPrint('🌐 [CONNECTIVITY] Network test result: $result');
      return result;
    } catch (e) {
      debugPrint('🌐 [CONNECTIVITY] Network test failed: $e');
      return false;
    }
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
