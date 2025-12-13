class ChatMessage {
  final String id;
  final String peminjamanId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'admin' or 'user'
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.peminjamanId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'peminjamanId': peminjamanId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      peminjamanId: map['peminjamanId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as dynamic) is String
          ? DateTime.parse(map['timestamp'])
          : (map['timestamp'] as dynamic).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }
}
