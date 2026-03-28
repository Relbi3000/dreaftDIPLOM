import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
    if (mounted) {
      setState(() {
        analyticsData = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (analyticsData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Platform Analytics')),
        body: const Center(child: Text("Failed to load analytics.")),
      );
    }

    final int totalUsers = analyticsData!['total_users'] ?? 0;
    final int totalAttempts = analyticsData!['total_attempts'] ?? 0;
    final double avgScore = analyticsData!['average_score'] ?? 0.0;
    final int topXp = analyticsData!['top_xp'] ?? 0;
    final List<dynamic> attemptsByCourse = analyticsData!['attempts_by_course'] ?? [];
    final List<dynamic> quizStats = analyticsData!['quiz_completion_stats'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('High-Level Metrics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMetricCard('Total Users', '$totalUsers', Icons.people, Colors.blue),
                _buildMetricCard('Total Attempts', '$totalAttempts', Icons.assignment, Colors.orange),
                _buildMetricCard('Avg Score', '${(avgScore * 100).toStringAsFixed(1)}%', Icons.analytics, Colors.green),
                _buildMetricCard('Top XP', '$topXp XP', Icons.emoji_events, Colors.amber),
              ],
            ),
            const SizedBox(height: 32),
            
            const Text('Attempts By Course', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...attemptsByCourse.map((c) {
               return Card(
                 margin: const EdgeInsets.only(bottom: 8),
                 child: ListTile(
                   leading: const Icon(Icons.school, color: Colors.purple),
                   title: Text(c['course'], style: const TextStyle(fontWeight: FontWeight.bold)),
                   trailing: Text('${c['attempts']} attempts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 ),
               );
            }).toList(),
            
            const SizedBox(height: 32),
            const Text('Quiz Completion Stats', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quizStats.length,
              itemBuilder: (context, index) {
                final q = quizStats[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.quiz, color: Colors.red),
                    title: Text(q['quiz'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: LinearProgressIndicator(
                       value: totalAttempts > 0 ? (q['completions'] / totalAttempts) : 0, 
                       color: Colors.redAccent, 
                       backgroundColor: Colors.white24
                    ),
                    trailing: Text('${q['completions']} completions', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
