import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'analytics_screen.dart';

class TeacherScreen extends StatefulWidget {
  final int userId;
  const TeacherScreen({required this.userId, super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  List<dynamic> courses = [];
  List<dynamic> studentsProgress = [];
  List<dynamic> recentAttempts = [];
  Map<String, dynamic>? overview;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final c = await ApiService.getCourses();
    final s = await ApiService.getStudentsProgress();
    final r = await ApiService.getTeacherAttempts();
    final d = await ApiService.getTeacherDashboard();
    
    if (mounted) {
      setState(() {
        courses = c;
        studentsProgress = s;
        recentAttempts = r;
        overview = d?['overview'];
        isLoading = false;
      });
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics), 
            tooltip: 'View Analytics',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()))
          ),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: _logout)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (overview != null) ...[
              const Text('Class Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildOverviewCard('Students', '${overview!['total_students']}', Icons.group, Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildOverviewCard('Avg Score', '${(overview!['average_score'] * 100).toStringAsFixed(1)}%', Icons.analytics, Colors.green)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildOverviewCard('Attempts', '${overview!['total_attempts']}', Icons.assignment, Colors.orange)),
                ],
              ),
              const SizedBox(height: 32),
            ],
            
            const Text('Courses Managed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...courses.map((c) => _buildCourseCard(c)).toList(),
            
            const SizedBox(height: 32),
            const Text('Students Progress', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: studentsProgress.length,
              itemBuilder: (context, index) {
                final sp = studentsProgress[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
                      child: Text('${sp['level']}', style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
                    ),
                    title: Text(sp['name'] ?? sp['email'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Level ${sp['level']} • XP ${sp['xp']} • Streak ${sp['streak']} Days • Lessons ${sp['lessons_completed']}'),
                    trailing: const Icon(Icons.show_chart, color: Colors.green),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            const Text('Recent Quiz Attempts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentAttempts.length,
              itemBuilder: (context, index) {
                final a = recentAttempts[index];
                final score = a['score'] * 100;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(score >= 70 ? Icons.check_circle : Icons.cancel, color: score >= 70 ? Colors.green : Colors.red),
                    title: Text('${a['user_name']} - ${a['quiz_title']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Score: ${score.toStringAsFixed(0)}% • XP: +${a['earned_xp']}'),
                    trailing: Text(a['created_at'] != null ? a['created_at'].toString().split('T')[0] : ''),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(dynamic course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)]),
            borderRadius: BorderRadius.circular(12)
          ),
          child: const Icon(Icons.school, color: Colors.white),
        ),
        title: Text(course['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(course['description'], maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

