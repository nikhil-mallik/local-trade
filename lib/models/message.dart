import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String listingId;
  final String content;
  final int timestamp;
  final bool isRead;
  
  Message({
    String? id,
    required this.senderId,
    required this.receiverId,
    required this.listingId,
    required this.content,
    int? timestamp,
    this.isRead = false,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'listingId': listingId,
      'content': content,
      'timestamp': timestamp,
      'isRead': isRead ? 1 : 0,
    };
  }
  
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      listingId: map['listingId'],
      content: map['content'],
      timestamp: map['timestamp'],
      isRead: map['isRead'] == 1,
    );
  }
}