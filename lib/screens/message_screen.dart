import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_trade/models/listing.dart';
import 'package:local_trade/models/message.dart';
import 'package:local_trade/providers/auth_provider.dart';
import 'package:local_trade/services/database_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:io'; // Add this import for File class

class MessageScreen extends StatefulWidget {
  final Listing listing;
  
  const MessageScreen({
    Key? key,
    required this.listing,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  
  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      _messages = await DatabaseService.getMessages(widget.listing.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (currentUser == null) return;
    
    final message = Message(
      senderId: currentUser.id,
      receiverId: widget.listing.sellerId,
      listingId: widget.listing.id,
      content: text,
    );
    
    try {
      await DatabaseService.saveMessage(message);
      
      setState(() {
        _messages.add(message);
        _messageController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;
    if (currentUser == null) return const Scaffold(body: Center(child: Text('Not logged in')));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat about ${widget.listing.title}'),
      ),
      body: Column(
        children: [
          // Listing info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                // Listing image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: widget.listing.imagesPaths.isNotEmpty
                        ? DecorationImage(
                            image: FileImage(File(widget.listing.imagesPaths.first)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[300],
                  ),
                  child: widget.listing.imagesPaths.isEmpty
                      ? const Icon(Icons.image_not_supported)
                      : null,
                ),
                const SizedBox(width: 16),
                // Listing details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.listing.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${widget.listing.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Messages
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('No messages yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == currentUser.id;
                          
                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.green[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.content,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(message.timestamp),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    if (now.difference(date).inDays > 0) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}