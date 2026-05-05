import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/ui/eduquest_theme.dart';

void main() {
  testWidgets('LoginScreen renders product shell and demo accounts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: buildEduQuestTheme(), home: const LoginScreen()),
    );

    expect(find.text('EduQuest'), findsWidgets);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create account'), findsWidgets);
    expect(find.text('Quick demo access'), findsOneWidget);
    expect(find.textContaining('Student demo'), findsOneWidget);
    expect(find.textContaining('Teacher demo'), findsOneWidget);
    expect(find.textContaining('Admin demo'), findsOneWidget);
  });
}
