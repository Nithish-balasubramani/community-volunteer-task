import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task_registration.dart';
import '../../models/volunteer_task.dart';

class VolunteerQrPassSheet extends StatelessWidget {
  final TaskRegistration registration;
  final VolunteerTask task;

  const VolunteerQrPassSheet({
    super.key,
    required this.registration,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 26),
              SizedBox(width: 8),
              Text(
                'Digital Check-In Pass',
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
            'Present this QR code to the NGO coordinator at event arrival',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // High-Fidelity Custom Generated QR Code Mockup
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildQrGraphic(registration.registrationId),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PASS ID: ${registration.registrationId}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Volunteer & Event Verification Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      registration.volunteerName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.badgeGreenBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'VALID RSVP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.badgeGreenText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close Pass'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildQrGraphic(String seed) {
    // Elegant geometric QR code pattern generator
    return Container(
      width: 170,
      height: 170,
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 121, // 11x11 grid
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 11,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
            ),
            itemBuilder: (context, index) {
              final row = index ~/ 11;
              final col = index % 11;

              // QR corner position detection patterns
              final isTopLeftCorner = row <= 2 && col <= 2;
              final isTopRightCorner = row <= 2 && col >= 8;
              final isBottomLeftCorner = row >= 8 && col <= 2;

              final isPositionPattern = isTopLeftCorner || isTopRightCorner || isBottomLeftCorner;

              // Deterministic fill based on seed and coordinate
              final fill = isPositionPattern || ((row * 7 + col * 13 + seed.hashCode) % 3 != 0);

              return Container(
                decoration: BoxDecoration(
                  color: fill ? const Color(0xFF1E293B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(isPositionPattern ? 1.5 : 1),
                ),
              );
            },
          ),
          // Center App Logo Stamp
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
