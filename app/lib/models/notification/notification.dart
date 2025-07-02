class NotificationModel {
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        userId: json['user_id'],
        title: json['title'],
        body: json['body'],
        type: json['type'],
        isRead: json['is_read'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };
}
