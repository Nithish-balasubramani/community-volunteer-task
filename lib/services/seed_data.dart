import '../models/app_user.dart';
import '../models/volunteer_task.dart';
import '../models/task_registration.dart';

class SeedData {
  static List<AppUser> get initialUsers => [
    // Organization 1: GreenEarth Foundation
    AppUser(
      uid: 'org_greenearth',
      fullName: 'GreenEarth Foundation',
      email: 'contact@greenearth.org',
      role: 'organization',
      phone: '+1 (555) 234-5678',
      preferredLocation: 'Downtown Community Center',
      organizationDescription: 'Dedicated to urban reforestation, sustainable parks, and environmental stewardship.',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    // Organization 2: Hope Literacy Initiative
    AppUser(
      uid: 'org_hopeliteracy',
      fullName: 'Hope Literacy Initiative',
      email: 'info@hopeliteracy.org',
      role: 'organization',
      phone: '+1 (555) 345-6789',
      preferredLocation: 'Metro City Library, West Wing',
      organizationDescription: 'Empowering children and youth through free weekend tutoring, mentorship, and book drives.',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    // Volunteer 1: Alex Chen (Has Gardening & Sunday availability)
    AppUser(
      uid: 'vol_alex_chen',
      fullName: 'Alex Chen',
      email: 'alex.chen@student.edu',
      role: 'volunteer',
      phone: '+1 (555) 890-1234',
      skills: ['Gardening', 'Tree Planting', 'Teamwork', 'Communication'],
      interests: ['Environment', 'Community Service', 'Sustainability'],
      availabilityDays: ['Sunday', 'Saturday'],
      availabilityTimeSlots: ['Morning', 'Afternoon'],
      preferredLocation: 'North Campus & City Parks',
      points: 120,
      verifiedAttendanceCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    // Volunteer 2: Maya Patel (Tutoring & Teaching)
    AppUser(
      uid: 'vol_maya_patel',
      fullName: 'Maya Patel',
      email: 'maya.patel@college.edu',
      role: 'volunteer',
      phone: '+1 (555) 901-2345',
      skills: ['Teaching', 'English Tutoring', 'Mathematics', 'Patience'],
      interests: ['Education', 'Youth Mentorship', 'Children'],
      availabilityDays: ['Saturday'],
      availabilityTimeSlots: ['Morning'],
      preferredLocation: 'West End',
      points: 80,
      verifiedAttendanceCount: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static List<VolunteerTask> get initialTasks {
    final now = DateTime.now();
    // Next Sunday calculation
    final daysUntilSunday = (DateTime.sunday - now.weekday + 7) % 7;
    final nextSunday = now.add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));
    final nextSaturday = nextSunday.subtract(const Duration(days: 1));

    return [
      VolunteerTask(
        taskId: 'task_tree_plantation_01',
        organizationId: 'org_greenearth',
        organizationName: 'GreenEarth Foundation',
        title: 'Community Tree Plantation Drive',
        description: 'Join us to plant 150 native shade trees along Riverfront Park. Tools, saplings, gloves, and refreshments will be provided. Help us combat urban heat islands and make our city greener!',
        category: 'Environment',
        requiredSkills: ['Gardening', 'Tree Planting', 'Teamwork'],
        eventDate: nextSunday,
        startTime: '09:00 AM',
        endTime: '01:00 PM',
        location: 'Riverfront Park, Gate 3, Sector 4',
        volunteerLimit: 20,
        registeredCount: 8,
        registrationDeadline: nextSunday.subtract(const Duration(days: 1)),
        status: 'active',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      VolunteerTask(
        taskId: 'task_reading_buddies_02',
        organizationId: 'org_hopeliteracy',
        organizationName: 'Hope Literacy Initiative',
        title: 'Weekend Reading Buddies for Kids',
        description: 'Pair up with elementary school students for fun, interactive reading sessions. We provide storybooks, reading guides, and activity sheets to inspire lifelong learning.',
        category: 'Education',
        requiredSkills: ['Teaching', 'English Tutoring', 'Communication'],
        eventDate: nextSaturday,
        startTime: '10:00 AM',
        endTime: '12:30 PM',
        location: 'Central Public Library, 2nd Floor Youth Zone',
        volunteerLimit: 12,
        registeredCount: 6,
        registrationDeadline: nextSaturday.subtract(const Duration(days: 1)),
        status: 'active',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      VolunteerTask(
        taskId: 'task_food_drive_03',
        organizationId: 'org_greenearth',
        organizationName: 'GreenEarth Foundation',
        title: 'Organic Harvest & Food Bank Sorting',
        description: 'Help sort and pack fresh organic vegetables harvested from our community micro-farms for local emergency shelters.',
        category: 'Community',
        requiredSkills: ['Teamwork', 'Organization'],
        eventDate: nextSunday.add(const Duration(days: 7)),
        startTime: '02:00 PM',
        endTime: '05:00 PM',
        location: 'Community Center Warehouse, Bay 2',
        volunteerLimit: 15,
        registeredCount: 3,
        registrationDeadline: nextSunday.add(const Duration(days: 5)),
        status: 'active',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),
    ];
  }

  static List<TaskRegistration> get initialRegistrations => [
    TaskRegistration(
      registrationId: 'reg_demo_alex_tree',
      taskId: 'task_tree_plantation_01',
      volunteerId: 'vol_alex_chen',
      volunteerName: 'Alex Chen',
      volunteerEmail: 'alex.chen@student.edu',
      organizationId: 'org_greenearth',
      status: 'registered',
      attendanceStatus: 'pending',
      registeredAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
