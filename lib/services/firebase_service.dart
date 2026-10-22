import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/volunteer_task.dart';
import '../models/task_registration.dart';
import '../models/app_notification.dart';

class FirebaseService {
  bool get isFirebaseInitialized => Firebase.apps.isNotEmpty;

  FirebaseAuth? get auth {
    if (!isFirebaseInitialized) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get firestore {
    if (!isFirebaseInitialized) return null;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Stream current auth state
  Stream<User?> get authStateChanges =>
      isFirebaseInitialized && auth != null ? auth!.authStateChanges() : const Stream.empty();

  // 1. Email & Password Authentication
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    if (!isFirebaseInitialized || auth == null) return null;
    return await auth!.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ).timeout(const Duration(seconds: 10));
  }

  Future<UserCredential?> registerWithEmailPassword(String email, String password) async {
    if (!isFirebaseInitialized || auth == null) return null;
    return await auth!.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ).timeout(const Duration(seconds: 10));
  }

  Future<void> signOut() async {
    if (isFirebaseInitialized && auth != null) {
      await auth!.signOut();
    }
  }

  // 2. User Document Management in Firestore
  Future<void> saveUser(AppUser user) async {
    if (!isFirebaseInitialized || firestore == null) return;
    await firestore!.collection('users').doc(user.uid).set(
      user.toMap(),
      SetOptions(merge: true),
    ).timeout(const Duration(seconds: 8));
  }

  Future<AppUser?> getUser(String uid) async {
    if (!isFirebaseInitialized || firestore == null) return null;
    try {
      final doc = await firestore!.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Firestore getUser error: $e');
    }
    return null;
  }

  Future<List<AppUser>> fetchAllUsers() async {
    if (!isFirebaseInitialized || firestore == null) return [];
    try {
      final snapshot = await firestore!.collection('users').get();
      return snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Firestore fetchAllUsers error: $e');
      return [];
    }
  }

  // 3. Tasks Management
  Stream<List<VolunteerTask>> streamTasks() {
    if (!isFirebaseInitialized || firestore == null) return const Stream.empty();
    return firestore!
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => VolunteerTask.fromMap(doc.data())).toList());
  }

  Future<List<VolunteerTask>> fetchTasks() async {
    if (!isFirebaseInitialized || firestore == null) return [];
    try {
      final snapshot = await firestore!.collection('tasks').get();
      return snapshot.docs.map((doc) => VolunteerTask.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Firestore fetchTasks error: $e');
      return [];
    }
  }

  Future<void> createTask(VolunteerTask task) async {
    if (!isFirebaseInitialized || firestore == null) return;
    await firestore!.collection('tasks').doc(task.taskId).set(task.toMap());
  }

  Future<void> updateTask(VolunteerTask task) async {
    if (!isFirebaseInitialized || firestore == null) return;
    await firestore!.collection('tasks').doc(task.taskId).update(task.toMap());
  }

  // 4. Registrations & Attendance
  Future<List<TaskRegistration>> fetchRegistrations() async {
    if (!isFirebaseInitialized || firestore == null) return [];
    try {
      final snapshot = await firestore!.collection('registrations').get();
      return snapshot.docs.map((doc) => TaskRegistration.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Firestore fetchRegistrations error: $e');
      return [];
    }
  }

  Future<void> registerForTask(TaskRegistration reg) async {
    if (!isFirebaseInitialized || firestore == null) return;
    await firestore!.collection('registrations').doc(reg.registrationId).set(reg.toMap());
    await firestore!.collection('tasks').doc(reg.taskId).update({
      'registeredCount': FieldValue.increment(1),
    });
  }

  Future<void> cancelRegistration(String registrationId, String taskId) async {
    if (!isFirebaseInitialized || firestore == null) return;
    await firestore!.collection('registrations').doc(registrationId).update({
      'status': 'cancelled',
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await firestore!.collection('tasks').doc(taskId).update({
      'registeredCount': FieldValue.increment(-1),
    });
  }

  Future<void> updateAttendanceStatus({
    required String registrationId,
    required String attendanceStatus,
    required String volunteerId,
    required int pointsToAward,
  }) async {
    if (!isFirebaseInitialized || firestore == null) return;
    await firestore!.collection('registrations').doc(registrationId).update({
      'attendanceStatus': attendanceStatus,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    if (pointsToAward != 0) {
      await firestore!.collection('users').doc(volunteerId).update({
        'points': FieldValue.increment(pointsToAward),
        'verifiedAttendanceCount': FieldValue.increment(attendanceStatus == 'attended' ? 1 : 0),
      });
    }
  }

  // 5. Notifications
  Future<void> sendNotification(AppNotification notification) async {
    if (!isFirebaseInitialized || firestore == null) return;
    await firestore!.collection('notifications').doc(notification.id).set(notification.toMap());
  }

  Stream<List<AppNotification>> streamUserNotifications(String userId) {
    if (!isFirebaseInitialized || firestore == null) return const Stream.empty();
    return firestore!
        .collection('notifications')
        .where('recipientUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AppNotification.fromMap(doc.data())).toList());
  }
}
