import 'package:flutter/foundation.dart';
import 'package:local_trade/models/user.dart';
import 'package:uuid/uuid.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  
  bool get isLoggedIn => _currentUser != null;
  
  Future<void> login(String email, String password) async {
    // In a real app, this would validate against stored credentials
    // For demo purposes, we'll create a mock user
    _currentUser = User(
      id: const Uuid().v4(),
      name: 'Demo User',
      email: email,
      phone: '555-123-4567',
      location: 'New York, NY',
      lastSynced: DateTime.now().millisecondsSinceEpoch,
    );
    
    notifyListeners();
  }
  
  // Make sure the register method is properly implemented
  Future<void> register(String name, String email, String password, String phone, String location) async {
    // In a real app, this would store credentials in a database
    // For demo purposes, we'll create a mock user
    _currentUser = User(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      location: location,
      lastSynced: DateTime.now().millisecondsSinceEpoch,
    );
    
    notifyListeners();
  }
  
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}