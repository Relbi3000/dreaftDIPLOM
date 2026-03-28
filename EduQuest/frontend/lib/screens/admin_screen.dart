import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'analytics_screen.dart';

class AdminScreen extends StatefulWidget {
  final int userId;
  const AdminScreen({required this.userId, super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> users = [];
  Map<String, dynamic>? platformStatus;
  bool isSafetyEnabled = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final usersData = await ApiService.getUsers();
    final statusData = await ApiService.getPlatformStatus();
    
    if (mounted) {
      setState(() {
        users = usersData;
        platformStatus = statusData;
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
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const Text('Platform Services', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatusRow('AI Tutor API', platformStatus?['services']?['tutor_api'] ?? 'Online Mock', Colors.green),
                    const SizedBox(height: 12),
                    _buildStatusRow('Database', platformStatus?['services']?['database'] ?? 'Connected', Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text('Platform Metrics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (platformStatus != null && platformStatus!['metrics'] != null)
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _buildMetricCard('Users', '${platformStatus!['metrics']['users']}', Colors.blue),
                  _buildMetricCard('Courses', '${platformStatus!['metrics']['courses']}', Colors.purple),
                  _buildMetricCard('Lessons', '${platformStatus!['metrics']['lessons']}', Colors.orange),
                  _buildMetricCard('Quizzes', '${platformStatus!['metrics']['quizzes']}', Colors.red),
                  _buildMetricCard('Attempts', '${platformStatus!['metrics']['attempts']}', Colors.green),
                ],
              ),
            const SizedBox(height: 32),

            const Text('AI Safety & Moderation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Strict AI Safety Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Prevent AI from answering off-topic questions (Mock control)'),
                value: isSafetyEnabled,
                activeColor: Theme.of(context).colorScheme.secondary,
                onChanged: (val) {
                  setState(() {
                    isSafetyEnabled = val;
                  });
                },
              ),
            ),

            const SizedBox(height: 32),
            const Text('User Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRoleColor(u['role']).withOpacity(0.2),
                      child: Icon(Icons.person, color: _getRoleColor(u['role'])),
                    ),
                    title: Text('${u['name'] ?? ''} (${u['email']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Role: ${u['role']}'),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(child: Text("Edit Role")),
                        const PopupMenuItem(child: Text("Deactivate User", style: TextStyle(color: Colors.red))),
                      ],
                    ),
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

  Widget _buildMetricCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Colors.redAccent;
      case 'teacher': return Colors.orangeAccent;
      default: return const Color(0xFF6C63FF);
    }
  }
}

