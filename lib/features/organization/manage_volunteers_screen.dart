import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/volunteer_task.dart';
import '../../services/app_state_provider.dart';

class ManageVolunteersScreen extends StatelessWidget {
  final VolunteerTask task;

  const ManageVolunteersScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final registrations = provider.getTaskRegistrations(task.taskId);
    final confirmedRegs = registrations.where((r) => r.isRegistered).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Volunteers & Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
            tooltip: 'Verify Check-In QR Pass',
            onPressed: () {
              _showQrScannerDialog(context, provider, confirmedRegs);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${DateFormat('EEE, MMM d, yyyy').format(task.eventDate)} • ${task.startTime}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${confirmedRegs.length} / ${task.volunteerLimit} Spots Filled',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${task.availableSlots} Available',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Registered Volunteers Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Registered Volunteers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  '${confirmedRegs.length} Registered',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Verify attendance after the service activity. Marking Present awards +50 points to boost the volunteer\'s future matching recommendations.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),

            if (confirmedRegs.isEmpty)
              _buildEmptyVolunteers()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: confirmedRegs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (ctx, idx) {
                  final reg = confirmedRegs[idx];
                  final isAttended = reg.attendanceStatus == 'attended';
                  final isAbsent = reg.attendanceStatus == 'absent';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isAttended
                            ? AppColors.success.withValues(alpha: 0.5)
                            : AppColors.outline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                reg.volunteerName.isNotEmpty
                                    ? reg.volunteerName[0].toUpperCase()
                                    : 'V',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reg.volunteerName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                  if (reg.volunteerEmail != null) ...[
                                    Text(
                                      reg.volunteerEmail!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAttended
                                    ? AppColors.badgeGreenBg
                                    : isAbsent
                                        ? AppColors.surfaceVariant
                                        : AppColors.badgeOrangeBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isAttended
                                    ? 'PRESENT (+50 PTS)'
                                    : isAbsent
                                        ? 'ABSENT'
                                        : 'PENDING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isAttended
                                      ? AppColors.badgeGreenText
                                      : isAbsent
                                          ? AppColors.textSecondary
                                          : AppColors.badgeOrangeText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.outline, height: 1),
                        const SizedBox(height: 10),

                        // Mark attendance buttons
                        Row(
                          children: [
                            const Text(
                              'Attendance:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            ChoiceChip(
                              label: const Text('Present', style: TextStyle(fontSize: 11)),
                              selected: isAttended,
                              selectedColor: AppColors.badgeGreenBg,
                              onSelected: (val) {
                                provider.updateAttendanceStatus(
                                  registrationId: reg.registrationId,
                                  attendanceStatus: val ? 'attended' : 'pending',
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              label: const Text('Absent', style: TextStyle(fontSize: 11)),
                              selected: isAbsent,
                              selectedColor: AppColors.surfaceVariant,
                              onSelected: (val) {
                                provider.updateAttendanceStatus(
                                  registrationId: reg.registrationId,
                                  attendanceStatus: val ? 'absent' : 'pending',
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showQrScannerDialog(
    BuildContext context,
    AppStateProvider provider,
    List<dynamic> registrations,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Scan & Verify Check-In Pass',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Verify arrival of registered volunteers to award attendance credits and +50 points.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Mock Scanner Camera Viewfinder
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const Positioned(
                      bottom: 12,
                      child: Text(
                        'Align Volunteer Pass QR Inside Frame',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Or Quick Verify by Registered Name:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 10),

              if (registrations.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No registered volunteers for this task.'),
                )
              else
                ...registrations.map(
                  (reg) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reg.volunteerName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        if (reg.attendanceStatus == 'attended')
                          const Text(
                            'PRESENT (+50 PTS)',
                            style: TextStyle(
                              color: AppColors.badgeGreenText,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: const Size(60, 32),
                            ),
                            onPressed: () {
                              provider.updateAttendanceStatus(
                                registrationId: reg.registrationId,
                                attendanceStatus: 'attended',
                              );
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Verified ${reg.volunteerName}! +50 Points awarded.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            child: const Text('Verify Pass', style: TextStyle(fontSize: 11)),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyVolunteers() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.person_search_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 10),
          const Text(
            'No volunteers have registered for this task yet.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
