class AppNotification {
  final String id;
  final String recipientUserId;
  final String title;
  final String message;
  final String type; // 'skill_match', 'attendance_present', 'attendance_absent', 'registration'
  final String? relatedTaskId;
  final int pointsEarned;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.recipientUserId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedTaskId,
    this.pointsEarned = 0,
    this.isRead = false,
    required this.createdAt,
  });

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      recipientUserId: recipientUserId,
      title: title,
      message: message,
      type: type,
      relatedTaskId: relatedTaskId,
      pointsEarned: pointsEarned,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientUserId': recipientUserId,
      'title': title,
      'message': message,
      'type': type,
      'relatedTaskId': relatedTaskId,
      'pointsEarned': pointsEarned,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      recipientUserId: map['recipientUserId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'skill_match',
      relatedTaskId: map['relatedTaskId'],
      pointsEarned: map['pointsEarned'] ?? 0,
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
