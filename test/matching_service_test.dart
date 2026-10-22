import 'package:flutter_test/flutter_test.dart';
import 'package:volunteerconnect/models/app_user.dart';
import 'package:volunteerconnect/models/volunteer_task.dart';
import 'package:volunteerconnect/services/matching_service.dart';

void main() {
  group('MatchingService Rule-Based Engine Tests', () {
    late AppUser volunteer;
    late VolunteerTask gardeningTask;

    setUp(() {
      // Alex Chen with Gardening skill and Sunday availability
      volunteer = AppUser(
        uid: 'vol_01',
        fullName: 'Alex Chen',
        email: 'alex@test.com',
        role: 'volunteer',
        skills: ['Gardening', 'Tree Planting', 'Teamwork'],
        interests: ['Environment', 'Community Service'],
        availabilityDays: ['Sunday'],
        availabilityTimeSlots: ['Morning'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sunday Morning Tree Plantation task
      final now = DateTime.now();
      final daysUntilSunday = (DateTime.sunday - now.weekday + 7) % 7;
      final nextSunday = now.add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));

      gardeningTask = VolunteerTask(
        taskId: 'task_01',
        organizationId: 'org_01',
        organizationName: 'GreenEarth Foundation',
        title: 'Community Tree Plantation Drive',
        description: 'Planting trees in the park',
        category: 'Environment',
        requiredSkills: ['Gardening', 'Tree Planting'],
        eventDate: nextSunday,
        startTime: '09:00 AM',
        endTime: '01:00 PM',
        location: 'Riverfront Park',
        volunteerLimit: 20,
        registeredCount: 5,
        registrationDeadline: nextSunday.subtract(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('Full match calculates 100 points when skills, category, and availability align', () {
      final result = MatchingService.calculateMatch(volunteer, gardeningTask);
      expect(result.totalScore, 100);
      expect(result.skillScore, 50);
      expect(result.interestScore, 25);
      expect(result.availabilityScore, 25);
      expect(result.matchedSkills, contains('Gardening'));
      expect(result.isCategoryMatched, isTrue);
      expect(result.isAvailabilityMatched, isTrue);
      expect(result.explanation, contains('Gardening'));
      expect(result.explanation, contains('Sunday availability'));
    });

    test('Handles empty volunteer profile safely without errors', () {
      final emptyVolunteer = AppUser(
        uid: 'vol_empty',
        fullName: 'Empty User',
        email: 'empty@test.com',
        role: 'volunteer',
        skills: [],
        interests: [],
        availabilityDays: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = MatchingService.calculateMatch(emptyVolunteer, gardeningTask);
      expect(result.totalScore, 0);
      expect(result.skillScore, 0);
      expect(result.interestScore, 0);
      expect(result.availabilityScore, 0);
      expect(result.explanation, isNotEmpty);
    });

    test('Availability mismatch produces 0 availability points', () {
      // Volunteer only available on Wednesday
      final wednesdayVolunteer = volunteer.copyWith(
        availabilityDays: ['Wednesday'],
      );

      final result = MatchingService.calculateMatch(wednesdayVolunteer, gardeningTask);
      expect(result.availabilityScore, 0);
      expect(result.totalScore, 75); // 50 (skills) + 25 (interest) + 0 (avail)
    });
  });
}
