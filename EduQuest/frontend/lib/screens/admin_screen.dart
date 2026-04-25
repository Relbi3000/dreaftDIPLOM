import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../ui/app_components.dart';
import '../ui/eduquest_theme.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  final int userId;

  const AdminScreen({required this.userId, super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  static const _destinations = [
    ShellDestination(label: 'Overview', icon: Icons.dashboard_outlined),
    ShellDestination(label: 'Users', icon: Icons.group_outlined),
    ShellDestination(label: 'Safety', icon: Icons.shield_outlined),
    ShellDestination(label: 'Reports', icon: Icons.assessment_outlined),
    ShellDestination(label: 'Profile', icon: Icons.person_outline),
  ];

  int _selectedIndex = 0;
  List<dynamic> users = [];
  Map<String, dynamic>? platformStatus;
  bool isSafetyEnabled = true;
  bool retriesEnabled = true;
  int xpPerQuiz = 100;
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
      final usersData = await ApiService.getUsers();
      final statusData = await ApiService.getPlatformStatus();
      final configData = await ApiService.getSystemConfig();

      if (!mounted) return;

      setState(() {
        users = usersData;
        platformStatus = statusData;
        if (configData != null) {
          isSafetyEnabled = configData['ai_safety'] ?? true;
          retriesEnabled = configData['retries_enabled'] ?? true;
          xpPerQuiz = configData['xp_per_quiz'] ?? 100;
        }
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadError = 'Admin workspace could not load governance data.';
      });
    }
  }

  Future<void> _updateConfig() async {
    final ok = await ApiService.updateSystemConfig(
      isSafetyEnabled,
      retriesEnabled,
      xpPerQuiz,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Configuration saved' : 'Failed to save configuration',
        ),
      ),
    );
  }

  Future<void> _changeRole(int id, String currentRole) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                ['student', 'teacher', 'admin']
                    .map(
                      (role) => ListTile(
                        title: Text(role.toUpperCase()),
                        onTap: () => Navigator.pop(context, role),
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
    if (newRole != null && newRole != currentRole) {
      await ApiService.changeUserRole(id, newRole);
      _loadData();
    }
  }

  Future<void> _toggleUserStatus(int id, bool currentStatus) async {
    await ApiService.toggleUserStatus(id, !currentStatus);
    _loadData();
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: AppLoadingView(
          title: 'Loading admin workspace',
          message:
              'Syncing platform metrics, user controls, and policy settings.',
        ),
      );
    }

    if (loadError != null) {
      return Scaffold(
        body: AppErrorState(
          title: 'Admin workspace unavailable',
          description: loadError!,
          onRetry: _loadData,
        ),
      );
    }

    return EduQuestShell(
      title: 'Admin workspace',
      subtitle:
          'Govern platform usage, user access, and AI-related operating controls.',
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
        return _buildUsersTab();
      case 2:
        return _buildSafetyTab();
      case 3:
        return _buildReportsTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    final metrics = platformStatus?['metrics'] as Map<String, dynamic>? ?? {};
    final services =
        platformStatus?['services'] as Map<String, dynamic>? ??
        <String, dynamic>{};

    return ListView(
      children: [
        AppSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppInfoChip(
                label: 'Governance shell',
                color: EduQuestColors.info,
                icon: Icons.admin_panel_settings_outlined,
              ),
              const SizedBox(height: 14),
              Text(
                'Platform health overview',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Admin surfaces should feel operational and policy-driven rather than like ordinary learning dashboards.',
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
                label: 'Users',
                value: '${metrics['users'] ?? 0}',
                icon: Icons.people_outline,
                color: EduQuestColors.primary,
              ),
              AppStatCard(
                label: 'Courses',
                value: '${metrics['courses'] ?? 0}',
                icon: Icons.library_books_outlined,
                color: EduQuestColors.secondary,
              ),
              AppStatCard(
                label: 'Quizzes',
                value: '${metrics['quizzes'] ?? 0}',
                icon: Icons.quiz_outlined,
                color: EduQuestColors.info,
              ),
              AppStatCard(
                label: 'Attempts',
                value: '${metrics['attempts'] ?? 0}',
                icon: Icons.fact_check_outlined,
                color: EduQuestColors.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const AppSectionHeader(
          title: 'Service posture',
          subtitle:
              'A quick read on core services and policy-sensitive subsystems.',
        ),
        const SizedBox(height: 12),
        ...[
          (
            'AI Tutor policy',
            services['safety_filter']?.toString() ?? 'Unknown',
          ),
          ('Database', services['database']?.toString() ?? 'Unknown'),
          (
            'Retries policy',
            retriesEnabled ? 'Enabled for learners' : 'Disabled for learners',
          ),
        ].map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppSurface(
              child: Row(
                children: [
                  const Icon(
                    Icons.donut_small_outlined,
                    color: EduQuestColors.info,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.$1,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(entry.$2, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUsersTab() {
    return ListView(
      children: [
        const AppSectionHeader(
          title: 'Users and roles',
          subtitle: 'Inspect account status, change roles, and control access.',
        ),
        const SizedBox(height: 12),
        if (users.isEmpty)
          const AppEmptyState(
            icon: Icons.group_outlined,
            title: 'No users returned',
            description:
                'The governance shell is ready. User data will appear here when the admin endpoint responds with rows.',
          )
        else
          ...users.map((user) {
            final isActive = user['is_active'] ?? true;
            final role = user['role']?.toString() ?? 'student';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppSurface(
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              isActive
                                  ? EduQuestColors.primarySoft
                                  : EduQuestColors.danger.withValues(
                                    alpha: 0.16,
                                  ),
                          child: Icon(
                            role == 'teacher'
                                ? Icons.school_outlined
                                : role == 'admin'
                                ? Icons.admin_panel_settings_outlined
                                : Icons.person_outline,
                            color:
                                isActive
                                    ? EduQuestColors.primary
                                    : EduQuestColors.danger,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['email']?.toString() ?? 'User',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${role.toUpperCase()} • ${isActive ? 'Active' : 'Suspended'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _changeRole(user['id'], role),
                            child: const Text('Change role'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                () => _toggleUserStatus(user['id'], isActive),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isActive
                                      ? EduQuestColors.danger
                                      : EduQuestColors.success,
                            ),
                            child: Text(isActive ? 'Disable' : 'Enable'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSafetyTab() {
    return ListView(
      children: [
        const AppSectionHeader(
          title: 'Safety and policy controls',
          subtitle: 'Tune AI filtering, retries, and motivational parameters.',
        ),
        const SizedBox(height: 12),
        AppSurface(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Strict AI safety filter'),
                subtitle: const Text(
                  'Prevent AI from answering unsafe or off-topic requests.',
                ),
                value: isSafetyEnabled,
                onChanged: (value) {
                  setState(() => isSafetyEnabled = value);
                  _updateConfig();
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Allow quiz retries'),
                subtitle: const Text(
                  'Support low-stakes mastery through repeated attempts.',
                ),
                value: retriesEnabled,
                onChanged: (value) {
                  setState(() => retriesEnabled = value);
                  _updateConfig();
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('XP per quiz'),
                subtitle: Text(
                  'Current value: $xpPerQuiz XP',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Slider(
                value: xpPerQuiz.toDouble(),
                min: 25,
                max: 200,
                divisions: 7,
                label: '$xpPerQuiz XP',
                onChanged: (value) => setState(() => xpPerQuiz = value.round()),
                onChangeEnd: (_) => _updateConfig(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    final metrics = platformStatus?['metrics'] as Map<String, dynamic>? ?? {};

    return ListView(
      children: [
        const AppSectionHeader(
          title: 'Platform reports',
          subtitle:
              'Aggregated signals for audit-style readouts and operating awareness.',
        ),
        const SizedBox(height: 12),
        AppSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current report snapshot',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              ...[
                'Users tracked: ${metrics['users'] ?? 0}',
                'Courses published: ${metrics['courses'] ?? 0}',
                'Lessons available: ${metrics['lessons'] ?? 0}',
                'Quizzes published: ${metrics['quizzes'] ?? 0}',
                'Attempts logged: ${metrics['attempts'] ?? 0}',
              ].map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_right,
                        color: EduQuestColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(line)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(2, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    index == 0
                        ? 'Policy audit placeholder'
                        : 'Operational trend placeholder',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    index == 0
                        ? 'This surface reserves space for explicit governance summaries tied to the diploma architecture.'
                        : 'This surface reserves space for later richer trend reporting once analytics depth increases.',
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
                    child: const Icon(Icons.admin_panel_settings_outlined),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administrator account',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Role-aware governance shell for users, safety controls, and platform reports.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const AppInfoChip(label: 'Admin', color: EduQuestColors.info),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppActionCard(
          title: 'Refresh workspace',
          subtitle: 'Reload users, platform health, and current configuration.',
          icon: Icons.refresh_outlined,
          color: EduQuestColors.info,
          onTap: _loadData,
        ),
        const SizedBox(height: 12),
        AppActionCard(
          title: 'Sign out',
          subtitle: 'Exit the admin role and return to the shared auth entry.',
          icon: Icons.logout_outlined,
          color: EduQuestColors.danger,
          onTap: _logout,
        ),
      ],
    );
  }
}
