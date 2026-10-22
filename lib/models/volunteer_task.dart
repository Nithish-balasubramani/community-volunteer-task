class VolunteerTask {
  final String taskId;
  final String organizationId;
  final String organizationName;
  final String title;
  final String description;
  final String category; // Environment, Education, Health, Community, Animal Care, etc.
  final List<String> requiredSkills;
  final DateTime eventDate;
  final String startTime; // e.g. "09:00 AM"
  final String endTime;   // e.g. "01:00 PM"
  final String location;
  final int volunteerLimit;
  final int registeredCount;
  final DateTime registrationDeadline;
  final String status; // 'active', 'cancelled', 'completed'
  final DateTime createdAt;
  final DateTime updatedAt;

  VolunteerTask({
    required this.taskId,
    required this.organizationId,
    required this.organizationName,
    required this.title,
    required this.description,
    required this.category,
    required this.requiredSkills,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.volunteerLimit,
    this.registeredCount = 0,
    required this.registrationDeadline,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFull => registeredCount >= volunteerLimit;
  int get availableSlots => (volunteerLimit - registeredCount).clamp(0, volunteerLimit);
  bool get isRegistrationClosed => DateTime.now().isAfter(registrationDeadline);
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isAvailable => !isFull && !isRegistrationClosed && status == 'active';

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'title': title,
      'description': description,
      'category': category,
      'requiredSkills': requiredSkills,
      'eventDate': eventDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'volunteerLimit': volunteerLimit,
      'registeredCount': registeredCount,
      'registrationDeadline': registrationDeadline.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VolunteerTask.fromMap(Map<String, dynamic> map) {
    return VolunteerTask(
      taskId: map['taskId'] ?? '',
      organizationId: map['organizationId'] ?? '',
      organizationName: map['organizationName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      eventDate: map['eventDate'] != null
          ? DateTime.tryParse(map['eventDate']) ?? DateTime.now()
          : DateTime.now(),
      startTime: map['startTime'] ?? '09:00 AM',
      endTime: map['endTime'] ?? '12:00 PM',
      location: map['location'] ?? '',
      volunteerLimit: (map['volunteerLimit'] as num?)?.toInt() ?? 10,
      registeredCount: (map['registeredCount'] as num?)?.toInt() ?? 0,
      registrationDeadline: map['registrationDeadline'] != null
          ? DateTime.tryParse(map['registrationDeadline']) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] ?? 'active',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  VolunteerTask copyWith({
    String? title,
    String? description,
    String? category,
    List<String>? requiredSkills,
    DateTime? eventDate,
    String? startTime,
    String? endTime,
    String? location,
    int? volunteerLimit,
    int? registeredCount,
    DateTime? registrationDeadline,
    String? status,
  }) {
    return VolunteerTask(
      taskId: taskId,
      organizationId: organizationId,
      organizationName: organizationName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      volunteerLimit: volunteerLimit ?? this.volunteerLimit,
      registeredCount: registeredCount ?? this.registeredCount,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
