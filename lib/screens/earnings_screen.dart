import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/earnings/earnings_bloc.dart';
import '../blocs/earnings/earnings_event.dart';
import '../blocs/earnings/earnings_state.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive_layout.dart';
import '../services/earnings_api.dart';
import '../widgets/earning_tile.dart';
import '../widgets/error_view.dart';
import '../widgets/pagination_footer.dart';
import '../widgets/shimmer_loading.dart';
import 'detail_screen.dart';

/// Screen displaying teen earnings history powered by [EarningsBloc].
///
/// Features:
/// 1. Architecture: Strict BLoC pattern separating data fetching from UI.
/// 2. Stream Safety: WebSocket stream managed & cancelled in [EarningsBloc].
/// 3. Performance: Virtualized with [ListView.builder] for 1,000–3,000 items.
/// 4. Zero Main-Thread Jank: Formatted currency precomputed on models.
/// 5. Safe Navigation: Detail routing handled via BLoC listener with mounted safety.
class EarningsScreen extends StatelessWidget {
  final String userId;
  final EarningsApi? api;

  const EarningsScreen({
    super.key,
    required this.userId,
    this.api,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EarningsBloc(
        api: api ?? EarningsApi(),
      )..add(LoadEarningsEvent(userId)),
      child: _EarningsView(userId: userId),
    );
  }
}

class _EarningsView extends StatefulWidget {
  final String userId;

  const _EarningsView({required this.userId});

  @override
  State<_EarningsView> createState() => _EarningsViewState();
}

class _EarningsViewState extends State<_EarningsView> {
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

    final state = context.read<EarningsBloc>().state;
    if (state.isLoadingMore ||
        state.hasReachedEnd ||
        state.paginationErrorMessage != null) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= (maxScroll - 300)) {
      context
          .read<EarningsBloc>()
          .add(FetchNextEarningsPageEvent(widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myEarnings),
        actions: [
          BlocBuilder<EarningsBloc, EarningsState>(
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
                  context
                      .read<EarningsBloc>()
                      .add(LoadEarningsEvent(widget.userId));
                },
              );
            },
          ),
        ],
      ),
      body: ResponsiveLayout.constrainedBody(
        context,
        child: BlocConsumer<EarningsBloc, EarningsState>(
          listenWhen: (previous, current) =>
              previous.currentDetail != current.currentDetail,
          listener: (context, state) {
            // Safe navigation when earning details resolve
            if (state.currentDetail != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(detail: state.currentDetail!),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == EarningsStatus.loading) {
              return const EarningsShimmerList();
            }

            if (state.status == EarningsStatus.failure) {
              return ErrorView(
                message: state.errorMessage ?? AppStrings.somethingWentWrong,
                onRetry: () {
                  context
                      .read<EarningsBloc>()
                      .add(LoadEarningsEvent(widget.userId));
                },
              );
            }

            if (state.earnings.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.savings_outlined,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppStrings.noEarningsTitle,
                        style: AppTextStyles.errorTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.noEarningsSubtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.errorMessage,
                      ),
                    ],
                  ),
                ),
              );
            }

            final showFooter = state.isLoadingMore ||
                state.paginationErrorMessage != null ||
                state.hasReachedEnd;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                final bloc = context.read<EarningsBloc>();
                bloc.add(LoadEarningsEvent(widget.userId));
                await bloc.stream.firstWhere(
                  (state) =>
                      !state.isRefreshing &&
                      state.status != EarningsStatus.loading,
                );
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: 1 + state.earnings.length + (showFooter ? 1 : 0),
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
                                'Earnings Overview',
                                style: AppTextStyles.cardTitle,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${state.earnings.length} completed milestones',
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
                              color: AppColors.successBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fiber_manual_record,
                                  color: AppColors.success,
                                  size: 10,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Live Sync',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.successText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (index > state.earnings.length) {
                    return PaginationFooter(
                      isLoadingMore: state.isLoadingMore,
                      paginationError: state.paginationErrorMessage,
                      hasReachedEnd: state.hasReachedEnd,
                      totalCount: state.earnings.length,
                      onRetry: () {
                        context
                            .read<EarningsBloc>()
                            .add(FetchNextEarningsPageEvent(widget.userId));
                      },
                    );
                  }

                  final earning = state.earnings[index - 1];
                  final isTileLoading = state.loadingDetailId == earning.id;
                  final subtitle =
                      '${earning.date.day}/${earning.date.month}/${earning.date.year}';

                  return EarningTile(
                    key: ValueKey(earning.id),
                    earning: earning,
                    subtitle: subtitle,
                    isLoading: isTileLoading,
                    onTap: () {
                      context
                          .read<EarningsBloc>()
                          .add(FetchEarningDetailEvent(earning));
                    },
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
