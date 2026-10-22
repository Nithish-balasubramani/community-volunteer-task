import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/task_card.dart';
import '../../services/app_state_provider.dart';
import '../../services/matching_service.dart';
import '../tasks/task_detail_screen.dart';
import '../activities/my_activities_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../leaderboard/leaderboard_screen.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Environment',
    'Education',
    'Community',
    'Health',
    'Animal Care',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();

    final pages = [
      _buildHomeTab(context, provider),
      _buildExploreTab(context, provider),
      const LeaderboardScreen(),
      const MyActivitiesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() => _currentIndex = idx);
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppColors.primary),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard, color: AppColors.primary),
            label: 'Rankings',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: AppColors.primary),
            label: 'My Activities',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, AppStateProvider provider) {
    final user = provider.currentUser;
    final allTasks = provider.allTasks.where((t) => t.status == 'active').toList();
    final myRegs = user != null ? provider.getVolunteerRegistrations(user.uid) : [];
    final completedCount = myRegs.where((r) => r.isAttended).length;
    final upcomingCount = myRegs.where((r) => r.isRegistered && !r.isAttended).length;

    // Calculate match recommendations
    final matchedList = allTasks.map((t) {
      final match = user != null ? MatchingService.calculateMatch(user, t) : null;
      return MapEntry(t, match);
    }).toList();

    // Sort by match score descending
    matchedList.sort((a, b) {
      final scoreA = a.value?.totalScore ?? 0;
      final scoreB = b.value?.totalScore ?? 0;
      return scoreB.compareTo(scoreA);
    });

    final recommendedTasks = matchedList.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'V',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.fullName.split(" ").first ?? "Volunteer"} 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ready to make an impact today?',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context) {
                  final unread = user != null ? provider.getUnreadNotificationCount(user.uid) : 0;
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, size: 26, color: AppColors.textMain),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          );
                        },
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$unread',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Volunteer Service Stats Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Points', '${user?.points ?? 0}', Icons.stars_rounded),
                _statDivider(),
                _buildStatItem('Attended', '$completedCount', Icons.verified),
                _statDivider(),
                _buildStatItem('Upcoming', '$upcomingCount', Icons.event_available),
                _statDivider(),
                _buildStatItem('Hours', '${completedCount * 3}', Icons.schedule),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recommended Tasks Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recommended for Your Skills',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _currentIndex = 1); // Switch to Explore
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Smart matching based on your registered skills, availability & interests',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          // Recommended Task List
          if (recommendedTasks.isEmpty)
            _buildEmptyState('No active tasks currently available.')
          else
            ...recommendedTasks.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: TaskCard(
                  task: item.key,
                  matchResult: item.value,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(taskId: item.key.taskId),
                      ),
                    );
                  },
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Category Quick Filter
          const Text(
            'Explore by Cause',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (ctx, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMain,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = cat;
                      _currentIndex = 1; // jump to explore with category
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreTab(BuildContext context, AppStateProvider provider) {
    final user = provider.currentUser;
    final allTasks = provider.allTasks.where((t) {
      if (t.status == 'cancelled') return false;
      if (_selectedCategory != 'All' && t.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explore Opportunities',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (ctx, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textMain,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                      onSelected: (selected) {
                        setState(() => _selectedCategory = cat);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: allTasks.isEmpty
              ? _buildEmptyState('No tasks found in category "$_selectedCategory"')
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: allTasks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (ctx, idx) {
                    final task = allTasks[idx];
                    final match = user != null
                        ? MatchingService.calculateMatch(user, task)
                        : null;
                    return TaskCard(
                      task: task,
                      matchResult: match,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(taskId: task.taskId),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
