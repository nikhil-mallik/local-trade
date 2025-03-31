import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_trade/providers/auth_provider.dart';
import 'package:local_trade/providers/listing_provider.dart';
import 'package:local_trade/providers/connectivity_provider.dart';
import 'package:local_trade/screens/login_screen.dart';
import 'package:local_trade/screens/listing_detail_screen.dart';
import 'package:local_trade/screens/add_listing_screen.dart';
import 'package:local_trade/screens/transfer_screen.dart';
import 'package:local_trade/widgets/listing_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Electronics',
    'Furniture',
    'Clothing',
    'Books',
    'Sports',
    'Other',
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Load listings when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingProvider>(context, listen: false).loadListings();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final listingProvider = Provider.of<ListingProvider>(context);
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);
    
    // If not logged in, show login screen
    if (!authProvider.isLoggedIn) {
      return const LoginScreen();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalTrade'),
        actions: [
          // Single icon button that shows dropdown menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              // Handle selection based on which option was chosen
              if (value == 'one') {
                 // Show profile or logout dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Profile'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${authProvider.currentUser!.name}'),
                      Text('Email: ${authProvider.currentUser!.email}'),
                      Text('Location: ${authProvider.currentUser!.location}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        authProvider.logout();
                      },
                      child: const Text('Logout'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
              } else if (value == 'two') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TransferScreen(),
                  ),
                );
              } 
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'one',
                child: Text('Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'two',
                child: Text('Transfer Data'),
              ),
              
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Connectivity status indicator
          if (!connectivityProvider.isOnline)
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                children: const [
                  Icon(Icons.wifi_off, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Offline Mode - Changes will sync when online',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search listings...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          
          // Category filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          
          // Listings
          Expanded(
            child: listingProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildListings(listingProvider),
          ),
        ],
      ),
      // In the FloatingActionButton onPressed callback, update it to:
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddListingScreen(),
            ),
          );
          
          // Reload listings when returning from add screen
          Provider.of<ListingProvider>(context, listen: false).loadListings();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildListings(ListingProvider provider) {
    // Filter listings based on search and category
    var filteredListings = provider.listings;
    
    // Apply search filter if text is entered
    if (_searchController.text.isNotEmpty) {
      filteredListings = provider.searchListings(_searchController.text);
    }
    
    // Apply category filter if not "All"
    if (_selectedCategory != 'All') {
      filteredListings = filteredListings
          .where((listing) => listing.category == _selectedCategory)
          .toList();
    }
    
    if (filteredListings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              provider.listings.isEmpty
                ? 'No listings available yet'
                : 'No listings match your search',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredListings.length,
      itemBuilder: (context, index) {
        final listing = filteredListings[index];
        
        return ListingCard(
          listing: listing,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ListingDetailScreen(listing: listing),
              ),
            );
          },
        );
      },
    );
  }
}