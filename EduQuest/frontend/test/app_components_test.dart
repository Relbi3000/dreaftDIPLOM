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

  testWidgets('ResponsiveStatsGrid stacks on narrow widths', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildEduQuestTheme(),
        home: Scaffold(
          body: ResponsiveStatsGrid(
            children: const [
              AppStatCard(
                label: 'XP',
                value: '1200',
                icon: Icons.bolt_outlined,
                color: EduQuestColors.primary,
              ),
              AppStatCard(
                label: 'Level',
                value: '4',
                icon: Icons.stars_outlined,
                color: EduQuestColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );

    final xpTopLeft = tester.getTopLeft(find.text('1200'));
    final levelTopLeft = tester.getTopLeft(find.text('4'));
    expect(levelTopLeft.dy, greaterThan(xpTopLeft.dy));
  });

  testWidgets('EduQuestShell keeps subtitle out of app bar title', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildEduQuestTheme(),
        home: EduQuestShell(
          title: 'Teacher workspace',
          subtitle: 'Compact subtitle inside shell body',
          currentIndex: 0,
          destinations: const [
            ShellDestination(label: 'One', icon: Icons.looks_one_outlined),
            ShellDestination(label: 'Two', icon: Icons.looks_two_outlined),
          ],
          onSelect: _noopSelect,
          child: const SizedBox.expand(),
        ),
      ),
    );

    expect(find.text('Teacher workspace'), findsOneWidget);
    expect(find.text('Compact subtitle inside shell body'), findsOneWidget);
    expect(find.byType(AppShellIntro), findsOneWidget);
  });
}

void _noop() {}
void _noopSelect(int _) {}
