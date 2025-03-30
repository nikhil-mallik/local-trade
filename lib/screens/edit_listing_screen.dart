import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_trade/models/listing.dart';
import 'package:local_trade/providers/listing_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditListingScreen extends StatefulWidget {
  final Listing listing;
  
  const EditListingScreen({
    Key? key,
    required this.listing,
  }) : super(key: key);

  @override
  _EditListingScreenState createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  
  late String _selectedCategory;
  late String _selectedCondition;
  late List<String> _imagePaths;
  
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
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.listing.title);
    _descriptionController = TextEditingController(text: widget.listing.description);
    _priceController = TextEditingController(text: widget.listing.price.toString());
    _selectedCategory = widget.listing.category;
    _selectedCondition = widget.listing.condition;
    _imagePaths = List.from(widget.listing.imagesPaths);
  }
  
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
        _imagePaths.addAll(images.map((image) => image.path));
      });
    }
  }
  
  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }
    
    final updatedListing = widget.listing.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      category: _selectedCategory,
      condition: _selectedCondition,
      imagesPaths: _imagePaths,
    );
    
    try {
      await Provider.of<ListingProvider>(context, listen: false).updateListing(updatedListing);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update listing: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Listing'),
                  content: const Text('Are you sure you want to delete this listing?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                try {
                  await Provider.of<ListingProvider>(context, listen: false)
                      .deleteListing(widget.listing.id);
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete listing: $e')),
                  );
                }
              }
            },
          ),
        ],
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
                child: _imagePaths.isEmpty
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
                        itemCount: _imagePaths.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Stack(
                              children: [
                                Image.file(
                                  File(_imagePaths[index]),
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
                                        _imagePaths.removeAt(index);
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
              onPressed: _updateListing,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('UPDATE LISTING', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}