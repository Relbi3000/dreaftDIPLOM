import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'ui/eduquest_theme.dart';

void main() {
  runApp(const EduQuestApp());
}

class EduQuestApp extends StatelessWidget {
  const EduQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduQuest',
      theme: buildEduQuestTheme(),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
