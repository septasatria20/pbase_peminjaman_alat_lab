import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ChatMessage> _messages = [];
  int _unreadCount = 0;

  List<ChatMessage> get messages => _messages;
  int get unreadCount => _unreadCount;

  // Stream chat messages for a specific peminjaman
  Stream<List<ChatMessage>> getChatStream(String peminjamanId) {
    return _firestore
        .collection('chats')
        .where('peminjamanId', isEqualTo: peminjamanId)
        // REMOVE .orderBy to avoid composite index requirement
        .snapshots()
        .map((snapshot) {
      // Sort manually in client side
      final messages = snapshot.docs.map((doc) {
        return ChatMessage.fromMap(doc.id, doc.data());
      }).toList();
      
      // Sort by timestamp ascending (oldest first)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      return messages;
    });
  }

  // Send message
  Future<void> sendMessage({
    required String peminjamanId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    try {
      await _firestore.collection('chats').add({
        'peminjamanId': peminjamanId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      print('✅ Message sent successfully');
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  /// Mark messages as read for current user
  Future<void> markMessagesAsRead(String peminjamanId, String currentUserId) async {
    try {
      // SIMPLIFIED: Only filter by peminjamanId, then check in-memory
      final querySnapshot = await _firestore
          .collection('chats')
          .where('peminjamanId', isEqualTo: peminjamanId)
          .get();

      final batch = _firestore.batch();
      
      // Filter in-memory to avoid complex index
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String?;
        final isRead = data['isRead'] as bool?;
        
        // Only update if message is from other user and not read yet
        if (senderId != currentUserId && isRead == false) {
          batch.update(doc.reference, {'isRead': true});
        }
      }

      await batch.commit();
      print('✅ Messages marked as read successfully');
    } catch (e) {
      print('❌ Error marking messages as read: $e');
      // Don't throw - just log, so chat still works
    }
  }

  // Get unread count for user
  Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection('chats')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
