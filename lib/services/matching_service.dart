import 'package:intl/intl.dart';
import '../models/app_user.dart';
import '../models/volunteer_task.dart';

class MatchResult {
  final int totalScore; // 0 to 100
  final int skillScore; // 0 to 50
  final int interestScore; // 0 to 25
  final int availabilityScore; // 0 to 25
  final int pointsBoost; // Reputation boost from earned attendance points
  final String explanation;
  final List<String> matchedSkills;
  final bool isCategoryMatched;
  final bool isAvailabilityMatched;

  MatchResult({
    required this.totalScore,
    required this.skillScore,
    required this.interestScore,
    required this.availabilityScore,
    this.pointsBoost = 0,
    required this.explanation,
    required this.matchedSkills,
    required this.isCategoryMatched,
    required this.isAvailabilityMatched,
  });
}

class MatchingService {
  /// Transparent rule-based matching engine according to specifications:
  /// Maximum Score: 100
  /// - Skills compatibility: up to 50 points
  /// - Interests / Category compatibility: up to 25 points
  /// - Availability compatibility: up to 25 points
  static MatchResult calculateMatch(AppUser volunteer, VolunteerTask task) {
    if (volunteer.role != 'volunteer') {
      return MatchResult(
        totalScore: 0,
        skillScore: 0,
        interestScore: 0,
        availabilityScore: 0,
        explanation: 'Only volunteers can be matched to tasks.',
        matchedSkills: [],
        isCategoryMatched: false,
        isAvailabilityMatched: false,
      );
    }

    // 1. Skill Compatibility (Max 50 points)
    int skillScore = 0;
    final List<String> matchedSkills = [];
    final vSkillsLower = volunteer.skills.map((s) => s.trim().toLowerCase()).toList();

    if (task.requiredSkills.isEmpty) {
      // General task: no specific skills needed, award full 50
      skillScore = 50;
    } else {
      for (final reqSkill in task.requiredSkills) {
        final reqLower = reqSkill.trim().toLowerCase();
        if (vSkillsLower.contains(reqLower)) {
          matchedSkills.add(reqSkill);
        }
      }

      if (matchedSkills.isNotEmpty) {
        final ratio = matchedSkills.length / task.requiredSkills.length;
        skillScore = (ratio * 50).round().clamp(0, 50);
      }
    }

    // 2. Interests / Category Compatibility (Max 25 points)
    int interestScore = 0;
    bool isCategoryMatched = false;
    final taskCategoryLower = task.category.trim().toLowerCase();
    final vInterestsLower = volunteer.interests.map((i) => i.trim().toLowerCase()).toList();

    if (vInterestsLower.contains(taskCategoryLower)) {
      interestScore = 25;
      isCategoryMatched = true;
    } else {
      // Partial match if interest contains category or vice versa
      final partial = vInterestsLower.any((i) =>
          i.contains(taskCategoryLower) || taskCategoryLower.contains(i));
      if (partial) {
        interestScore = 15;
        isCategoryMatched = true;
      }
    }

    // 3. Availability Compatibility (Max 25 points)
    // Compare volunteer's available days with task event date day of week
    int availabilityScore = 0;
    bool isAvailabilityMatched = false;
    final eventDayName = DateFormat('EEEE').format(task.eventDate); // e.g. "Sunday"
    final vDaysLower = volunteer.availabilityDays.map((d) => d.trim().toLowerCase()).toList();

    if (vDaysLower.contains(eventDayName.toLowerCase())) {
      isAvailabilityMatched = true;
      // Also check time slot if available
      final taskStartLower = task.startTime.toLowerCase();
      bool timeMatched = false;

      final isTaskMorning = taskStartLower.contains('am') || taskStartLower.contains('08:') || taskStartLower.contains('09:') || taskStartLower.contains('10:') || taskStartLower.contains('11:');
      
      for (final slot in volunteer.availabilityTimeSlots) {
        final slotLower = slot.toLowerCase();
        if (isTaskMorning && slotLower.contains('morning')) {
          timeMatched = true;
          break;
        } else if (!isTaskMorning && (slotLower.contains('afternoon') || slotLower.contains('evening'))) {
          timeMatched = true;
          break;
        }
      }

      if (volunteer.availabilityTimeSlots.isEmpty || timeMatched) {
        availabilityScore = 25;
      } else {
        availabilityScore = 15; // Day matches, time slot not explicitly matched
      }
    } else {
      availabilityScore = 0; // Out of availability
    }

    // 4. Points & Attendance Track Record Boost (Up to 15 points bonus)
    // Volunteers who regularly attend and earn points receive higher priority recommendations
    final pointsBoost = (volunteer.points / 20).floor().clamp(0, 15);

    final rawScore = skillScore + interestScore + availabilityScore + pointsBoost;
    final totalScore = rawScore.clamp(0, 100);

    // Build human-readable explanation
    final explanations = <String>[];
    if (matchedSkills.isNotEmpty) {
      explanations.add('your ${matchedSkills.join(", ")} skills');
    }
    if (isCategoryMatched) {
      explanations.add('${task.category} interest');
    }
    if (isAvailabilityMatched) {
      explanations.add('$eventDayName availability');
    }
    if (pointsBoost > 0) {
      explanations.add('your verified attendance points (+${pointsBoost}pts boost)');
    }

    String explanation;
    if (explanations.isNotEmpty) {
      explanation = 'Recommended because ${explanations.join(" and ")} match this task.';
    } else {
      explanation = 'Available community opportunity that welcomes all participants.';
    }

    return MatchResult(
      totalScore: totalScore,
      skillScore: skillScore,
      interestScore: interestScore,
      availabilityScore: availabilityScore,
      pointsBoost: pointsBoost,
      explanation: explanation,
      matchedSkills: matchedSkills,
      isCategoryMatched: isCategoryMatched,
      isAvailabilityMatched: isAvailabilityMatched,
    );
  }
}
