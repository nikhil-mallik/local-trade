import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:local_trade/services/database_service.dart';
import 'package:local_trade/services/api_service.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isOnline = false;
  
  bool get isOnline => _isOnline;
  
  ConnectivityProvider() {
    checkConnectivity();
    Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  Future<void> checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Error checking connectivity: $e');
      _isOnline = false;
      notifyListeners();
    }
  }
  
  void _updateConnectionStatus(ConnectivityResult result) {
    print('Connectivity changed: $result');
    _isOnline = result != ConnectivityResult.none;
    notifyListeners();
  }
}