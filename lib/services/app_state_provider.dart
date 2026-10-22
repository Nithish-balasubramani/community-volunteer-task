import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/app_user.dart';
import '../models/volunteer_task.dart';
import '../models/task_registration.dart';
import '../models/app_notification.dart';
import 'matching_service.dart';
import 'seed_data.dart';

import 'firebase_service.dart';

class AppStateProvider extends ChangeNotifier {
  static const String _sessionFileName = '.vc_session';
  final _uuid = const Uuid();
  final FirebaseService _firebaseService = FirebaseService();

  FirebaseService get firebaseService => _firebaseService;

  // Current authenticated user
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Stored collections
  final List<AppUser> _users = [];
  final List<VolunteerTask> _tasks = [];
  final List<TaskRegistration> _registrations = [];
  final List<AppNotification> _notifications = [];

  AppStateProvider() {
    _initializeSeedData();
    _restoreSavedSession();
    _syncFromFirestore();
  }

  File _getSessionFile() {
    try {
      final tempDir = Directory.systemTemp.path;
      if (tempDir.isNotEmpty && tempDir != '/') {
        return File('$tempDir/$_sessionFileName');
      }
    } catch (_) {}
    return File(_sessionFileName);
  }

  Future<void> _syncFromFirestore() async {
    try {
      final cloudUsers = await _firebaseService.fetchAllUsers();
      for (final u in cloudUsers) {
        final idx = _users.indexWhere((x) => x.uid == u.uid);
        if (idx != -1) {
          _users[idx] = u;
        } else {
          _users.add(u);
        }
      }

      final cloudTasks = await _firebaseService.fetchTasks();
      for (final t in cloudTasks) {
        final idx = _tasks.indexWhere((x) => x.taskId == t.taskId);
        if (idx != -1) {
          _tasks[idx] = t;
        } else {
          _tasks.insert(0, t);
        }
      }

      final cloudRegs = await _firebaseService.fetchRegistrations();
      for (final r in cloudRegs) {
        final idx = _registrations.indexWhere((x) => x.registrationId == r.registrationId);
        if (idx != -1) {
          _registrations[idx] = r;
        } else {
          _registrations.add(r);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Firestore sync notice (offline or first run): $e');
    }
  }

  Future<void> _restoreSavedSession() async {
    try {
      // 1. Check Firebase Auth first
      final fbUser = _firebaseService.auth?.currentUser;
      if (fbUser != null) {
        final profile = await _firebaseService.getUser(fbUser.uid);
        if (profile != null) {
          _currentUser = profile;
          final idx = _users.indexWhere((u) => u.uid == profile.uid);
          if (idx != -1) {
            _users[idx] = profile;
          } else {
            _users.add(profile);
          }
          await _saveSessionUser(profile);
          notifyListeners();
          return;
        }
      }

      // 2. Check locally saved session JSON (preserves session across restarts forever)
      final file = _getSessionFile();
      if (await file.exists()) {
        final content = (await file.readAsString()).trim();
        if (content.isNotEmpty) {
          try {
            final Map<String, dynamic> userMap = jsonDecode(content);
            final user = AppUser.fromMap(userMap);
            if (user.uid.isNotEmpty) {
              _currentUser = user;
              final idx = _users.indexWhere((u) => u.uid == user.uid);
              if (idx != -1) {
                _users[idx] = user;
              } else {
                _users.add(user);
              }
              notifyListeners();
              return;
            }
          } catch (_) {
            // If it was just a raw UID string
            final found = _users.firstWhere((u) => u.uid == content, orElse: () => _users.first);
            if (found.uid.isNotEmpty) {
              _currentUser = found;
              notifyListeners();
              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to restore saved session: $e');
    }
  }

  void _initializeSeedData() {
    _users.addAll(SeedData.initialUsers);
    _tasks.addAll(SeedData.initialTasks);
    _registrations.addAll(SeedData.initialRegistrations);
    _initializeDemoNotifications();
  }

  void _initializeDemoNotifications() {
    _notifications.addAll([
      AppNotification(
        id: 'notif_demo_1',
        recipientUserId: 'vol_alex_chen',
        title: 'High Skill Match Opportunity! 🌱',
        message: 'GreenEarth Foundation just posted "Community Tree Plantation Drive" matching your Gardening & Tree Planting skills!',
        type: 'skill_match',
        relatedTaskId: 'task_tree_plantation_01',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'notif_demo_2',
        recipientUserId: 'vol_alex_chen',
        title: 'Attendance Verified! +50 Points ⭐',
        message: 'GreenEarth Foundation marked you Present for the Community Clean-Up. 50 service points awarded!',
        type: 'attendance_present',
        pointsEarned: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 'notif_demo_3',
        recipientUserId: 'vol_maya_patel',
        title: 'New Skill Match! 📚',
        message: 'Hope Literacy Initiative posted "Weekend Reading Club" matching your Teaching skills!',
        type: 'skill_match',
        relatedTaskId: 'task_reading_club_02',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);
  }

  // Getters
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<AppUser> get allUsers => List.unmodifiable(_users);
  List<VolunteerTask> get allTasks => List.unmodifiable(_tasks);
  List<TaskRegistration> get allRegistrations => List.unmodifiable(_registrations);
  List<AppNotification> get allNotifications => List.unmodifiable(_notifications);

  List<AppNotification> getUserNotifications(String userId) {
    final list = _notifications.where((n) => n.recipientUserId == userId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int getUnreadNotificationCount(String userId) {
    return _notifications.where((n) => n.recipientUserId == userId && !n.isRead).length;
  }

  void markNotificationAsRead(String notifId) {
    final idx = _notifications.indexWhere((n) => n.id == notifId);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead(String userId) {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].recipientUserId == userId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Authentication
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final trimmedEmail = email.trim();

    // 1. Try Firebase Authentication first
    try {
      final userCred = await _firebaseService.signInWithEmailPassword(trimmedEmail, password);
      final fbUid = userCred?.user?.uid;
      if (fbUid != null) {
        // Fetch or create Firestore user record with timeout
        AppUser? profile;
        try {
          profile = await _firebaseService.getUser(fbUid).timeout(const Duration(seconds: 4));
        } catch (_) {}

        profile ??= AppUser(
          uid: fbUid,
          fullName: userCred?.user?.displayName ?? trimmedEmail.split('@').first,
          email: trimmedEmail,
          role: 'volunteer',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save in background without blocking
        _firebaseService.saveUser(profile).catchError((e) {
          debugPrint('saveUser background notice: $e');
        });

        final idx = _users.indexWhere((u) => u.uid == profile!.uid);
        if (idx != -1) {
          _users[idx] = profile;
        } else {
          _users.add(profile);
        }

        _currentUser = profile;
        _isLoading = false;
        notifyListeners();
        _saveSessionUser(profile.uid);
        return true;
      }
    } catch (fbError) {
      debugPrint('Firebase signIn error: $fbError');
    }

    // 2. Fallback to existing demo / local accounts
    final matchedUser = _users.firstWhere(
      (u) => u.email.toLowerCase() == trimmedEmail.toLowerCase(),
      orElse: () => AppUser(
        uid: '',
        fullName: '',
        email: '',
        role: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (matchedUser.uid.isNotEmpty) {
      _currentUser = matchedUser;
      _isLoading = false;
      notifyListeners();
      _saveSessionUser(matchedUser.uid);
      return true;
    } else {
      _errorMessage = 'Invalid email or password. Please verify credentials or register.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveSessionUser(dynamic userOrUid) async {
    try {
      final file = _getSessionFile();
      if (userOrUid is AppUser) {
        await file.writeAsString(jsonEncode(userOrUid.toMap()));
      } else if (userOrUid is String) {
        final found = _users.where((u) => u.uid == userOrUid);
        if (found.isNotEmpty) {
          await file.writeAsString(jsonEncode(found.first.toMap()));
        } else {
          await file.writeAsString(userOrUid);
        }
      }
    } catch (e) {
      debugPrint('Failed to save session: $e');
    }
  }

  Future<void> _clearSessionUser() async {
    try {
      final file = _getSessionFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Failed to clear session: $e');
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String role, // 'volunteer' or 'organization'
    String? phone,
    List<String> skills = const [],
    List<String> interests = const [],
    List<String> availabilityDays = const [],
    List<String> availabilityTimeSlots = const [],
    String? preferredLocation,
    String? organizationDescription,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final trimmedEmail = email.trim();

    String userUid = 'user_${_uuid.v4().substring(0, 8)}';

    // 1. Register with Firebase Authentication
    try {
      final cred = await _firebaseService.registerWithEmailPassword(trimmedEmail, password);
      if (cred?.user != null) {
        userUid = cred!.user!.uid;
      }
    } catch (fbError) {
      debugPrint('Firebase registration error: $fbError');
      final errString = fbError.toString().toLowerCase();
      if (errString.contains('email-already-in-use')) {
        _errorMessage = 'This email is already registered in Firebase. Please sign in instead.';
        _isLoading = false;
        notifyListeners();
        return false;
      } else if (errString.contains('weak-password')) {
        _errorMessage = 'Password is too weak. Please use at least 6 characters.';
        _isLoading = false;
        notifyListeners();
        return false;
      } else if (errString.contains('invalid-email')) {
        _errorMessage = 'Please enter a valid email address.';
        _isLoading = false;
        notifyListeners();
        return false;
      } else if (errString.contains('network-request-failed') || errString.contains('timeout')) {
        _errorMessage = 'Network connection timed out. Please check your internet connection.';
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _errorMessage = 'Registration error: ${fbError.toString()}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    final newUser = AppUser(
      uid: userUid,
      fullName: fullName.trim(),
      email: trimmedEmail.toLowerCase(),
      role: role,
      phone: phone?.trim(),
      skills: skills,
      interests: interests,
      availabilityDays: availabilityDays,
      availabilityTimeSlots: availabilityTimeSlots,
      preferredLocation: preferredLocation?.trim(),
      organizationDescription: organizationDescription?.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 2. Persist to Firestore in background (offline resilient)
    _firebaseService.saveUser(newUser).catchError((e) {
      debugPrint('Firestore saveUser error: $e');
    });

    _users.add(newUser);
    _currentUser = newUser;
    _isLoading = false;
    notifyListeners();
    _saveSessionUser(newUser.uid);
    return true;
  }

  void switchDemoUser(String uid) {
    final user = _users.firstWhere((u) => u.uid == uid, orElse: () => _users.first);
    _currentUser = user;
    notifyListeners();
    _saveSessionUser(user.uid);
  }

  void logout() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      debugPrint('Firebase signOut notice: $e');
    }
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
    _clearSessionUser();
  }

  // Profile Updates
  Future<void> updateProfile({
    required String fullName,
    String? phone,
    List<String>? skills,
    List<String>? interests,
    List<String>? availabilityDays,
    List<String>? availabilityTimeSlots,
    String? preferredLocation,
    String? organizationDescription,
  }) async {
    if (_currentUser == null) return;

    final updated = _currentUser!.copyWith(
      fullName: fullName,
      phone: phone,
      skills: skills,
      interests: interests,
      availabilityDays: availabilityDays,
      availabilityTimeSlots: availabilityTimeSlots,
      preferredLocation: preferredLocation,
      organizationDescription: organizationDescription,
    );

    final idx = _users.indexWhere((u) => u.uid == updated.uid);
    if (idx != -1) {
      _users[idx] = updated;
    }
    _currentUser = updated;
    notifyListeners();
  }

  // Task Operations (Organization privileged)
  Future<bool> createTask({
    required String title,
    required String description,
    required String category,
    required List<String> requiredSkills,
    required DateTime eventDate,
    required String startTime,
    required String endTime,
    required String location,
    required int volunteerLimit,
    required DateTime registrationDeadline,
  }) async {
    if (_currentUser == null || !_currentUser!.isOrganization) {
      _errorMessage = 'Unauthorized: Only registered organizations can create tasks.';
      notifyListeners();
      return false;
    }

    final newTask = VolunteerTask(
      taskId: 'task_${_uuid.v4().substring(0, 8)}',
      organizationId: _currentUser!.uid,
      organizationName: _currentUser!.fullName,
      title: title.trim(),
      description: description.trim(),
      category: category,
      requiredSkills: requiredSkills,
      eventDate: eventDate,
      startTime: startTime,
      endTime: endTime,
      location: location.trim(),
      volunteerLimit: volunteerLimit,
      registeredCount: 0,
      registrationDeadline: registrationDeadline,
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _tasks.insert(0, newTask);

    // Persist to Cloud Firestore
    try {
      await _firebaseService.createTask(newTask);
    } catch (e) {
      debugPrint('Firestore createTask error: $e');
    }

    // Auto-dispatch notifications to volunteers whose skills match the new task
    for (final vol in _users.where((u) => u.isVolunteer)) {
      final match = MatchingService.calculateMatch(vol, newTask);
      if (match.matchedSkills.isNotEmpty || match.totalScore >= 40) {
        final notif = AppNotification(
          id: 'notif_${_uuid.v4().substring(0, 8)}',
          recipientUserId: vol.uid,
          title: 'New Skill Match: ${newTask.title}',
          message: '${newTask.organizationName} posted a new opportunity matching ${match.matchedSkills.isNotEmpty ? match.matchedSkills.join(", ") : newTask.category} (${match.totalScore}% Match)!',
          type: 'skill_match',
          relatedTaskId: newTask.taskId,
          createdAt: DateTime.now(),
        );
        _notifications.insert(0, notif);
        try {
          await _firebaseService.sendNotification(notif);
        } catch (_) {}
      }
    }

    notifyListeners();
    return true;
  }

  Future<bool> updateTask(VolunteerTask task) async {
    if (_currentUser == null || task.organizationId != _currentUser!.uid) {
      _errorMessage = 'Unauthorized: You can only edit tasks belonging to your organization.';
      notifyListeners();
      return false;
    }

    final index = _tasks.indexWhere((t) => t.taskId == task.taskId);
    if (index != -1) {
      _tasks[index] = task;
      try {
        await _firebaseService.updateTask(task);
      } catch (e) {
        debugPrint('Firestore updateTask error: $e');
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> cancelTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.taskId == taskId);
    if (index != -1) {
      final task = _tasks[index];
      if (_currentUser == null || task.organizationId != _currentUser!.uid) {
        _errorMessage = 'Unauthorized to cancel this task.';
        notifyListeners();
        return false;
      }
      final updated = task.copyWith(status: 'cancelled');
      _tasks[index] = updated;
      try {
        await _firebaseService.updateTask(updated);
      } catch (e) {
        debugPrint('Firestore cancelTask error: $e');
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // Volunteer Task Registration (Transactional-like with Firestore sync)
  Future<String?> registerForTask(String taskId) async {
    if (_currentUser == null || !_currentUser!.isVolunteer) {
      return 'Please log in as a volunteer to register.';
    }

    final taskIndex = _tasks.indexWhere((t) => t.taskId == taskId);
    if (taskIndex == -1) return 'Task not found.';

    final task = _tasks[taskIndex];

    if (task.isCancelled) return 'This task has been cancelled.';
    if (task.isCompleted) return 'This task is already completed.';
    if (task.isRegistrationClosed) return 'Registration deadline has passed.';
    if (task.isFull) return 'Volunteer capacity reached. Task is full.';

    // Check duplicate
    final existing = _registrations.any(
      (r) => r.taskId == taskId && r.volunteerId == _currentUser!.uid && r.isRegistered,
    );
    if (existing) {
      return 'You are already registered for this task.';
    }

    // Atomic Registration
    final regId = 'reg_${task.taskId}_${_currentUser!.uid}';
    final registration = TaskRegistration(
      registrationId: regId,
      taskId: taskId,
      volunteerId: _currentUser!.uid,
      volunteerName: _currentUser!.fullName,
      volunteerEmail: _currentUser!.email,
      organizationId: task.organizationId,
      status: 'registered',
      attendanceStatus: 'pending',
      registeredAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _registrations.add(registration);
    _tasks[taskIndex] = task.copyWith(registeredCount: task.registeredCount + 1);

    try {
      await _firebaseService.registerForTask(registration);
    } catch (e) {
      debugPrint('Firestore registerForTask error: $e');
    }

    notifyListeners();
    return null; // Null indicates success
  }

  Future<bool> cancelRegistration(String registrationId) async {
    final regIdx = _registrations.indexWhere((r) => r.registrationId == registrationId);
    if (regIdx == -1) return false;

    final reg = _registrations[regIdx];
    if (_currentUser == null || reg.volunteerId != _currentUser!.uid) {
      _errorMessage = 'Unauthorized to cancel this registration.';
      notifyListeners();
      return false;
    }

    _registrations[regIdx] = reg.copyWith(status: 'cancelled');

    // Decrement count
    final taskIdx = _tasks.indexWhere((t) => t.taskId == reg.taskId);
    if (taskIdx != -1) {
      final task = _tasks[taskIdx];
      _tasks[taskIdx] = task.copyWith(
        registeredCount: (task.registeredCount - 1).clamp(0, task.volunteerLimit),
      );
    }

    try {
      await _firebaseService.cancelRegistration(registrationId, reg.taskId);
    } catch (e) {
      debugPrint('Firestore cancelRegistration error: $e');
    }

    notifyListeners();
    return true;
  }

  // Attendance and Participation Tracking (Organization privileged)
  Future<bool> updateAttendanceStatus({
    required String registrationId,
    required String attendanceStatus, // 'pending', 'attended', 'absent'
  }) async {
    final regIdx = _registrations.indexWhere((r) => r.registrationId == registrationId);
    if (regIdx == -1) return false;

    final reg = _registrations[regIdx];
    if (_currentUser == null || reg.organizationId != _currentUser!.uid) {
      _errorMessage = 'Unauthorized: Only the host organization can mark attendance.';
      notifyListeners();
      return false;
    }

    final previousStatus = reg.attendanceStatus;
    _registrations[regIdx] = reg.copyWith(attendanceStatus: attendanceStatus);

    // Award / Adjust points and verified attendance count for the volunteer
    final volIdx = _users.indexWhere((u) => u.uid == reg.volunteerId);
    int pointsDelta = 0;
    if (volIdx != -1) {
      final vol = _users[volIdx];
      int newPoints = vol.points;
      int newAttendance = vol.verifiedAttendanceCount;

      if (previousStatus != 'attended' && attendanceStatus == 'attended') {
        // Volunteer came and was marked Present: Award 50 points + 1 verified count
        pointsDelta = 50;
        newPoints += 50;
        newAttendance += 1;
      } else if (previousStatus == 'attended' && attendanceStatus != 'attended') {
        // Attendance revoked (marked absent or pending): Revert points
        pointsDelta = -50;
        newPoints = (newPoints - 50).clamp(0, 999999);
        newAttendance = (newAttendance - 1).clamp(0, 999999);
      }

      final updatedVol = vol.copyWith(
        points: newPoints,
        verifiedAttendanceCount: newAttendance,
      );
      _users[volIdx] = updatedVol;

      if (_currentUser != null && _currentUser!.uid == vol.uid) {
        _currentUser = updatedVol;
      }
    }

    try {
      await _firebaseService.updateAttendanceStatus(
        registrationId: registrationId,
        attendanceStatus: attendanceStatus,
        volunteerId: reg.volunteerId,
        pointsToAward: pointsDelta,
      );
    } catch (e) {
      debugPrint('Firestore updateAttendanceStatus error: $e');
    }

    // Send attendance notification to the volunteer
    if (previousStatus != attendanceStatus) {
      final task = getTaskById(reg.taskId);
      final taskTitle = task?.title ?? 'Service Task';

      if (attendanceStatus == 'attended') {
        _notifications.insert(
          0,
          AppNotification(
            id: 'notif_${_uuid.v4().substring(0, 8)}',
            recipientUserId: reg.volunteerId,
            title: 'Attendance Verified! +50 Points ⭐',
            message: '${_currentUser!.fullName} verified your attendance for "$taskTitle". You earned 50 points and 1 service credit!',
            type: 'attendance_present',
            pointsEarned: 50,
            relatedTaskId: reg.taskId,
            createdAt: DateTime.now(),
          ),
        );
      } else if (attendanceStatus == 'absent') {
        _notifications.insert(
          0,
          AppNotification(
            id: 'notif_${_uuid.v4().substring(0, 8)}',
            recipientUserId: reg.volunteerId,
            title: 'Attendance Notice',
            message: 'You were marked Absent for "$taskTitle". Points were not awarded.',
            type: 'attendance_absent',
            relatedTaskId: reg.taskId,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    notifyListeners();
    return true;
  }

  // Queries
  List<VolunteerTask> getOrganizationTasks(String orgId) {
    return _tasks.where((t) => t.organizationId == orgId).toList();
  }

  List<TaskRegistration> getOrganizationRegistrations(String orgId) {
    return _registrations.where((r) => r.organizationId == orgId).toList();
  }

  List<TaskRegistration> getTaskRegistrations(String taskId) {
    return _registrations.where((r) => r.taskId == taskId).toList();
  }

  List<TaskRegistration> getVolunteerRegistrations(String volunteerId) {
    return _registrations.where((r) => r.volunteerId == volunteerId).toList();
  }

  VolunteerTask? getTaskById(String taskId) {
    final matches = _tasks.where((t) => t.taskId == taskId);
    return matches.isNotEmpty ? matches.first : null;
  }

  bool isUserRegisteredForTask(String taskId) {
    if (_currentUser == null) return false;
    return _registrations.any(
      (r) => r.taskId == taskId && r.volunteerId == _currentUser!.uid && r.isRegistered,
    );
  }
}
