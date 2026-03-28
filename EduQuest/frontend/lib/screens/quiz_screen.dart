import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;
  final int userId;

  const QuizScreen({required this.lessonId, required this.lessonTitle, required this.userId, super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> questions = [];
  int currentQuestionIdx = 0;
  int correctAnswers = 0;
  bool isLoading = true;
  bool showResult = false;
  Map<String, dynamic>? resultData;
  int? quizId;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final quiz = await ApiService.getQuiz(widget.lessonId);
    setState(() {
      if (quiz != null) {
        quizId = quiz['id'];
        questions = jsonDecode(quiz['questions']);
      } else {
        quizId = 1;
        questions = [
          {'q': 'What is a variable?', 'options': ['A data container', 'A loop', 'A function'], 'answer': 0},
          {'q': 'Which is NOT a standard data type?', 'options': ['Integer', 'String', 'Elephant'], 'answer': 2}
        ];
      }
      isLoading = false;
    });
  }

  Future<void> _submitAnswer(int selectedIdx) async {
    final correctIdx = questions[currentQuestionIdx]['answer'];
    if (selectedIdx == correctIdx) {
      correctAnswers++;
    }

    if (currentQuestionIdx < questions.length - 1) {
      setState(() => currentQuestionIdx++);
    } else {
      // Quiz finished, submit score
      setState(() => isLoading = true);
      double score = correctAnswers / questions.length;
      final res = await ApiService.submitQuiz(quizId ?? 1, widget.userId, score);
      setState(() {
        isLoading = false;
        showResult = true;
        resultData = res ?? {'xp_earned': (score * 100).toInt(), 'new_level': 3};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text('Quiz: ${widget.lessonTitle}')),
      body: showResult ? _buildResultView() : _buildQuizView(),
    );
  }

  Widget _buildQuizView() {
    final q = questions[currentQuestionIdx];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Question ${currentQuestionIdx + 1} of ${questions.length}', 
            style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: (currentQuestionIdx) / questions.length, color: Colors.blueAccent),
          const SizedBox(height: 32),
          Text(q['q'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          ...List.generate(q['options'].length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF282A36),
                  side: const BorderSide(color: Color(0xFF6C63FF), width: 1),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () => _submitAnswer(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Text(q['options'][index], style: const TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 100),
          const SizedBox(height: 32),
          Text('Quiz Completed!', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('You scored $correctAnswers out of ${questions.length}', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 32),
           Container(
             padding: const EdgeInsets.all(24),
             decoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.2), borderRadius: BorderRadius.circular(24)),
             child: Column(
               children: [
                 Text('+${resultData!['xp_earned']} XP', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                 const SizedBox(height: 8),
                 Text('Current Level: ${resultData!['new_level']}', style: const TextStyle(fontSize: 18, color: Colors.white70)),
               ],
             ),
           ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
               // pop back to dashboard, removing lesson screen too
               Navigator.pop(context);
            },
            child: const Text('Back to Dashboard', style: TextStyle(fontSize: 18)),
          )
        ],
      ),
    );
  }
}
