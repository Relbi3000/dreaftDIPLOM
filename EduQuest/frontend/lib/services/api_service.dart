import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    return {
      'Content-Type': 'application/json',
      if (userId != null) 'X-User-Id': userId.toString(),
    };
  }

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
      final response = await http.get(Uri.parse('$baseUrl/gamification/profile/$userId'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<bool> completeLesson(int userId, int lessonId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/gamification/profile/$userId/complete_lesson/$lessonId'), headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<List<dynamic>> getUserAttempts(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/quizzes/user/$userId/attempts'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getCourses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/courses/'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getLessons(int courseId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/courses/$courseId/lessons'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> getQuiz(int lessonId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/quizzes/lesson/$lessonId'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> submitQuiz(int quizId, int userId, double score) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quizzes/$quizId/submit'),
        headers: await _getHeaders(),
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
        headers: await _getHeaders(),
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
      final response = await http.get(Uri.parse('$baseUrl/teacher/dashboard'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<List<dynamic>> getStudentsProgress() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/teacher/students-progress'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getTeacherAttempts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/teacher/recent-attempts'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  // Teacher Content Management
  static Future<bool> createCourse(String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/teacher/courses'),
        headers: await _getHeaders(),
        body: jsonEncode({'title': title, 'description': description})
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> createLesson(int courseId, String title, String content, int order) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/teacher/lessons'),
        headers: await _getHeaders(),
        body: jsonEncode({'course_id': courseId, 'title': title, 'content': content, 'order': order})
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> createQuiz(int lessonId, String title, List<dynamic> questions) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/teacher/quizzes'),
        headers: await _getHeaders(),
        body: jsonEncode({'lesson_id': lessonId, 'title': title, 'questions': questions})
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/users'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  static Future<bool> toggleUserStatus(int userId, bool active) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/admin/users/$userId/status?active=$active'), headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> changeUserRole(int userId, String role) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/admin/users/$userId/role?role=$role'), headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<Map<String, dynamic>?> getSystemConfig() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/config'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<bool> updateSystemConfig(bool aiSafety, bool retries, int xp) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/config'),
        headers: await _getHeaders(),
        body: jsonEncode({'ai_safety': aiSafety, 'retries_enabled': retries, 'xp_per_quiz': xp})
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<Map<String, dynamic>?> getPlatformStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/platform-status'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> getAnalyticsOverview() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analytics/overview'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return null;
  }
}
