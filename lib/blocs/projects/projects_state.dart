import 'package:equatable/equatable.dart';

import '../../models/project.dart';

enum ProjectsStatus { initial, firstPageLoading, firstPageError, loaded }

class ProjectsState extends Equatable {
  final ProjectsStatus status;
  final List<Project> projects;
  final int currentPage;
  final String? firstPageErrorMessage;
  final bool isLoadingMore;
  final String? paginationErrorMessage;
  final bool hasReachedEnd;
  final bool isRefreshing;

  const ProjectsState({
    this.status = ProjectsStatus.initial,
    this.projects = const [],
    this.currentPage = 0,
    this.firstPageErrorMessage,
    this.isLoadingMore = false,
    this.paginationErrorMessage,
    this.hasReachedEnd = false,
    this.isRefreshing = false,
  });

  ProjectsState copyWith({
    ProjectsStatus? status,
    List<Project>? projects,
    int? currentPage,
    String? firstPageErrorMessage,
    bool? isLoadingMore,
    String? paginationErrorMessage,
    bool? hasReachedEnd,
    bool? isRefreshing,
    bool clearFirstPageError = false,
    bool clearPaginationError = false,
  }) {
    return ProjectsState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      currentPage: currentPage ?? this.currentPage,
      firstPageErrorMessage: clearFirstPageError
          ? null
          : (firstPageErrorMessage ?? this.firstPageErrorMessage),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationErrorMessage: clearPaginationError
          ? null
          : (paginationErrorMessage ?? this.paginationErrorMessage),
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  String toString() =>
      'ProjectsState(status: $status, page: $currentPage, count: ${projects.length}${firstPageErrorMessage != null ? ', error: $firstPageErrorMessage' : ''})';

  @override
  List<Object?> get props => [
        status,
        projects,
        currentPage,
        firstPageErrorMessage,
        isLoadingMore,
        paginationErrorMessage,
        hasReachedEnd,
        isRefreshing,
      ];
}
