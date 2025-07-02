class ChatMessage {
  final String senderId;
  final String message;
  final String translatedMessage;
  final String type;
  final DateTime createdAt;

  ChatMessage({
    required this.senderId,
    required this.message,
    required this.translatedMessage,
    required this.type,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        senderId: json['sender_id'],
        message: json['message'],
        translatedMessage: json['translated_message'],
        type: json['type'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'sender_id': senderId,
        'message': message,
        'translated_message': translatedMessage,
        'type': type,
        'created_at': createdAt.toIso8601String(),
      };
}
