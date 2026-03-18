class TravelerIntro {
  final String travelerId;
  final String title;
  final String content;
  final String location;
  final String preferredMeetup;
  final List<String> travelTheme;
  final DateTime createdAt;
  final DateTime updatedAt;

  TravelerIntro({
    required this.travelerId,
    required this.title,
    required this.content,
    required this.location,
    required this.preferredMeetup,
    required this.travelTheme,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TravelerIntro.fromJson(Map<String, dynamic> json) => TravelerIntro(
        travelerId: json['traveler_id'],
        title: json['title'],
        content: json['content'],
        location: json['location'],
        preferredMeetup: json['preferred_meetup'],
        travelTheme: List<String>.from(json['travel_theme']),
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'traveler_id': travelerId,
        'title': title,
        'content': content,
        'location': location,
        'preferred_meetup': preferredMeetup,
        'travel_theme': travelTheme,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
