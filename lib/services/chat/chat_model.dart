class ChatMessageModel {
  final String message;
  final String role;
  final String sessionId;
  final DateTime messageTime;
  final String title;
  final DateTime? deletedAt;

  ChatMessageModel(
      {required this.message,
      required this.role,
      required this.sessionId,
      required this.messageTime,
      required this.title,
      this.deletedAt});

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'role': role,
      'session_id': sessionId,
      'message_time': messageTime.toIso8601String(),
      'title': title,
      'deleted_at': deletedAt?.toIso8601String()
    };
  }
}
