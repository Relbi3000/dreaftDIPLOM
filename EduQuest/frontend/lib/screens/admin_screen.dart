import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  final int userId;
  const AdminScreen({required this.userId, super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> users = [];
  Map<String, dynamic>? platformStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final usersData = await ApiService.getUsers();
    final statusData = await ApiService.getPlatformStatus();
    
    setState(() {
      users = usersData;
      platformStatus = statusData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.of(context).pop())
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Platform Status', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatusRow('AI Tutor API', platformStatus?['tutor_api'] ?? 'Online', Colors.green),
                    const SizedBox(height: 12),
                    _buildStatusRow('Safety Filter', platformStatus?['safety_filter'] ?? 'Active', Colors.blue),
                    const SizedBox(height: 12),
                    _buildStatusRow('Database', platformStatus?['database'] ?? 'Connected', Colors.green),
                  ],
                ),
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
                    title: Text(u['email'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Role: ${u['role']}'),
                  ),
                );
              },
            ),
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
