import 'package:equatable/equatable.dart';

import '../../models/earning.dart';

enum EarningsStatus { initial, loading, success, failure }

class EarningsState extends Equatable {
  final EarningsStatus status;
  final List<Earning> earnings;
  final int currentPage;
  final String? errorMessage;
  final String? loadingDetailId;
  final EarningDetail? currentDetail;
  final Earning? latestRealtimeEarning;
  final bool isLoadingMore;
  final String? paginationErrorMessage;
  final bool hasReachedEnd;
  final bool isRefreshing;

  const EarningsState({
    this.status = EarningsStatus.initial,
    this.earnings = const [],
    this.currentPage = 0,
    this.errorMessage,
    this.loadingDetailId,
    this.currentDetail,
    this.latestRealtimeEarning,
    this.isLoadingMore = false,
    this.paginationErrorMessage,
    this.hasReachedEnd = false,
    this.isRefreshing = false,
  });

  EarningsState copyWith({
    EarningsStatus? status,
    List<Earning>? earnings,
    int? currentPage,
    String? errorMessage,
    String? loadingDetailId,
    EarningDetail? currentDetail,
    Earning? latestRealtimeEarning,
    bool? isLoadingMore,
    String? paginationErrorMessage,
    bool? hasReachedEnd,
    bool? isRefreshing,
    bool clearDetail = false,
    bool clearRealtimeEarning = false,
    bool clearErrorMessage = false,
    bool clearPaginationError = false,
  }) {
    return EarningsState(
      status: status ?? this.status,
      earnings: earnings ?? this.earnings,
      currentPage: currentPage ?? this.currentPage,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      loadingDetailId: loadingDetailId,
      currentDetail: clearDetail ? null : (currentDetail ?? this.currentDetail),
      latestRealtimeEarning: clearRealtimeEarning
          ? null
          : (latestRealtimeEarning ?? this.latestRealtimeEarning),
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
      'EarningsState(status: $status, count: ${earnings.length}, page: $currentPage${errorMessage != null ? ', error: $errorMessage' : ''})';

  @override
  List<Object?> get props => [
        status,
        earnings,
        currentPage,
        errorMessage,
        loadingDetailId,
        currentDetail?.id,
        latestRealtimeEarning?.id,
        isLoadingMore,
        paginationErrorMessage,
        hasReachedEnd,
        isRefreshing,
      ];
}
