import 'dart:convert';

class Listing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String condition;
  final String sellerId;
  final String sellerName;
  final int createdAt;
  final List<String> imagesPaths;
  
  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    required this.imagesPaths,
  });
  
  // Add copyWith method
  Listing copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? condition,
    String? sellerId,
    String? sellerName,
    int? createdAt,
    List<String>? imagesPaths,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      createdAt: createdAt ?? this.createdAt,
      imagesPaths: imagesPaths ?? this.imagesPaths,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'condition': condition,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'createdAt': createdAt,
      'imagesPaths': jsonEncode(imagesPaths), // Make sure this is properly encoded
    };
  }
  
  factory Listing.fromMap(Map<String, dynamic> map) {
    try {
      print('Parsing listing from map: ${map['id']}');
      print('Raw map data: $map');
      
      // Handle potential JSON parsing issues with imagesPaths
      List<String> imagePaths = [];
      try {
        final imagesJson = map['imagesPaths'];
        print('Images JSON: $imagesJson');
        
        if (imagesJson != null && imagesJson.isNotEmpty) {
          imagePaths = List<String>.from(jsonDecode(imagesJson));
          print('Parsed image paths: $imagePaths');
        }
      } catch (e) {
        print('Error parsing images for listing ${map['id']}: $e');
      }
      
      // Handle potential type issues with price
      double price = 0.0;
      try {
        if (map['price'] is int) {
          price = (map['price'] as int).toDouble();
        } else if (map['price'] is double) {
          price = map['price'];
        } else if (map['price'] is String) {
          price = double.parse(map['price']);
        }
      } catch (e) {
        print('Error parsing price for listing ${map['id']}: $e');
      }
      
      return Listing(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        price: price,
        category: map['category'] ?? 'Other',
        condition: map['condition'] ?? 'Unknown',
        sellerId: map['sellerId'] ?? '',
        sellerName: map['sellerName'] ?? '',
        createdAt: map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
        imagesPaths: imagePaths,
      );
    } catch (e) {
      print('Error creating Listing from map: $e');
      rethrow;
    }
  }
}