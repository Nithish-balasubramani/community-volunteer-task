import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task_registration.dart';
import '../../services/app_state_provider.dart';
import '../tasks/task_detail_screen.dart';
import 'volunteer_qr_pass_sheet.dart';

class MyActivitiesScreen extends StatefulWidget {
  const MyActivitiesScreen({super.key});

  @override
  State<MyActivitiesScreen> createState() => _MyActivitiesScreenState();
}

class _MyActivitiesScreenState extends State<MyActivitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final user = provider.currentUser;

    if (user == null) {
      return const Center(child: Text('Please log in to view activities.'));
    }

    final registrations = provider.getVolunteerRegistrations(user.uid);
    final upcomingRegs = registrations
        .where((r) => r.isRegistered && r.attendanceStatus == 'pending')
        .toList();
    final completedRegs = registrations
        .where((r) => r.attendanceStatus == 'attended')
        .toList();
    final cancelledRegs = registrations
        .where((r) => r.isCancelled || r.attendanceStatus == 'absent')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Volunteer Activities'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Upcoming (${upcomingRegs.length})'),
            Tab(text: 'Completed (${completedRegs.length})'),
            Tab(text: 'Past (${cancelledRegs.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivityList(context, provider, upcomingRegs, isUpcoming: true),
          _buildActivityList(context, provider, completedRegs, isCompleted: true),
          _buildActivityList(context, provider, cancelledRegs, isCancelled: true),
        ],
      ),
    );
  }

  Widget _buildActivityList(
    BuildContext context,
    AppStateProvider provider,
    List<TaskRegistration> list, {
    bool isUpcoming = false,
    bool isCompleted = false,
    bool isCancelled = false,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUpcoming
                    ? Icons.event_available_outlined
                    : isCompleted
                        ? Icons.military_tech_outlined
                        : Icons.history,
                size: 54,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 14),
              Text(
                isUpcoming
                    ? 'No upcoming volunteer commitments.'
                    : isCompleted
                        ? 'No completed tasks yet. Attend registered events to earn credit!'
                        : 'No cancelled or past records.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (ctx, idx) {
        final reg = list[idx];
        final task = provider.getTaskById(reg.taskId);

        if (task == null) return const SizedBox.shrink();

        final dateFormat = DateFormat('EEE, MMM d, yyyy');

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.badgeGreenBg
                          : isCancelled
                              ? AppColors.surfaceVariant
                              : AppColors.badgeBlueBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isCompleted
                          ? 'ATTENDANCE CONFIRMED (+3 hrs)'
                          : isCancelled
                              ? (reg.isCancelled ? 'CANCELLED' : 'ABSENT')
                              : 'CONFIRMED REGISTRATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isCompleted
                            ? AppColors.badgeGreenText
                            : isCancelled
                                ? AppColors.textSecondary
                                : AppColors.badgeBlueText,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Reg: ${DateFormat('MMM d').format(reg.registeredAt)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                task.organizationName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),

              // Date & Location
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${dateFormat.format(task.eventDate)} • ${task.startTime}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      task.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Action buttons (Check-in QR Pass and View/Cancel)
              Row(
                children: [
                  if (isUpcoming) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(125, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                      label: const Text('Check-In Pass', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => VolunteerQrPassSheet(
                            registration: reg,
                            task: task,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(90, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TaskDetailScreen(taskId: task.taskId),
                        ),
                      );
                    },
                    child: const Text('View', style: TextStyle(fontSize: 12)),
                  ),
                  const Spacer(),
                  if (isUpcoming) ...[
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => _showCancelDialog(context, provider, reg.registrationId),
                      child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelDialog(
      BuildContext context, AppStateProvider provider, String registrationId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Registration?'),
        content: const Text(
            'Are you sure you want to cancel your spot? This will make the slot available for other volunteers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Spot'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await provider.cancelRegistration(registrationId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registration cancelled successfully.')),
                );
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
