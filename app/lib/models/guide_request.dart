class GuideRequest {
  final String fromUserId;
  final String toUserId;
  final String meetingLocation;
  final DateTime scheduledTime;
  final String duration;
  final String status;
  final int fee;
  final DateTime createdAt;

  GuideRequest({
    required this.fromUserId,
    required this.toUserId,
    required this.meetingLocation,
    required this.scheduledTime,
    required this.duration,
    required this.status,
    required this.fee,
    required this.createdAt,
  });

  factory GuideRequest.fromJson(Map<String, dynamic> json) => GuideRequest(
        fromUserId: json['from_user_id'],
        toUserId: json['to_user_id'],
        meetingLocation: json['meeting_location'],
        scheduledTime: DateTime.parse(json['scheduled_time']),
        duration: json['duration'],
        status: json['status'],
        fee: json['fee'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'meeting_location': meetingLocation,
        'scheduled_time': scheduledTime.toIso8601String(),
        'duration': duration,
        'status': status,
        'fee': fee,
        'created_at': createdAt.toIso8601String(),
      };
}
