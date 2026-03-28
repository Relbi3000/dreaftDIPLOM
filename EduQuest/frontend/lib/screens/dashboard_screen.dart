import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'lesson_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  const DashboardScreen({required this.userId, super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? profile;
  List<dynamic> courses = [];
  List<dynamic> attempts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final p = await ApiService.getProfile(widget.userId);
    final c = await ApiService.getCourses();
    final a = await ApiService.getUserAttempts(widget.userId);
    
    if (mounted) {
      setState(() {
        profile = p ?? {'xp': 1500, 'level': 3, 'streak': 5, 'completed_lessons': []};
        courses = c;
        attempts = a;
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isDesktop = MediaQuery.of(context).size.width >= 600;

    Widget body = _buildBodyContent();

    if (isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('EduQuest', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout)
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              backgroundColor: Theme.of(context).colorScheme.surface,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.library_books), label: Text('Courses')),
                NavigationRailDestination(icon: Icon(Icons.history), label: Text('History')),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('EduQuest', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout)
        ],
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildCoursesTab();
      case 2:
        return _buildHistoryTab();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileSection(),
          const SizedBox(height: 32),
          const Text('Recent Courses', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (courses.isNotEmpty) _buildCourseCard(courses.first) else const Text('No courses available.'),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return _buildCourseCard(courses[index]);
      },
    );
  }

  Widget _buildHistoryTab() {
    if (attempts.isEmpty) {
      return const Center(child: Text("No quiz attempts yet. Start learning!"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: attempts.length,
      itemBuilder: (context, index) {
        final a = attempts[index];
        final score = a['score'] * 100;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(score >= 70 ? Icons.check_circle : Icons.cancel, color: score >= 70 ? Colors.green : Colors.red, size: 32),
            title: Text(a['quiz_title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Score: ${score.toStringAsFixed(0)}% • XP: +${a['earned_xp']}'),
            trailing: Text(a['created_at'] != null ? a['created_at'].toString().split('T')[0] : ''),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection() {
    int level = profile!['level'] ?? 1;
    int xp = profile!['xp'] ?? 0;
    int streak = profile!['streak'] ?? 0;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Level $level', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                         value: (xp % 500) / 500.0,
                         backgroundColor: Colors.white24,
                         color: Theme.of(context).colorScheme.secondary,
                         minHeight: 12,
                         borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 8),
                      Text('$xp XP / ${level * 500} XP', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBadge(Icons.star, '$xp', 'Total XP', Colors.amber),
                _buildStatBadge(Icons.local_fire_department, '$streak', 'Day Streak', Colors.deepOrange),
                _buildStatBadge(Icons.emoji_events, '${(xp~/300)+1}', 'Badges', Colors.blueAccent),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15), 
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 2)
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildCourseCard(dynamic course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (_) => LessonScreen(courseId: course['id'], courseTitle: course['title'], userId: widget.userId)
          ));
          _loadData(); // Reload data when returning
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                  ]
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(course['description'], style: const TextStyle(color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

