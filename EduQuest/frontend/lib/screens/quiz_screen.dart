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
  List<int> userAnswers = [];
  int correctAnswers = 0;
  bool isLoading = true;
  bool showResult = false;
  Map<String, dynamic>? resultData;
  int? quizId;
  bool retriesEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final quiz = await ApiService.getQuiz(widget.lessonId);
    final config = await ApiService.getSystemConfig();
    
    setState(() {
      if (config != null) {
        retriesEnabled = config['retries_enabled'] ?? true;
      }
      if (quiz != null && quiz['questions'] != null) {
        quizId = quiz['id'];
        questions = jsonDecode(quiz['questions']);
      } else {
        quizId = 1;
        questions = [
          {'q': 'What is a variable?', 'options': ['A data container', 'A loop', 'A function'], 'answer': 0},
        ];
      }
      userAnswers = List.filled(questions.length, -1);
      isLoading = false;
    });
  }

  Future<void> _submitAnswer(int selectedIdx) async {
    userAnswers[currentQuestionIdx] = selectedIdx;
    final correctIdx = questions[currentQuestionIdx]['answer'];
    if (selectedIdx == correctIdx) {
      correctAnswers++;
    }

    if (currentQuestionIdx < questions.length - 1) {
      setState(() => currentQuestionIdx++);
    } else {
      setState(() => isLoading = true);
      double score = questions.isEmpty ? 0 : correctAnswers / questions.length;
      final res = await ApiService.submitQuiz(quizId ?? 1, widget.userId, score);
      
      await ApiService.completeLesson(widget.userId, widget.lessonId);

      setState(() {
        isLoading = false;
        showResult = true;
        resultData = res ?? {
          'xp_earned': (score * 100).toInt(), 
          'new_level': 1, 
          'feedback_message': 'Good job! Keep learning.'
        };
      });
    }
  }

  void _retryQuiz() {
    setState(() {
      currentQuestionIdx = 0;
      correctAnswers = 0;
      userAnswers = List.filled(questions.length, -1);
      showResult = false;
    });
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
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                ),
                onPressed: () => _submitAnswer(index),
                child: Text(q['options'][index], style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
          const SizedBox(height: 16),
          const Text('Quiz Completed!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('You scored $correctAnswers out of ${questions.length}', style: const TextStyle(fontSize: 18, color: Colors.white70)),
          const SizedBox(height: 8),
          if (resultData != null && resultData!['feedback_message'] != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blueAccent.withOpacity(0.5))),
              child: Text(
                resultData!['feedback_message'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.lightBlueAccent, fontStyle: FontStyle.italic),
              ),
            ),
          const SizedBox(height: 16),
           Container(
             padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
             child: Column(
               children: [
                 Text('+${resultData!['xp_earned']} XP', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
               ],
             ),
           ),
          const SizedBox(height: 32),
          const Text('Review Answers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...List.generate(questions.length, (index) {
            final q = questions[index];
            final userAnswerIdx = userAnswers[index];
            final correctIdx = q['answer'];
            final isCorrect = userAnswerIdx == correctIdx;

            return Card(
              color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(q['q'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Your answer: ${userAnswerIdx >= 0 && userAnswerIdx < q['options'].length ? q['options'][userAnswerIdx] : 'None'}', 
                      style: TextStyle(color: isCorrect ? Colors.green : Colors.redAccent)),
                    if (!isCorrect)
                      Text('Correct answer: ${q['options'][correctIdx]}', style: const TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (retriesEnabled)
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Quiz'),
                  onPressed: _retryQuiz,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                ),
              ElevatedButton.icon(
                icon: const Icon(Icons.dashboard),
                label: const Text('Continue'),
                onPressed: () {
                   Navigator.pop(context);
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

