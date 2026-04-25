import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/ui/app_components.dart';
import 'package:frontend/ui/eduquest_theme.dart';

void main() {
  testWidgets('AppEmptyState renders title and action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildEduQuestTheme(),
        home: const Scaffold(
          body: AppEmptyState(
            icon: Icons.school_outlined,
            title: 'Empty title',
            description: 'Empty description',
            actionLabel: 'Retry',
            onAction: _noop,
          ),
        ),
      ),
    );

    expect(find.text('Empty title'), findsOneWidget);
    expect(find.text('Empty description'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('AppStatusBanner renders message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildEduQuestTheme(),
        home: const Scaffold(
          body: AppStatusBanner(
            message: 'Everything synced',
            color: EduQuestColors.success,
            icon: Icons.check_circle_outline,
          ),
        ),
      ),
    );

    expect(find.text('Everything synced'), findsOneWidget);
  });
}

void _noop() {}
