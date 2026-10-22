class TaskRegistration {
  final String registrationId;
  final String taskId;
  final String volunteerId;
  final String volunteerName;
  final String? volunteerEmail;
  final String organizationId;
  final String status; // 'registered', 'cancelled'
  final String attendanceStatus; // 'pending', 'attended', 'absent'
  final DateTime registeredAt;
  final DateTime updatedAt;

  TaskRegistration({
    required this.registrationId,
    required this.taskId,
    required this.volunteerId,
    required this.volunteerName,
    this.volunteerEmail,
    required this.organizationId,
    this.status = 'registered',
    this.attendanceStatus = 'pending',
    required this.registeredAt,
    required this.updatedAt,
  });

  bool get isRegistered => status == 'registered';
  bool get isCancelled => status == 'cancelled';
  bool get isAttended => attendanceStatus == 'attended';

  Map<String, dynamic> toMap() {
    return {
      'registrationId': registrationId,
      'taskId': taskId,
      'volunteerId': volunteerId,
      'volunteerName': volunteerName,
      'volunteerEmail': volunteerEmail,
      'organizationId': organizationId,
      'status': status,
      'attendanceStatus': attendanceStatus,
      'registeredAt': registeredAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TaskRegistration.fromMap(Map<String, dynamic> map) {
    return TaskRegistration(
      registrationId: map['registrationId'] ?? '',
      taskId: map['taskId'] ?? '',
      volunteerId: map['volunteerId'] ?? '',
      volunteerName: map['volunteerName'] ?? 'Volunteer',
      volunteerEmail: map['volunteerEmail'],
      organizationId: map['organizationId'] ?? '',
      status: map['status'] ?? 'registered',
      attendanceStatus: map['attendanceStatus'] ?? 'pending',
      registeredAt: map['registeredAt'] != null
          ? DateTime.tryParse(map['registeredAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  TaskRegistration copyWith({
    String? status,
    String? attendanceStatus,
  }) {
    return TaskRegistration(
      registrationId: registrationId,
      taskId: taskId,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
      volunteerEmail: volunteerEmail,
      organizationId: organizationId,
      status: status ?? this.status,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      registeredAt: registeredAt,
      updatedAt: DateTime.now(),
    );
  }
}
