import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/volunteer_task.dart';
import '../../services/app_state_provider.dart';
import 'create_task_screen.dart';
import 'manage_volunteers_screen.dart';
import '../auth/welcome_screen.dart';

class OrganizationDashboard extends StatefulWidget {
  const OrganizationDashboard({super.key});

  @override
  State<OrganizationDashboard> createState() => _OrganizationDashboardState();
}

class _OrganizationDashboardState extends State<OrganizationDashboard> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final org = provider.currentUser;

    if (org == null || !org.isOrganization) {
      return const Scaffold(
        body: Center(child: Text('Unauthorized: Organization access only.')),
      );
    }

    final orgTasks = provider.getOrganizationTasks(org.uid);
    final activeTasks = orgTasks.where((t) => t.status == 'active').toList();
    final orgRegistrations = provider.getOrganizationRegistrations(org.uid);
    final totalVolunteers = orgRegistrations.where((r) => r.isRegistered).length;
    final attendedCount = orgRegistrations.where((r) => r.isAttended).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              org.fullName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const Text(
              'Organization Partner Portal',
              style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () {
              provider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
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
            // KPI Summary Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Active Events',
                    '${activeTasks.length}',
                    Icons.event,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Registrations',
                    '$totalVolunteers',
                    Icons.group,
                    AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Attended',
                    '$attendedCount',
                    Icons.verified_user,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions: Create Task
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text('Create New Volunteer Opportunity'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
                );
              },
            ),
            const SizedBox(height: 28),

            // Published Tasks Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Published Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  '${orgTasks.length} Total',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (orgTasks.isEmpty)
              _buildEmptyOrgState()
            else
              ...orgTasks.map((task) => _buildOrgTaskCard(context, provider, task)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrgTaskCard(
      BuildContext context, AppStateProvider provider, VolunteerTask task) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final registrations = provider.getTaskRegistrations(task.taskId);
    final confirmedRegs = registrations.where((r) => r.isRegistered).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: task.isCancelled
                      ? AppColors.surfaceVariant
                      : AppColors.badgeTealBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.isCancelled ? 'CANCELLED' : task.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: task.isCancelled
                        ? AppColors.textSecondary
                        : AppColors.badgeTealText,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$confirmedRegs / ${task.volunteerLimit} Volunteers Registered',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            task.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            '${dateFormat.format(task.eventDate)} • ${task.startTime}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Location: ${task.location}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          // Action Buttons: Manage Volunteers (Attendance) & Edit/Cancel
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.people, size: 16),
                  label: Text('Manage RSVPs ($confirmedRegs)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ManageVolunteersScreen(task: task),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (!task.isCancelled) ...[
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                  tooltip: 'Cancel Task',
                  onPressed: () => _confirmCancelTask(context, provider, task.taskId),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmCancelTask(
      BuildContext context, AppStateProvider provider, String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Volunteer Opportunity?'),
        content: const Text(
            'Are you sure you want to cancel this event? Registered volunteers will be notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await provider.cancelTask(taskId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task cancelled.')),
                );
              }
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrgState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text(
              'You haven\'t published any volunteer tasks yet.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
