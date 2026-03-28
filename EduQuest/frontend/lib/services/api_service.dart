import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to host localhost, or standard localhost for Web/Desktop
  // Assuming a local run for the defense.
  static const String baseUrl = 'http://192.168.1.68:8000/api';
  
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', data['user_id']);
        return data;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getProfile(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/gamification/profile/$userId'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<bool> completeLesson(int userId, int lessonId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/gamification/profile/$userId/complete_lesson/$lessonId'));
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<List<dynamic>> getUserAttempts(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/quizzes/user/$userId/attempts'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getCourses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/courses/'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getLessons(int courseId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/courses/$courseId/lessons'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> getQuiz(int lessonId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/quizzes/lesson/$lessonId'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> submitQuiz(int quizId, int userId, double score) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quizzes/$quizId/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'score': score}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<String> getAiHint(int userId, String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai-tutor/hint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'context': 'General', 'user_question': question}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['hint'];
      }
      return "I'm having trouble connecting to my knowledge base right now.";
    } catch (e) {
      return "Network error: Unable to reach AI Tutor.";
    }
  }

  static Future<Map<String, dynamic>?> getTeacherDashboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/teacher/dashboard'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<List<dynamic>> getStudentsProgress() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/teacher/students-progress'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getTeacherAttempts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/teacher/recent-attempts'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/users'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> getPlatformStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/platform-status'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> getAnalyticsOverview() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analytics/overview'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return null;
  }
}
