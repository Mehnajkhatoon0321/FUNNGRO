import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/project.dart';
import '../../services/projects_api.dart';
import 'projects_event.dart';
import 'projects_state.dart';

/// Business Logic Component managing project pagination against the flaky fake API.
/// Isolates network requests, page increments, error retries, and deduplication.
class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ProjectsApi _api;

  ProjectsBloc({required ProjectsApi api})
      : _api = api,
        super(const ProjectsState()) {
    on<FetchFirstPageEvent>(_onFetchFirstPage);
    on<FetchNextPageEvent>(_onFetchNextPage);
    on<RetryPaginationEvent>(_onRetryPagination);
  }

  Future<void> _onFetchFirstPage(
    FetchFirstPageEvent event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(state.copyWith(
      isRefreshing: state.projects.isNotEmpty,
      status: state.projects.isEmpty
          ? ProjectsStatus.firstPageLoading
          : ProjectsStatus.loaded,
      clearFirstPageError: true,
      clearPaginationError: true,
      hasReachedEnd: false,
    ));

    try {
      final results = await _api.fetchProjects(0);
      emit(state.copyWith(
        isRefreshing: false,
        status: ProjectsStatus.loaded,
        projects: results,
        currentPage: 0,
        hasReachedEnd: results.isEmpty,
        clearFirstPageError: true,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        status: state.projects.isEmpty
            ? ProjectsStatus.firstPageError
            : ProjectsStatus.loaded,
        firstPageErrorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        status: state.projects.isEmpty
            ? ProjectsStatus.firstPageError
            : ProjectsStatus.loaded,
        firstPageErrorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onFetchNextPage(
    FetchNextPageEvent event,
    Emitter<ProjectsState> emit,
  ) async {
    // Guard against concurrent pagination or requests when at end of list
    if (state.isLoadingMore ||
        state.hasReachedEnd ||
        state.status != ProjectsStatus.loaded) {
      return;
    }

    final targetPage = state.currentPage + 1;

    emit(state.copyWith(
      isLoadingMore: true,
      clearPaginationError: true,
    ));

    try {
      final results = await _api.fetchProjects(targetPage);

      if (results.isEmpty) {
        emit(state.copyWith(
          isLoadingMore: false,
          hasReachedEnd: true,
          clearPaginationError: true,
        ));
      } else {
        // Prevent duplicate items when merging
        final existingIds = state.projects.map((p) => p.id).toSet();
        final uniqueNew = results.where((p) => !existingIds.contains(p.id));
        final merged = List<Project>.from(state.projects)..addAll(uniqueNew);

        emit(state.copyWith(
          isLoadingMore: false,
          projects: merged,
          currentPage: targetPage,
          clearPaginationError: true,
        ));
      }
    } on ApiException catch (e) {
      // Keep previously loaded items intact, surface error on footer
      emit(state.copyWith(
        isLoadingMore: false,
        paginationErrorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        paginationErrorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onRetryPagination(
    RetryPaginationEvent event,
    Emitter<ProjectsState> emit,
  ) async {
    await _onFetchNextPage(const FetchNextPageEvent(), emit);
  }
}
