import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../ui/app_components.dart';
import '../ui/eduquest_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? analyticsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ApiService.getAnalyticsOverview();
    if (!mounted) return;
    setState(() {
      analyticsData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: AppLoadingView(
          title: 'Loading analytics',
          message: 'Preparing aggregate platform metrics and completion data.',
        ),
      );
    }

    if (analyticsData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Platform analytics')),
        body: AppErrorState(
          title: 'Analytics unavailable',
          description: 'The analytics endpoint did not return data.',
          onRetry: _loadData,
        ),
      );
    }

    final totalUsers = analyticsData!['total_users'] ?? 0;
    final totalAttempts = analyticsData!['total_attempts'] ?? 0;
    final avgScore =
        ((analyticsData!['average_score'] ?? 0.0) as num).toDouble();
    final topXp = analyticsData!['top_xp'] ?? 0;
    final attemptsByCourse =
        analyticsData!['attempts_by_course'] as List<dynamic>? ?? [];
    final quizStats =
        analyticsData!['quiz_completion_stats'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Platform analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AppSectionHeader(
            title: 'High-level metrics',
            subtitle:
                'A standalone analytics surface that matches the new role-aware UI system.',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: GridView.count(
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                AppStatCard(
                  label: 'Total users',
                  value: '$totalUsers',
                  icon: Icons.people_outline,
                  color: EduQuestColors.primary,
                ),
                AppStatCard(
                  label: 'Attempts',
                  value: '$totalAttempts',
                  icon: Icons.fact_check_outlined,
                  color: EduQuestColors.secondary,
                ),
                AppStatCard(
                  label: 'Average score',
                  value: '${(avgScore * 100).round()}%',
                  icon: Icons.analytics_outlined,
                  color: EduQuestColors.info,
                ),
                AppStatCard(
                  label: 'Top XP',
                  value: '$topXp',
                  icon: Icons.emoji_events_outlined,
                  color: EduQuestColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const AppSectionHeader(
            title: 'Attempts by course',
            subtitle: 'Cross-course view of assessment activity.',
          ),
          const SizedBox(height: 12),
          if (attemptsByCourse.isEmpty)
            const AppEmptyState(
              icon: Icons.school_outlined,
              title: 'No course attempt data',
              description:
                  'Attempt-by-course analytics will appear here when data is available.',
            )
          else
            ...attemptsByCourse.map((course) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppSurface(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        color: EduQuestColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          course['course']?.toString() ?? 'Course',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '${course['attempts']} attempts',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
          const AppSectionHeader(
            title: 'Quiz completion stats',
            subtitle: 'Completion counts across published quizzes.',
          ),
          const SizedBox(height: 12),
          if (quizStats.isEmpty)
            const AppEmptyState(
              icon: Icons.quiz_outlined,
              title: 'No quiz completion data',
              description:
                  'Quiz-level completion metrics will appear here when attempts are logged.',
            )
          else
            ...quizStats.map((quiz) {
              final completions = (quiz['completions'] ?? 0) as num;
              final ratio =
                  totalAttempts > 0
                      ? (completions / totalAttempts).toDouble()
                      : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz['quiz']?.toString() ?? 'Quiz',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: ratio.clamp(0, 1),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(999),
                        backgroundColor: EduQuestColors.primarySoft,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$completions completions',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
