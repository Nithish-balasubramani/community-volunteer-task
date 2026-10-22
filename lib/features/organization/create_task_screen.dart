import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../services/app_state_provider.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController(text: '15');
  final _startTimeController = TextEditingController(text: '09:00 AM');
  final _endTimeController = TextEditingController(text: '01:00 PM');

  String _selectedCategory = 'Environment';
  DateTime _eventDate = DateTime.now().add(const Duration(days: 7));
  DateTime _registrationDeadline = DateTime.now().add(const Duration(days: 6));

  final List<String> _categories = [
    'Environment',
    'Education',
    'Community',
    'Health',
    'Animal Care',
    'Elderly Support',
  ];

  final List<String> _selectedSkills = [];
  final List<String> _availableSkills = [
    'Gardening',
    'Tree Planting',
    'First Aid',
    'Teamwork',
    'Event Setup',
    'Cooking',
    'Organization',
    'Public Speaking',
    'Fundraising',
    'Counseling',
    'Animal Care',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _submitTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one required or helpful skill.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final capacity = int.tryParse(_capacityController.text.trim()) ?? 10;
    if (capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capacity must be a positive number.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = context.read<AppStateProvider>();
    final success = await provider.createTask(
      title: _titleController.text,
      description: _descController.text,
      category: _selectedCategory,
      requiredSkills: _selectedSkills,
      eventDate: _eventDate,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      location: _locationController.text,
      volunteerLimit: capacity,
      registrationDeadline: _registrationDeadline,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task published! Skill-matched volunteers will receive instant recommendations.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to create task'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickEventDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() {
        _eventDate = picked;
        // Adjust deadline to be before or on event date
        if (_registrationDeadline.isAfter(picked)) {
          _registrationDeadline = picked.subtract(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _pickDeadlineDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _registrationDeadline,
      firstDate: DateTime.now(),
      lastDate: _eventDate,
    );
    if (picked != null) {
      setState(() => _registrationDeadline = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Volunteer Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Publish an activity to recruit enthusiastic student volunteers.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _titleController,
                label: 'Task Title',
                hint: 'e.g. Tree Plantation Drive at Riverfront Park',
                prefixIcon: Icons.title,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Category dropdown
              const Text(
                'Category / Cause',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined,
                      color: AppColors.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descController,
                label: 'Description & Scope of Work',
                hint: 'What will volunteers do? Are tools provided? Any safety tips?',
                maxLines: 4,
                prefixIcon: Icons.description_outlined,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _locationController,
                label: 'Location / Venue Address',
                hint: 'e.g. Sector 4, Riverfront Park Gate 3',
                prefixIcon: Icons.place_outlined,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Location is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Date pickers row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Event Date',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickEventDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    dateFormat.format(_eventDate),
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RSVP Deadline',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDeadlineDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined,
                                    size: 16, color: AppColors.warning),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    dateFormat.format(_registrationDeadline),
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time & Volunteer Capacity
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _startTimeController,
                      label: 'Start Time',
                      hint: '09:00 AM',
                      prefixIcon: Icons.schedule,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _endTimeController,
                      label: 'End Time',
                      hint: '01:00 PM',
                      prefixIcon: Icons.schedule_send,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _capacityController,
                      label: 'Max Spots',
                      hint: '15',
                      prefixIcon: Icons.group_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || int.tryParse(val.trim()) == null) {
                          return 'Number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Required Skills
              const Text(
                'Required / Matching Skills',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'The matching engine will recommend this task to volunteers with these skills.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSkills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: isSelected,
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textMain,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSkills.add(skill);
                        } else {
                          _selectedSkills.remove(skill);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submitTask,
                child: const Text('Publish Volunteer Opportunity'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
