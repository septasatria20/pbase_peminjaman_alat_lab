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
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromMap(doc.id, doc.data());
      }).toList();
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
      // FIX: Remove orderBy to avoid index requirement
      final querySnapshot = await _firestore
          .collection('chats')
          .where('peminjamanId', isEqualTo: peminjamanId)
          .where('senderId', isNotEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('❌ Error marking messages as read: $e');
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
