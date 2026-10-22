import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/volunteer_task.dart';
import '../../services/app_state_provider.dart';
import '../../services/matching_service.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final task = provider.getTaskById(taskId);
    final currentUser = provider.currentUser;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: Text('Task not found or has been removed.')),
      );
    }

    final isRegistered = provider.isUserRegisteredForTask(taskId);
    final matchResult = currentUser != null && currentUser.isVolunteer
        ? MatchingService.calculateMatch(currentUser, task)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task link copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category & Status Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.badgeTealBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.badgeTealText,
                    ),
                  ),
                ),
                const Spacer(),
                if (matchResult != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.badgeGreenBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified,
                            color: AppColors.badgeGreenText, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          '${matchResult.totalScore}% Match',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.badgeGreenText,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Organization Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.business, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.organizationName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                        const Text(
                          'Verified Community Partner',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Match Explanation Box (if high recommendation)
            if (matchResult != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Smart Match Breakdown',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      matchResult.explanation,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _scorePill('Skills', '${matchResult.skillScore}/50'),
                        _scorePill('Interests', '${matchResult.interestScore}/25'),
                        _scorePill('Availability', '${matchResult.availabilityScore}/25'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Event Details Grid
            _buildDetailRow(
              Icons.calendar_month,
              'Date & Time',
              '${task.eventDate.year}-${task.eventDate.month.toString().padLeft(2, '0')}-${task.eventDate.day.toString().padLeft(2, '0')} (${task.startTime} – ${task.endTime})',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.location_on_outlined,
              'Event Location',
              task.location,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.people_alt_outlined,
              'Volunteer Capacity',
              '${task.registeredCount} / ${task.volunteerLimit} spots filled (${task.availableSlots} available)',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.timer_outlined,
              'Registration Deadline',
              '${task.registrationDeadline.year}-${task.registrationDeadline.month.toString().padLeft(2, '0')}-${task.registrationDeadline.day.toString().padLeft(2, '0')}',
            ),

            const SizedBox(height: 22),
            const Divider(color: AppColors.outline),
            const SizedBox(height: 16),

            // Description
            const Text(
              'About This Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Required Skills
            const Text(
              'Required / Helpful Skills',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.requiredSkills.map((skill) {
                final isVolunteerSkill = currentUser?.skills.contains(skill) ?? false;
                return Chip(
                  label: Text(skill),
                  avatar: isVolunteerSkill
                      ? const Icon(Icons.check_circle, size: 16, color: AppColors.primary)
                      : null,
                  backgroundColor: isVolunteerSkill
                      ? AppColors.primaryLight
                      : AppColors.surfaceVariant,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isVolunteerSkill ? FontWeight.w700 : FontWeight.w500,
                    color: isVolunteerSkill ? AppColors.primary : AppColors.textMain,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.outline)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: _buildBottomActionButton(context, provider, task, isRegistered),
        ),
      ),
    );
  }

  Widget _scorePill(String label, String score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        '$label: $score',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMain,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButton(
    BuildContext context,
    AppStateProvider provider,
    VolunteerTask task,
    bool isRegistered,
  ) {
    if (provider.currentUser == null) {
      return ElevatedButton(
        onPressed: () {},
        child: const Text('Sign in to Register'),
      );
    }

    if (provider.currentUser!.isOrganization) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceVariant,
          foregroundColor: AppColors.textSecondary,
        ),
        onPressed: null,
        child: const Text('Viewing as Organization'),
      );
    }

    if (isRegistered) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.badgeGreenBg,
          foregroundColor: AppColors.badgeGreenText,
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are already registered! Check My Activities.'),
              backgroundColor: AppColors.success,
            ),
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 20),
            SizedBox(width: 8),
            Text('Already Registered'),
          ],
        ),
      );
    }

    if (task.isFull) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceVariant,
          foregroundColor: AppColors.textMuted,
        ),
        onPressed: null,
        child: const Text('Event is Full (Waitlist Closed)'),
      );
    }

    if (task.isRegistrationClosed) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceVariant,
          foregroundColor: AppColors.textMuted,
        ),
        onPressed: null,
        child: const Text('Registration Closed'),
      );
    }

    return ElevatedButton.icon(
      icon: const Icon(Icons.touch_app_rounded, size: 20),
      onPressed: () async {
        final error = await provider.registerForTask(task.taskId);
        if (context.mounted) {
          if (error == null) {
            _showSuccessRegistrationDialog(context, task);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      label: const Text('Interested / Register for Work'),
    );
  }

  void _showSuccessRegistrationDialog(BuildContext context, VolunteerTask task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.badgeGreenBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Registration Confirmed!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are registered for "${task.title}". The organization has been notified.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
