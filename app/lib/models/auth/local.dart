class Local {
  final bool certified;
  final int age;
  final String gender;
  final String preferredMeetup;
  final String preferredLocation;
  final List<String> interests;
  final String hobbies;
  final Map<String, dynamic> verificationData;
  final String verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Local({
    required this.certified,
    required this.age,
    required this.gender,
    required this.preferredMeetup,
    required this.preferredLocation,
    required this.interests,
    required this.hobbies,
    required this.verificationData,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Local.fromJson(Map<String, dynamic> json) => Local(
        certified: json['certified'],
        age: json['age'],
        gender: json['gender'],
        preferredMeetup: json['preferred_meetup'],
        preferredLocation: json['preferred_location'],
        interests: List<String>.from(json['interests']),
        hobbies: json['hobbies'],
        verificationData: Map<String, dynamic>.from(json['verification_data']),
        verificationStatus: json['verification_status'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'certified': certified,
        'age': age,
        'gender': gender,
        'preferred_meetup': preferredMeetup,
        'preferred_location': preferredLocation,
        'interests': interests,
        'hobbies': hobbies,
        'verification_data': verificationData,
        'verification_status': verificationStatus,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
