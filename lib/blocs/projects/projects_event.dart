import 'package:equatable/equatable.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch initial page (page 0), triggered on initial screen load or pull-to-refresh.
class FetchFirstPageEvent extends ProjectsEvent {
  const FetchFirstPageEvent();
}

/// Fetch the next page of projects during scrolling.
class FetchNextPageEvent extends ProjectsEvent {
  const FetchNextPageEvent();
}

/// Retry the failed subsequent page without losing previously loaded projects.
class RetryPaginationEvent extends ProjectsEvent {
  const RetryPaginationEvent();
}
