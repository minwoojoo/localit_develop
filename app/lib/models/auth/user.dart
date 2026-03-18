class User {
  final String email;
  final String nickname;
  final String phoneNumber;
  final String type; // 'traveler' | 'local'
  final String profileImageUrl;
  final List<String> languages;
  final int trustScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.email,
    required this.nickname,
    required this.phoneNumber,
    required this.type,
    required this.profileImageUrl,
    required this.languages,
    required this.trustScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json['email'],
        nickname: json['nickname'],
        phoneNumber: json['phone_number'],
        type: json['type'],
        profileImageUrl: json['profileImageUrl'],
        languages: List<String>.from(json['languages']),
        trustScore: json['trust_score'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'nickname': nickname,
        'phone_number': phoneNumber,
        'type': type,
        'profileImageUrl': profileImageUrl,
        'languages': languages,
        'trust_score': trustScore,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
