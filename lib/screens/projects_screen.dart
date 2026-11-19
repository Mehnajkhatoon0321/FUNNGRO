import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/projects/projects_bloc.dart';
import '../blocs/projects/projects_event.dart';
import '../blocs/projects/projects_state.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive_layout.dart';
import '../services/projects_api.dart';
import '../widgets/error_view.dart';
import '../widgets/pagination_footer.dart';
import '../widgets/project_card.dart';
import '../widgets/shimmer_loading.dart';

/// Screen demonstrating infinite scroll pagination driven by [ProjectsBloc].
///
/// Features:
/// 1. Architecture: API calls isolated strictly inside [ProjectsBloc].
/// 2. Flaky Network Resilience: Retains existing items on subsequent page failures.
/// 3. Virtualization: [ListView.builder] with footer indicator for infinite scroll.
/// 4. Theme & Typography: Strict adherence to centralized [AppColors] & [AppTextStyles].
class ProjectsScreen extends StatelessWidget {
  final ProjectsApi? api;

  const ProjectsScreen({super.key, this.api});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectsBloc(
        api: api ?? ProjectsApi(),
      )..add(const FetchFirstPageEvent()),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatefulWidget {
  const _ProjectsView();

  @override
  State<_ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<_ProjectsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final state = context.read<ProjectsBloc>().state;
    if (state.isLoadingMore ||
        state.hasReachedEnd ||
        state.paginationErrorMessage != null) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Trigger next page fetch when within 300px from the bottom
    if (currentScroll >= (maxScroll - 300)) {
      context.read<ProjectsBloc>().add(const FetchNextPageEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.exploreProjects),
        actions: [
          BlocBuilder<ProjectsBloc, ProjectsState>(
            buildWhen: (previous, current) =>
                previous.isRefreshing != current.isRefreshing,
            builder: (context, state) {
              if (state.isRefreshing) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: AppStrings.refresh,
                onPressed: () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                  context.read<ProjectsBloc>().add(const FetchFirstPageEvent());
                },
              );
            },
          ),
        ],
      ),
      body: ResponsiveLayout.constrainedBody(
        context,
        child: BlocConsumer<ProjectsBloc, ProjectsState>(
          listenWhen: (previous, current) =>
              current.firstPageErrorMessage != null &&
              previous.firstPageErrorMessage != current.firstPageErrorMessage &&
              current.projects.isNotEmpty,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.firstPageErrorMessage!),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          },
          builder: (context, state) {
            // When initial list is empty, show shimmer loading or full-screen error
            if (state.projects.isEmpty) {
              if (state.status == ProjectsStatus.firstPageLoading ||
                  state.status == ProjectsStatus.initial) {
                return const ProjectsShimmerList();
              }

              if (state.status == ProjectsStatus.firstPageError) {
                return ErrorView(
                  title: AppStrings.couldNotLoadProjects,
                  message: state.firstPageErrorMessage ??
                      AppStrings.somethingWentWrong,
                  onRetry: () {
                    context
                        .read<ProjectsBloc>()
                        .add(const FetchFirstPageEvent());
                  },
                );
              }

              return const Center(
                child: Text(
                  AppStrings.noProjectsAvailable,
                  style: AppTextStyles.bodySecondary,
                ),
              );
            }

            // When projects are loaded, render list with pagination footer
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                final bloc = context.read<ProjectsBloc>();
                bloc.add(const FetchFirstPageEvent());
                await bloc.stream.firstWhere(
                  (state) =>
                      !state.isRefreshing &&
                      state.status != ProjectsStatus.firstPageLoading,
                );
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: 1 + state.projects.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Explore Projects',
                                style: AppTextStyles.cardTitle,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${state.projects.length} opportunities available',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  color: AppColors.primary,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Infinite Feed',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (index == state.projects.length + 1) {
                    return PaginationFooter(
                      isLoadingMore: state.isLoadingMore,
                      paginationError: state.paginationErrorMessage,
                      hasReachedEnd: state.hasReachedEnd,
                      totalCount: state.projects.length,
                      onRetry: () {
                        context
                            .read<ProjectsBloc>()
                            .add(const RetryPaginationEvent());
                      },
                    );
                  }

                  final project = state.projects[index - 1];
                  return ProjectCard(
                    key: ValueKey(project.id),
                    project: project,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
