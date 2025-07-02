class Matching {
  final String requesterId;
  final String receiverId;
  final String status;
  final String preferredDate;
  final String location;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;

  Matching({
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.preferredDate,
    required this.location,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Matching.fromJson(Map<String, dynamic> json) => Matching(
        requesterId: json['requester_id'],
        receiverId: json['receiver_id'],
        status: json['status'],
        preferredDate: json['preferred_date'],
        location: json['location'],
        message: json['message'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'requester_id': requesterId,
        'receiver_id': receiverId,
        'status': status,
        'preferred_date': preferredDate,
        'location': location,
        'message': message,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
