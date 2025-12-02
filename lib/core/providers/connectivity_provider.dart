import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isConnected = true;
  bool _hasShownOfflineDialog = false;

  bool get isConnected => _isConnected;
  bool get hasShownOfflineDialog => _hasShownOfflineDialog;

  ConnectivityProvider() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Could not check connectivity status: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final bool wasConnected = _isConnected;
    
    // Check if the connectivity result indicates a connection
    _isConnected = result == ConnectivityResult.mobile || 
                   result == ConnectivityResult.wifi || 
                   result == ConnectivityResult.ethernet ||
                   result == ConnectivityResult.vpn;

    // Reset dialog flag when connection is restored
    if (_isConnected && !wasConnected) {
      _hasShownOfflineDialog = false;
    }

    debugPrint('Connectivity changed: $_isConnected (Result: $result)');
    notifyListeners();
  }

  void markOfflineDialogShown() {
    _hasShownOfflineDialog = true;
    notifyListeners();
  }

  void resetOfflineDialogFlag() {
    _hasShownOfflineDialog = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
