import 'package:flutter/foundation.dart';
import 'package:local_trade/models/listing.dart';
import 'package:local_trade/services/database_service.dart';

class ListingProvider with ChangeNotifier {
  List<Listing> _listings = [];
  bool _isLoading = false;
  
  List<Listing> get listings => _listings;
  bool get isLoading => _isLoading;
  
  // Add a constructor to load listings when provider is created
  ListingProvider() {
    // Load listings when the provider is initialized
    loadListings();
  }
  
  Future<void> loadListings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      print('Loading listings from database...');
      _listings = await DatabaseService.getListings();
      print('Loaded ${_listings.length} listings:');
      for (var listing in _listings) {
        print('Listing ID: ${listing.id}, Title: ${listing.title}, Price: ${listing.price}');
      }
    } catch (e) {
      print('Error loading listings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addListing(Listing listing) async {
    try {
      print('Adding listing to provider: ${listing.id}');
      await DatabaseService.saveListing(listing);
      _listings.add(listing);
      // Print the newly added listing
      print('Added new listing: ID: ${listing.id}, Title: ${listing.title}, Price: ${listing.price}');
      print('Current listings count: ${_listings.length}');
      notifyListeners();
      return Future.value(); // Success
    } catch (e) {
      print('Error adding listing: $e');
      return Future.error(e); // Propagate error to UI
    }
  }
  
  // Add the searchListings method that's used in HomeScreen
  List<Listing> searchListings(String query) {
    final lowercaseQuery = query.toLowerCase();
    final results = _listings.where((listing) {
      return listing.title.toLowerCase().contains(lowercaseQuery) ||
             listing.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
    
    // Print search results
    print('Search query: "$query" returned ${results.length} results');
    for (var listing in results) {
      print('Result: ${listing.title}');
    }
    
    return results;
  }
  
  Future<void> updateListing(Listing updatedListing) async {
    try {
      await DatabaseService.saveListing(updatedListing);
      
      final index = _listings.indexWhere((listing) => listing.id == updatedListing.id);
      if (index != -1) {
        _listings[index] = updatedListing;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating listing: $e');
    }
  }
  
  Future<void> deleteListing(String id) async {
    try {
      await DatabaseService.deleteListing(id);
      
      _listings.removeWhere((listing) => listing.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting listing: $e');
    }
  }
}