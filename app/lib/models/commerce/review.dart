class Review {
  final String fromUserId;
  final String toUserId;
  final String relatedService;
  final String relatedId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.fromUserId,
    required this.toUserId,
    required this.relatedService,
    required this.relatedId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        fromUserId: json['from_user_id'],
        toUserId: json['to_user_id'],
        relatedService: json['related_service'],
        relatedId: json['related_id'],
        rating: json['rating'],
        comment: json['comment'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'related_service': relatedService,
        'related_id': relatedId,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };
}
