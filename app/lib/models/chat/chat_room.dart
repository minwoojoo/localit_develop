class ChatRoom {
  final String travelerId;
  final String localId;
  final String relatedMatchId;
  final DateTime createdAt;

  ChatRoom({
    required this.travelerId,
    required this.localId,
    required this.relatedMatchId,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) => ChatRoom(
        travelerId: json['traveler_id'],
        localId: json['local_id'],
        relatedMatchId: json['related_match_id'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'traveler_id': travelerId,
        'local_id': localId,
        'related_match_id': relatedMatchId,
        'created_at': createdAt.toIso8601String(),
      };
}
