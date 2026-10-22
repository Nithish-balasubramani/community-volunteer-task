import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../services/app_state_provider.dart';
import '../../core/constants/app_skills.dart';
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final List<String> _selectedSkills = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppStateProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phone ?? '';
      _locationController.text = user.preferredLocation ?? '';
      _selectedSkills.addAll(user.skills);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final provider = context.read<AppStateProvider>();
    await provider.updateProfile(
      fullName: _nameController.text,
      phone: _phoneController.text,
      preferredLocation: _locationController.text,
      skills: _selectedSkills,
    );
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final user = provider.currentUser;

    if (user == null) {
      return const Center(child: Text('Not logged in.'));
    }

    final myRegistrations = provider.getVolunteerRegistrations(user.uid);
    final completedCount = myRegistrations.where((r) => r.isAttended).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Volunteer Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Name Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'V',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${user.points} Service Points',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.badgeGreenBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$completedCount Verified Events',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.badgeGreenText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Fields / Editing
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact & Campus Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    readOnly: !_isEditing,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    readOnly: !_isEditing,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _locationController,
                    label: 'Preferred Location / Campus Area',
                    readOnly: !_isEditing,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Skills & Availability (Chips)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Matched Skills',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                      if (_isEditing)
                        Text(
                          '${_selectedSkills.length} selected',
                          style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_isEditing)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: AppSkills.all.map((s) {
                        final isSelected = _selectedSkills.contains(s);
                        return FilterChip(
                          label: Text(s, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          selectedColor: AppColors.primaryLight,
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedSkills.add(s);
                              } else {
                                _selectedSkills.remove(s);
                              }
                            });
                          },
                        );
                      }).toList(),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: user.skills.isEmpty
                          ? [
                              const Text(
                                'No skills added yet. Tap edit above to choose your skills!',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              )
                            ]
                          : user.skills.map((s) {
                              return Chip(
                                label: Text(s, style: const TextStyle(fontSize: 12)),
                                backgroundColor: AppColors.primaryLight,
                                labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                              );
                            }).toList(),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Weekly Availability',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: user.availabilityDays.map((d) {
                      return Chip(
                        label: Text(d, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.secondaryLight,
                        labelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout & Settings
            OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: () {
                provider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
