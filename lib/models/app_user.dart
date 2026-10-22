class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final String role; // 'volunteer' or 'organization'
  final String? phone;
  final List<String> skills;
  final List<String> interests;
  final List<String> availabilityDays; // e.g., 'Sunday', 'Saturday'
  final List<String> availabilityTimeSlots; // e.g., 'Morning', 'Afternoon'
  final String? preferredLocation;
  final String? organizationDescription;
  final int points;
  final int verifiedAttendanceCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.skills = const [],
    this.interests = const [],
    this.availabilityDays = const [],
    this.availabilityTimeSlots = const [],
    this.preferredLocation,
    this.organizationDescription,
    this.points = 0,
    this.verifiedAttendanceCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOrganization => role == 'organization';
  bool get isVolunteer => role == 'volunteer';

  // Badge Milestones
  String get tierName {
    if (points >= 300) return 'Platinum Changemaker';
    if (points >= 150) return 'Gold Leader';
    if (points >= 75) return 'Silver Contributor';
    return 'Bronze Volunteer';
  }

  String get tierBadgeEmoji {
    if (points >= 300) return '💎';
    if (points >= 150) return '🥇';
    if (points >= 75) return '🥈';
    return '🥉';
  }

  int get nextTierThreshold {
    if (points < 75) return 75;
    if (points < 150) return 150;
    if (points < 300) return 300;
    return 300;
  }

  double get tierProgress {
    if (points >= 300) return 1.0;
    if (points >= 150) return ((points - 150) / 150).clamp(0.0, 1.0);
    if (points >= 75) return ((points - 75) / 75).clamp(0.0, 1.0);
    return (points / 75).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'skills': skills,
      'interests': interests,
      'availabilityDays': availabilityDays,
      'availabilityTimeSlots': availabilityTimeSlots,
      'preferredLocation': preferredLocation,
      'organizationDescription': organizationDescription,
      'points': points,
      'verifiedAttendanceCount': verifiedAttendanceCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'volunteer',
      phone: map['phone'],
      skills: List<String>.from(map['skills'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      availabilityDays: List<String>.from(map['availabilityDays'] ?? []),
      availabilityTimeSlots: List<String>.from(map['availabilityTimeSlots'] ?? []),
      preferredLocation: map['preferredLocation'],
      organizationDescription: map['organizationDescription'],
      points: map['points'] ?? 0,
      verifiedAttendanceCount: map['verifiedAttendanceCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AppUser copyWith({
    String? fullName,
    String? phone,
    List<String>? skills,
    List<String>? interests,
    List<String>? availabilityDays,
    List<String>? availabilityTimeSlots,
    String? preferredLocation,
    String? organizationDescription,
    int? points,
    int? verifiedAttendanceCount,
  }) {
    return AppUser(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      role: role,
      phone: phone ?? this.phone,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      availabilityDays: availabilityDays ?? this.availabilityDays,
      availabilityTimeSlots: availabilityTimeSlots ?? this.availabilityTimeSlots,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      organizationDescription: organizationDescription ?? this.organizationDescription,
      points: points ?? this.points,
      verifiedAttendanceCount: verifiedAttendanceCount ?? this.verifiedAttendanceCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
