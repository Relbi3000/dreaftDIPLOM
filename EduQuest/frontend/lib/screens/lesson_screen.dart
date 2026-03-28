import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'quiz_screen.dart';
import 'ai_tutor_screen.dart';

class LessonScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  final int userId;

  const LessonScreen({required this.courseId, required this.courseTitle, required this.userId, super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  List<dynamic> lessons = [];
  List<int> completedLessons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final resLessons = await ApiService.getLessons(widget.courseId);
    final resProfile = await ApiService.getProfile(widget.userId);
    
    setState(() {
      lessons = resLessons.isNotEmpty ? resLessons : [];
      if (resProfile != null && resProfile['completed_lessons'] != null) {
        completedLessons = List<int>.from(resProfile['completed_lessons']);
      }
      isLoading = false;
    });
  }

  void _openLessonDetails(dynamic lesson) {
      // Mark as completed when opened
      if (!completedLessons.contains(lesson['id'])) {
        ApiService.completeLesson(widget.userId, lesson['id']).then((_) {
           setState(() {
             completedLessons.add(lesson['id']);
           });
        });
      }

     showModalBottomSheet(
        context: context, 
        isScrollControlled: true,
        backgroundColor: const Color(0xFF282A36),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          expand: false,
          builder: (_, controller) => _buildLessonContent(lesson, controller)
        )
     );
  }

  Widget _buildLessonContent(dynamic lesson, ScrollController controller) {
     return Padding(
       padding: const EdgeInsets.all(24.0),
       child: ListView(
         controller: controller,
         children: [
           Text(lesson['title'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
           const SizedBox(height: 24),
           Text(lesson['content'], style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.white70)),
           const SizedBox(height: 48),
           ElevatedButton.icon(
             icon: const Icon(Icons.smart_toy),
             label: const Text('Ask AI Tutor for help'),
             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B4D8)),
             onPressed: () {
               Navigator.push(context, MaterialPageRoute(
                 builder: (_) => AITutorScreen(userId: widget.userId, contextStr: lesson['title'])
               ));
             },
           ),
           const SizedBox(height: 16),
           ElevatedButton.icon(
             icon: const Icon(Icons.quiz),
             label: const Text('Take Quiz to Earn XP'),
             onPressed: () async {
               Navigator.pop(context); // close modal
               await Navigator.push(context, MaterialPageRoute(
                 builder: (_) => QuizScreen(lessonId: lesson['id'], lessonTitle: lesson['title'], userId: widget.userId)
               ));
               _loadData(); // refresh completed status
             },
           )
         ],
       ),
     );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text(widget.courseTitle)),
      body: lessons.isEmpty 
          ? const Center(child: Text("No lessons found for this course."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final l = lessons[index];
          final isCompleted = completedLessons.contains(l['id']);

          return Card(
             margin: const EdgeInsets.only(bottom: 16),
             elevation: isCompleted ? 1 : 3,
             child: ListTile(
               leading: CircleAvatar(
                 backgroundColor: isCompleted ? Colors.green.withOpacity(0.2) : const Color(0xFF6C63FF).withOpacity(0.2),
                 child: isCompleted 
                     ? const Icon(Icons.check, color: Colors.green)
                     : Text('${index + 1}', style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
               ),
               title: Text(l['title'], style: TextStyle(fontWeight: FontWeight.bold, decoration: isCompleted ? TextDecoration.none : null)),
               subtitle: Text(isCompleted ? 'Completed' : 'Read lesson & take quiz', style: TextStyle(color: isCompleted ? Colors.green : Colors.grey)),
               trailing: const Icon(Icons.arrow_forward_ios, size: 16),
               contentPadding: const EdgeInsets.all(16),
               onTap: () => _openLessonDetails(l),
             ),
          );
        },
      ),
    );
  }
}

