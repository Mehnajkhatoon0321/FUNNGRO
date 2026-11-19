import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:funngro_assessment/services/projects_api.dart';

// Deterministic Random for testing
class DeterministicRandom implements Random {
  final int nextIntResult;
  DeterministicRandom(this.nextIntResult);

  @override
  int nextInt(int max) => nextIntResult;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0.0;
}

void main() {
  group('ProjectsApi Tests', () {
    test('fetchProjects returns 20 items for valid page 0', () async {
      final api = ProjectsApi(
        rng: DeterministicRandom(1), // nextInt(5) != 0, so no failure
        latency: Duration.zero,
      );

      final projects = await api.fetchProjects(0);
      expect(projects.length, 20);
      expect(projects.first.id, 'p0');
      expect(projects.last.id, 'p19');
    });

    test('fetchProjects returns empty list for page > 7', () async {
      final api = ProjectsApi(
        rng: DeterministicRandom(1),
        latency: Duration.zero,
      );

      final projects = await api.fetchProjects(8);
      expect(projects, isEmpty);
    });

    test('fetchProjects throws ApiException when random returns 0', () async {
      final api = ProjectsApi(
        rng: DeterministicRandom(0), // triggers error: nextInt(5) == 0
        latency: Duration.zero,
      );

      expect(() => api.fetchProjects(0), throwsA(isA<ApiException>()));
    });
  });
}
