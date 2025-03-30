import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:local_trade/models/listing.dart';
import 'package:local_trade/models/message.dart';

class DatabaseService {
  static Database? _database;
  
  static Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'local_trade.db');
    
    // Print the database path for debugging
    print('Database path: $path');
    
    // Delete existing database to recreate with correct schema
    await deleteDatabase(path);
    print('Deleted existing database to recreate schema');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print('Creating database tables...');
        // Create listings table with all required columns
        await db.execute('''
          CREATE TABLE listings(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            price REAL,
            category TEXT,
            condition TEXT,
            sellerId TEXT,
            sellerName TEXT,
            createdAt INTEGER,
            imagesPaths TEXT
          )
        ''');
        
        // Create messages table
        await db.execute('''
          CREATE TABLE messages(
            id TEXT PRIMARY KEY,
            senderId TEXT,
            receiverId TEXT,
            listingId TEXT,
            content TEXT,
            timestamp INTEGER,
            isRead INTEGER
          )
        ''');
        print('Database tables created successfully');
      },
    );
  }
  
  // Listings methods
  // The commented method can be removed since we have a better implementation below
  
  static Future<void> saveListing(Listing listing) async {
    final db = await database;
    
    // Convert the listing to a map with proper JSON encoding for the images
    final listingMap = listing.toMap();
    
    // Add debug print to see what's being saved
    print('Saving listing to database: ${listing.id}');
    print('Listing data: $listingMap');
    
    try {
      await db.insert(
        'listings',
        listingMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // Verify the listing was saved by retrieving it
      final savedListing = await db.query(
        'listings',
        where: 'id = ?',
        whereArgs: [listing.id],
      );
      
      print('Verification - Saved listing retrieved: ${savedListing.isNotEmpty}');
      if (savedListing.isNotEmpty) {
        print('Saved listing data: ${savedListing.first}');
      }
    } catch (e) {
      print('Error saving listing to database: $e');
      // Try to get more information about the error
      print('Error details: ${e.toString()}');
      rethrow;
    }
  }
  
  // Find the duplicate getListings methods and keep only one of them
  // Replace the duplicate methods with a single implementation:
  
  static Future<List<Listing>> getListings() async {
    final db = await database;
    
    // Add debug print
    print('Querying listings from database');
    
    final List<Map<String, dynamic>> maps = await db.query('listings');
    
    print('Database returned ${maps.length} listings');
    
    // If no listings found, print the tables in the database to verify structure
    if (maps.isEmpty) {
      final tables = await db.query('sqlite_master', 
                                   columns: ['name'], 
                                   where: 'type = ?', 
                                   whereArgs: ['table']);
      print('Database tables: ${tables.map((t) => t['name']).toList()}');
    }
    
    return List.generate(maps.length, (i) {
      try {
        return Listing.fromMap(maps[i]);
      } catch (e) {
        print('Error parsing listing ${maps[i]['id']}: $e');
        // Return a placeholder listing in case of error
        return Listing(
          id: maps[i]['id'] ?? 'error',
          title: 'Error loading listing',
          description: 'There was an error loading this listing',
          price: 0.0,
          category: 'Other',
          condition: 'Unknown',
          sellerId: '',
          sellerName: '',
          createdAt: DateTime.now().millisecondsSinceEpoch,
          imagesPaths: [],
        );
      }
    });
  }
  
  static Future<void> deleteListing(String id) async {
    final db = await database;
    
    await db.delete(
      'listings',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    print('Deleted listing from database: $id');
  }
  
  // Messages methods
  static Future<List<Message>> getMessages(String listingId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'listingId = ?',
      whereArgs: [listingId],
      orderBy: 'timestamp ASC',
    );
    
    print('Database query returned ${maps.length} messages for listing $listingId');
    
    return List.generate(maps.length, (i) {
      return Message.fromMap(maps[i]);
    });
  }
  
  static Future<void> saveMessage(Message message) async {
    final db = await database;
    
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    print('Saved message to database: ${message.id}');
  }
}