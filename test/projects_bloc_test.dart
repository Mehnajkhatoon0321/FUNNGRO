import 'package:flutter_test/flutter_test.dart';
import 'package:funngro_assessment/blocs/projects/projects_bloc.dart';
import 'package:funngro_assessment/blocs/projects/projects_event.dart';
import 'package:funngro_assessment/blocs/projects/projects_state.dart';
import 'package:funngro_assessment/models/project.dart';
import 'package:funngro_assessment/services/projects_api.dart';

class ControllableProjectsApi extends ProjectsApi {
  bool shouldFail;
  List<Project>? customResult;

  ControllableProjectsApi({
    this.shouldFail = false,
    this.customResult,
  }) : super(latency: Duration.zero);

  @override
  Future<List<Project>> fetchProjects(int page) async {
    if (shouldFail) {
      throw ApiException('Simulated network outage');
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
  group('ProjectsBloc Unit Tests', () {
    late ControllableProjectsApi api;
    late ProjectsBloc bloc;

    setUp(() {
      api = ControllableProjectsApi();
      bloc = ProjectsBloc(api: api);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has initial status and empty projects', () {
      expect(bloc.state.status, ProjectsStatus.initial);
      expect(bloc.state.projects, isEmpty);
      expect(bloc.state.currentPage, 0);
    });

    test('FetchFirstPageEvent loads 20 items successfully', () async {
      bloc.add(const FetchFirstPageEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProjectsState>(
              (s) => s.status == ProjectsStatus.firstPageLoading),
          predicate<ProjectsState>((s) =>
              s.status == ProjectsStatus.loaded &&
              s.projects.length == 20 &&
              s.currentPage == 0 &&
              !s.hasReachedEnd),
        ]),
      );
    });

    test('FetchFirstPageEvent emits firstPageError on failure', () async {
      api.shouldFail = true;
      bloc.add(const FetchFirstPageEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProjectsState>(
              (s) => s.status == ProjectsStatus.firstPageLoading),
          predicate<ProjectsState>((s) =>
              s.status == ProjectsStatus.firstPageError &&
              s.firstPageErrorMessage!.contains('Simulated network outage')),
        ]),
      );
    });

    test('FetchNextPageEvent appends items without losing previous ones',
        () async {
      // First page
      bloc.add(const FetchFirstPageEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      // Second page
      bloc.add(const FetchNextPageEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProjectsState>((s) => s.isLoadingMore),
          predicate<ProjectsState>((s) =>
              !s.isLoadingMore &&
              s.projects.length == 40 &&
              s.currentPage == 1),
        ]),
      );
    });

    test('FetchNextPageEvent preserves projects when page fails', () async {
      // Load page 0 successfully
      bloc.add(const FetchFirstPageEvent());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.projects.length, 20);

      // Next page fails
      api.shouldFail = true;
      bloc.add(const FetchNextPageEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<ProjectsState>((s) => s.isLoadingMore),
          predicate<ProjectsState>((s) =>
              !s.isLoadingMore &&
              s.projects.length == 20 && // 20 projects still retained!
              s.paginationErrorMessage != null),
        ]),
      );
    });
  });
}
