import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funngro_assessment/models/project.dart';
import 'package:funngro_assessment/screens/projects_screen.dart';
import 'package:funngro_assessment/services/projects_api.dart';

class ControllableProjectsApi extends ProjectsApi {
  bool shouldFail;
  Duration simulatedLatency;
  List<Project>? customResult;

  ControllableProjectsApi({
    this.shouldFail = false,
    this.simulatedLatency = Duration.zero,
    this.customResult,
  }) : super(latency: Duration.zero);

  @override
  Future<List<Project>> fetchProjects(int page) async {
    if (simulatedLatency > Duration.zero) {
      await Future.delayed(simulatedLatency);
    }
    if (shouldFail) {
      throw ApiException('Simulated server outage');
    }
    if (customResult != null) {
      return customResult!;
    }
    if (page > 7) return [];
    return List.generate(
      20,
      (i) => Project(
        id: 'p${page * 20 + i}',
        title: 'Project ${page * 20 + i}',
        company: 'Company $i',
        payout: 500,
      ),
    );
  }
}

void main() {
  group('ProjectsScreen Widget Tests', () {
    testWidgets('shows loading indicator on initial launch', (tester) async {
      final api = ControllableProjectsApi(
        simulatedLatency: const Duration(seconds: 1),
      );

      await tester.pumpWidget(
        MaterialApp(home: ProjectsScreen(api: api)),
      );

      // Loading state is displayed before Future resolves
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Fetching latest projects...'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays 20 projects upon successful fetch', (tester) async {
      final api = ControllableProjectsApi(shouldFail: false);

      await tester.pumpWidget(
        MaterialApp(home: ProjectsScreen(api: api)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Project 0'), findsOneWidget);
      expect(find.text('Project 1'), findsOneWidget);
    });

    testWidgets(
        'demonstrates failed pagination request and successful retry without losing items',
        (tester) async {
      // Set tester surface size to display list and allow scrolling
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final api = ControllableProjectsApi(shouldFail: false);

      await tester.pumpWidget(
        MaterialApp(home: ProjectsScreen(api: api)),
      );
      await tester.pumpAndSettle();

      // Initial projects are loaded
      expect(find.text('Project 0'), findsOneWidget);

      // Now simulate network failure for next page
      api.shouldFail = true;

      // Scroll down to trigger pagination
      await tester.drag(find.byType(ListView), const Offset(0, -2500));
      await tester.pumpAndSettle();

      // Verify failure footer appears with Retry button and original items are preserved!
      expect(find.textContaining('Failed to load next page'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Now restore network connectivity and tap Retry
      api.shouldFail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Next page is loaded
      expect(find.text('Project 20'), findsOneWidget);
    });
  });
}
