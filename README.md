# LocalTrade - Offline-First Community Marketplace

A Flutter mobile app for local marketplace coordination that works offline, designed for the Hackathon challenge.

## Features

- **Offline-First**: Create and browse listings without internet connection
- **Efficient Sync**: Automatically syncs data when connectivity is available
- **User-Owned Data**: All data stays on the user's device until they choose to sync
- **Resource-Efficient**: Optimized for low-resource environments
- **Community-Centered**: Designed for local community marketplace coordination
- **Image Support**: Add multiple images to listings that are stored locally
- **Search Functionality**: Find listings by title or description
- **Category Filtering**: Browse listings by category
- **Direct Messaging**: Contact sellers directly through the app

## Technical Implementation

- **Flutter Framework**: Cross-platform development for Android and iOS
- **SQLite Database**: Local storage for offline functionality with efficient data persistence
- **Provider Pattern**: State management for reactive UI updates
- **Connectivity Monitoring**: Detect network changes and sync accordingly
- **Image Handling**: Local storage of images with efficient loading
- **UUID Generation**: Unique identifiers for listings and messages

## App Structure

### Models
- **Listing**: Represents items for sale with properties like title, description, price, etc.
- **Message**: Handles communication between users
- **User**: Stores user information and preferences

### Providers
- **AuthProvider**: Manages user authentication state
- **ListingProvider**: Handles CRUD operations for listings
- **ConnectivityProvider**: Monitors network connectivity

### Screens
- **HomeScreen**: Main screen displaying all listings
- **AddListingScreen**: Form for creating new listings
- **EditListingScreen**: Form for updating existing listings
- **ListingDetailScreen**: Detailed view of a specific listing
- **ProfileScreen**: User profile and settings
- **MessagesScreen**: User conversations

## Getting Started

### Prerequisites

- Flutter SDK (2.17.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android or iOS device/emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/local_trade.git
cd local_trade
```
## Usage
### Creating a Listing
1. Tap the "+" button on the home screen
2. Fill in the listing details (title, description, price, etc.)
3. Add images by tapping the image area
4. Select a category and condition
5. Tap "SAVE LISTING"

### Browsing Listings
- Scroll through listings on the home screen
- Use the search bar to find specific items
- Filter by category using the dropdown menu
- Tap on any listing to view details
- Sort listings by price or date

### Messaging
1. Open a listing detail page
2. Tap "Contact Seller"
3. Type your message and send
4. View all conversations in the Messages tab
5. Receive notifications for new messages

### Offline Usage
- All features work without internet connection
- Create and browse listings while offline
- Messages are queued and sent when connection is restored
- Changes are stored locally and synchronized later
- Visual indicators show sync status of listings

## Architecture
The app follows a clean architecture approach with separation of concerns:

1. Data Layer :
   - SQLite database for local storage
   - Models for data representation
   - Repository pattern for data access

2. Business Logic Layer :
   - Providers for state management
   - Services for business logic

3. Presentation Layer :
   - Screens for UI components
   - Widgets for reusable UI elements

The app uses a unidirectional data flow:
- User actions trigger events in providers
- Providers update the state
- UI rebuilds based on the new state

## Offline-First Strategy
LocalTrade implements a true offline-first approach:
1. Local Database : All data is stored locally first using SQLite
2. Connectivity Detection : App monitors network status using the connectivity_plus package
3. Background Sync : When connectivity is restored, data is synced in the background
4. Conflict Resolution : Smart merging of local and remote data with timestamp-based conflict resolution
5. Optimistic UI : UI updates immediately with local data while syncing happens in background
6. Queue System : Operations are queued when offline and processed when online

## Performance Optimization
- Lazy Loading : Images and data are loaded on-demand
- Efficient Queries : Optimized database queries for faster data retrieval
- Memory Management : Proper disposal of resources to prevent memory leaks
- Image Compression : Automatic compression of images before storage
- Pagination : Listings are loaded in batches to improve performance
- Caching : Frequently accessed data is cached for quick access
- Minimal Rebuilds : UI components only rebuild when necessary

## Security Consideration
- Local Encryption : Sensitive data is encrypted on device
- Secure Communication : HTTPS for all network requests
- Input Validation : All user inputs are validated before processing
- Error Handling : Comprehensive error handling to prevent data loss
- Authentication : Secure user authentication system
- Data Sanitization : All user-generated content is sanitized before storage
- Permission Management : Minimal permission requirements

## Future Enhancements
- Peer-to-Peer Sync : Direct sync between devices without central server
- Offline Payments : Support for offline payment tracking
- Enhanced Search : Full-text search capabilities
- Reputation System : User ratings and reviews
- Geolocation : Location-based filtering of listings
- Barcode Scanning : Quick listing creation via barcode scanning
- AR Visualization : View items in your space using AR
- Multi-language Support : Internationalization for global users
- Dark Mode : Support for light and dark themes

## Contributing
1. Fork the repository
2. Create your feature branch ( git checkout -b feature/amazing-feature )
3. Commit your changes ( git commit -m 'Add some amazing feature' )
4. Push to the branch ( git push origin feature/amazing-feature )
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments
- Flutter team for the amazing framework
- SQLite for reliable local database
- Provider package for state management
- Image_picker package for handling images
- UUID package for generating unique identifiers
- All contributors and testers who helped improve the app
- The open-source community for inspiration and support

This README provides a comprehensive overview of your LocalTrade app, including its features, technical implementation, architecture, and usage instructions. It also includes information about the database schema, performance optimizations, security considerations, and future enhancement plans.