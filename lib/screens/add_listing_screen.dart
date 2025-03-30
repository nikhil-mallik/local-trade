import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_trade/models/listing.dart';
import 'package:local_trade/providers/auth_provider.dart';
import 'package:local_trade/providers/listing_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart'; // Add this import at the top
import 'dart:io';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({Key? key}) : super(key: key);

  @override
  _AddListingScreenState createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCategory = 'Electronics';
  String _selectedCondition = 'New';
  List<XFile> _selectedImages = [];
  
  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Home & Garden',
    'Sports',
    'Toys',
    'Vehicles',
    'Other',
  ];
  
  final List<String> _conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
    'Poor',
  ];
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images;
      });
    }
  }
  
  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }
    
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create a listing')),
      );
      return;
    }
    
    final listing = Listing(
      id: const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      category: _selectedCategory,
      condition: _selectedCondition,
      sellerId: currentUser.id,
      sellerName: currentUser.name,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      imagesPaths: _selectedImages.map((image) => image.path).toList(),
    );
    
    try {
      await Provider.of<ListingProvider>(context, listen: false).addListing(listing);
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save listing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Listing'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Images
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 48),
                            SizedBox(height: 8),
                            Text('Add Images'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Stack(
                              children: [
                                Image.file(
                                  File(_selectedImages[index].path),
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImages.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Condition
            DropdownButtonFormField<String>(
              value: _selectedCondition,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: _conditions.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(condition),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Save button
            ElevatedButton(
              onPressed: _saveListing,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('SAVE LISTING', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}