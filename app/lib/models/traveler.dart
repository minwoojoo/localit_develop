class Traveler {
  final List<String> preferredRegions;
  final List<String> travelStyle;
  final DateTime createdAt;
  final DateTime updatedAt;

  Traveler({
    required this.preferredRegions,
    required this.travelStyle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Traveler.fromJson(Map<String, dynamic> json) => Traveler(
        preferredRegions: List<String>.from(json['preferred_regions']),
        travelStyle: List<String>.from(json['travel_style']),
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'preferred_regions': preferredRegions,
        'travel_style': travelStyle,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
