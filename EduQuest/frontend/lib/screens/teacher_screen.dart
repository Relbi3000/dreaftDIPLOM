import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../ui/app_components.dart';
import '../ui/eduquest_theme.dart';
import 'login_screen.dart';

class TeacherScreen extends StatefulWidget {
  final int userId;

  const TeacherScreen({required this.userId, super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  static const _destinations = [
    ShellDestination(label: 'Overview', icon: Icons.dashboard_outlined),
    ShellDestination(label: 'Content', icon: Icons.menu_book_outlined),
    ShellDestination(label: 'Assign', icon: Icons.assignment_outlined),
    ShellDestination(label: 'Analytics', icon: Icons.insights_outlined),
    ShellDestination(label: 'Profile', icon: Icons.person_outline),
  ];

  int _selectedIndex = 0;
  List<dynamic> courses = [];
  List<dynamic> studentsProgress = [];
  List<dynamic> recentAttempts = [];
  Map<String, dynamic>? overview;
  bool isLoading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getCourses(),
        ApiService.getStudentsProgress(),
        ApiService.getTeacherAttempts(),
        ApiService.getTeacherDashboard(),
      ]);

      if (!mounted) return;

      setState(() {
        courses = results[0] as List<dynamic>;
        studentsProgress = results[1] as List<dynamic>;
        recentAttempts = results[2] as List<dynamic>;
        overview = (results[3] as Map<String, dynamic>?)?['overview'];
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadError = 'Teacher workspace could not load data from the API.';
      });
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _showCreateCourseDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final navigator = Navigator.of(dialogContext);
        final messenger = ScaffoldMessenger.of(context);
        return AlertDialog(
          title: const Text('Create course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Course title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;
                final ok = await ApiService.createCourse(
                  titleController.text,
                  descController.text,
                );
                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      ok ? 'Course created' : 'Failed to create course',
                    ),
                  ),
                );
                if (ok) _loadData();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateLessonDialog() async {
    if (courses.isEmpty) return;
    int selectedCourseId = courses.first['id'];
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final orderController = TextEditingController(text: '1');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final navigator = Navigator.of(dialogContext);
        final messenger = ScaffoldMessenger.of(context);
        return AlertDialog(
          title: const Text('Create lesson'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedCourseId,
                  items:
                      courses
                          .map(
                            (course) => DropdownMenuItem<int>(
                              value: course['id'],
                              child: Text(course['title']),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) => selectedCourseId = value ?? selectedCourseId,
                  decoration: const InputDecoration(labelText: 'Course'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Lesson title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Lesson content',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Order'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final ok = await ApiService.createLesson(
                  selectedCourseId,
                  titleController.text,
                  contentController.text,
                  int.tryParse(orderController.text) ?? 1,
                );
                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      ok ? 'Lesson created' : 'Failed to create lesson',
                    ),
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateQuizDialog() async {
    final titleController = TextEditingController();
    final lessonIdController = TextEditingController();
    final questionsController = TextEditingController(
      text: '[{"q": "Example?", "options": ["A", "B", "C", "D"], "answer": 0}]',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final navigator = Navigator.of(dialogContext);
        final messenger = ScaffoldMessenger.of(context);
        return AlertDialog(
          title: const Text('Create quiz'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Quiz title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lessonIdController,
                  decoration: const InputDecoration(labelText: 'Lesson ID'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: questionsController,
                  minLines: 4,
                  maxLines: 7,
                  decoration: const InputDecoration(
                    labelText: 'Questions JSON array',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final questions = jsonDecode(questionsController.text);
                  final ok = await ApiService.createQuiz(
                    int.parse(lessonIdController.text),
                    titleController.text,
                    questions,
                  );
                  if (!mounted) return;
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        ok ? 'Quiz created' : 'Failed to create quiz',
                      ),
                    ),
                  );
                } catch (_) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Questions JSON is invalid')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: AppLoadingView(
          title: 'Loading teacher workspace',
          message: 'Syncing courses, student progress, and classroom activity.',
        ),
      );
    }

    if (loadError != null) {
      return Scaffold(
        body: AppErrorState(
          title: 'Teacher workspace unavailable',
          description: loadError!,
          onRetry: _loadData,
        ),
      );
    }

    return EduQuestShell(
      title: 'Teacher workspace',
      subtitle:
          'Publish content, coordinate assignments, and review class analytics.',
      currentIndex: _selectedIndex,
      destinations: _destinations,
      onSelect: (index) => setState(() => _selectedIndex = index),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: _loadData,
          icon: const Icon(Icons.refresh),
        ),
      ],
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton.extended(
                onPressed: _showCreateCourseDialog,
                icon: const Icon(Icons.add),
                label: const Text('New course'),
              )
              : null,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _buildCurrentTab(),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedIndex) {
      case 1:
        return _buildContentTab();
      case 2:
        return _buildAssignmentsTab();
      case 3:
        return _buildAnalyticsTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    final activeCourses = courses.length;
    final activeStudents =
        (overview?['active_students'] as num?)?.toInt() ??
        studentsProgress.length;
    final avgScore =
        ((overview?['average_score'] as num?)?.toDouble() ??
            (studentsProgress.isEmpty
                ? 0
                : studentsProgress.fold<double>(
                      0,
                      (sum, item) =>
                          sum +
                          (((item['average_score'] ?? 0) as num).toDouble()),
                    ) /
                    studentsProgress.length)) *
        100;

    return ListView(
      children: [
        AppSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppInfoChip(
                label: 'Teacher control layer',
                color: EduQuestColors.primary,
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 14),
              Text(
                'Class health at a glance',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This shell surfaces course activity, student momentum, and recent attempts so the teaching side feels like a real product surface.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 170,
          child: GridView.count(
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              AppStatCard(
                label: 'Active courses',
                value: '$activeCourses',
                icon: Icons.menu_book_outlined,
                color: EduQuestColors.primary,
              ),
              AppStatCard(
                label: 'Tracked students',
                value: '$activeStudents',
                icon: Icons.groups_2_outlined,
                color: EduQuestColors.info,
              ),
              AppStatCard(
                label: 'Average score',
                value: '${avgScore.round()}%',
                icon: Icons.analytics_outlined,
                color: EduQuestColors.secondary,
              ),
              AppStatCard(
                label: 'Recent attempts',
                value: '${recentAttempts.length}',
                icon: Icons.fact_check_outlined,
                color: EduQuestColors.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const AppSectionHeader(
          title: 'Recommended next actions',
          subtitle: 'Common instructor workflows from this screen.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppActionCard(
                title: 'Publish content',
                subtitle:
                    'Create a course or lesson shell for the current week.',
                icon: Icons.addchart_outlined,
                color: EduQuestColors.primary,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppActionCard(
                title: 'Review analytics',
                subtitle: 'Inspect weak spots and progress signals by learner.',
                icon: Icons.insights_outlined,
                color: EduQuestColors.accent,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const AppSectionHeader(
          title: 'Recent class activity',
          subtitle:
              'Latest quiz attempts and class movement from the backend feed.',
        ),
        const SizedBox(height: 12),
        if (recentAttempts.isEmpty)
          const AppEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No classroom attempts yet',
            description:
                'As students complete quizzes, this overview will show live attempt traffic.',
          )
        else
          ...recentAttempts.take(5).map(_buildAttemptTile),
      ],
    );
  }

  Widget _buildContentTab() {
    return ListView(
      children: [
        const AppSectionHeader(
          title: 'Content studio',
          subtitle:
              'Manage courses, lessons, and assessment content from one teacher flow.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppActionCard(
                title: 'Create course',
                subtitle: 'Start a new learning path for a topic or module.',
                icon: Icons.add_box_outlined,
                color: EduQuestColors.primary,
                onTap: _showCreateCourseDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppActionCard(
                title: 'Create lesson',
                subtitle: 'Add reading content and order it inside a course.',
                icon: Icons.post_add_outlined,
                color: EduQuestColors.secondary,
                onTap: _showCreateLessonDialog,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppActionCard(
          title: 'Create quiz',
          subtitle:
              'Publish an assessment payload that students can practice against.',
          icon: Icons.quiz_outlined,
          color: EduQuestColors.info,
          onTap: _showCreateQuizDialog,
        ),
        const SizedBox(height: 16),
        const AppSectionHeader(
          title: 'Published courses',
          subtitle: 'Current teacher-visible course inventory.',
        ),
        const SizedBox(height: 12),
        if (courses.isEmpty)
          const AppEmptyState(
            icon: Icons.menu_book_outlined,
            title: 'No published courses',
            description:
                'The content shell is ready. Create the first course to populate this surface.',
          )
        else
          ...courses.map((course) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppSurface(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: EduQuestColors.primarySoft,
                      child: Text(
                        '${course['id']}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['title']?.toString() ?? 'Course',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            course['description']?.toString() ??
                                'Description not provided.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const AppInfoChip(
                      label: 'Published',
                      color: EduQuestColors.success,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAssignmentsTab() {
    return ListView(
      children: [
        const AppSectionHeader(
          title: 'Assignment planning',
          subtitle:
              'Show how teacher-side task distribution will work, even while some backend endpoints are still thin.',
        ),
        const SizedBox(height: 12),
        AppSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppInfoChip(
                label: 'Placeholder-powered shell',
                color: EduQuestColors.secondary,
                icon: Icons.auto_awesome_mosaic_outlined,
              ),
              const SizedBox(height: 12),
              Text(
                'Assignment controls',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'This phase intentionally makes the full teacher product surface visible before every backend workflow is complete.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ...[
                'Assign a quiz to a course cohort',
                'Set target completion windows',
                'Mark assignments that need reteaching support',
                'Review recent completion and missed-attempt patterns',
              ].map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: EduQuestColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Assignment template ${index + 1}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      AppInfoChip(
                        label: index == 0 ? 'Ready' : 'Planned',
                        color:
                            index == 0
                                ? EduQuestColors.success
                                : EduQuestColors.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    index == 0
                        ? 'A realistic placeholder for quiz distribution and due-date planning.'
                        : 'Visible product shell for assignment workflows that the next backend iteration will deepen.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return ListView(
      children: [
        const AppSectionHeader(
          title: 'Teacher analytics',
          subtitle:
              'Track learner progress, weak zones, and class performance patterns.',
        ),
        const SizedBox(height: 12),
        if (studentsProgress.isEmpty)
          const AppEmptyState(
            icon: Icons.bar_chart_outlined,
            title: 'No student analytics yet',
            description:
                'Once student attempts and progress data accumulate, this tab will become more informative.',
          )
        else
          ...studentsProgress.map((student) {
            final avgScore =
                (((student['average_score'] ?? 0) as num).toDouble() * 100)
                    .round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student['full_name']?.toString() ?? 'Student',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        AppInfoChip(
                          label: '$avgScore%',
                          color: EduQuestColors.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Level ${student['level'] ?? 1} • ${student['xp'] ?? 0} XP • ${student['completed_lessons'] ?? 0} completed lessons',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (avgScore / 100).clamp(0, 1).toDouble(),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(999),
                      backgroundColor: EduQuestColors.primarySoft,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      children: [
        AppSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: EduQuestColors.primarySoft,
                    child: const Icon(Icons.school_outlined),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teacher account',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Role-aware educator shell for content, assignments, and analytics.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const AppInfoChip(
                    label: 'Teacher',
                    color: EduQuestColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppActionCard(
          title: 'Refresh workspace',
          subtitle: 'Reload course, attempt, and student analytics data.',
          icon: Icons.refresh_outlined,
          color: EduQuestColors.info,
          onTap: _loadData,
        ),
        const SizedBox(height: 12),
        AppActionCard(
          title: 'Sign out',
          subtitle: 'Return to the shared role-based auth entry.',
          icon: Icons.logout_outlined,
          color: EduQuestColors.danger,
          onTap: _logout,
        ),
      ],
    );
  }

  Widget _buildAttemptTile(dynamic attempt) {
    final score = (((attempt['score'] ?? 0) as num).toDouble() * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppSurface(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: EduQuestColors.surfaceAlt,
              child: Text('$score%'),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attempt['quiz_title']?.toString() ?? 'Quiz attempt',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${attempt['student_name'] ?? 'Student'} • ${attempt['earned_xp'] ?? 0} XP earned',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
