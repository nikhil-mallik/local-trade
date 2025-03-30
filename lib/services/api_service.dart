import 'package:local_trade/models/listing.dart';
import 'package:local_trade/models/message.dart';

// This is a mock API service for demonstration purposes
// In a real app, this would make actual HTTP requests to a backend
class ApiService {
  static Future<void> saveListing(Listing listing) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would send the listing to a server
    print('Listing synced to server: ${listing.id}');
    
    // Simulate success
    return;
  }
  
  static Future<void> deleteListing(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would delete the listing on the server
    print('Listing deleted on server: $id');
    
    // Simulate success
    return;
  }
  
  static Future<void> sendMessage(Message message) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would send the message to a server
    print('Message sent to server: ${message.id}');
    
    // Simulate success
    return;
  }
  
  static Future<List<Listing>> getListings() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would fetch listings from a server
    // Return an empty list for this demo
    return [];
  }
}