import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/earning.dart';
import '../../services/earnings_api.dart';
import 'earnings_event.dart';
import 'earnings_state.dart';

/// Business Logic Component managing earnings data, real-time streams, detail queries,
/// and smooth infinite scroll pagination.
class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final EarningsApi _api;
  StreamSubscription<WalletUpdate>? _walletSubscription;

  EarningsBloc({required EarningsApi api})
      : _api = api,
        super(const EarningsState()) {
    on<LoadEarningsEvent>(_onLoadEarnings);
    on<FetchNextEarningsPageEvent>(_onFetchNextEarningsPage);
    on<WalletUpdateReceivedEvent>(_onWalletUpdateReceived);
    on<FetchEarningDetailEvent>(_onFetchEarningDetail);
  }

  Future<void> _onLoadEarnings(
    LoadEarningsEvent event,
    Emitter<EarningsState> emit,
  ) async {
    emit(state.copyWith(
      isRefreshing: state.earnings.isNotEmpty,
      status: state.earnings.isEmpty
          ? EarningsStatus.loading
          : EarningsStatus.success,
      clearErrorMessage: true,
      clearPaginationError: true,
      hasReachedEnd: false,
    ));

    // Cancel prior subscription if user changed
    await _walletSubscription?.cancel();

    // Start listening to real-time wallet stream in the background
    _walletSubscription = _api.walletUpdates(event.userId).listen(
      (update) => add(WalletUpdateReceivedEvent(update)),
      onError: (error) {
        // Stream errors should not crash the state machine
      },
    );

    try {
      final earnings =
          await _api.fetchEarnings(event.userId, page: 0, pageSize: 20);
      emit(state.copyWith(
        isRefreshing: false,
        status: EarningsStatus.success,
        earnings: earnings,
        currentPage: 0,
        hasReachedEnd: earnings.isEmpty,
        clearErrorMessage: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        status: state.earnings.isEmpty
            ? EarningsStatus.failure
            : EarningsStatus.success,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onFetchNextEarningsPage(
    FetchNextEarningsPageEvent event,
    Emitter<EarningsState> emit,
  ) async {
    if (state.isLoadingMore ||
        state.hasReachedEnd ||
        state.status != EarningsStatus.success) {
      return;
    }

    final targetPage = state.currentPage + 1;

    emit(state.copyWith(
      isLoadingMore: true,
      clearPaginationError: true,
    ));

    try {
      final results = await _api.fetchEarnings(
        event.userId,
        page: targetPage,
        pageSize: 20,
      );

      if (results.isEmpty) {
        emit(state.copyWith(
          isLoadingMore: false,
          hasReachedEnd: true,
          clearPaginationError: true,
        ));
      } else {
        final existingIds = state.earnings.map((e) => e.id).toSet();
        final uniqueNew = results.where((e) => !existingIds.contains(e.id));
        final merged = List<Earning>.from(state.earnings)..addAll(uniqueNew);

        emit(state.copyWith(
          isLoadingMore: false,
          earnings: merged,
          currentPage: targetPage,
          clearPaginationError: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        paginationErrorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void _onWalletUpdateReceived(
    WalletUpdateReceivedEvent event,
    Emitter<EarningsState> emit,
  ) {
    final newEarning = event.update.toEarning();
    final updatedList = List<Earning>.from(state.earnings);

    final existingIndex = updatedList.indexWhere((e) => e.id == newEarning.id);
    if (existingIndex >= 0) {
      // Prevent duplicate - update existing entry in place
      updatedList[existingIndex] = newEarning;
    } else {
      // Prepend at index 0
      updatedList.insert(0, newEarning);
    }

    emit(state.copyWith(
      earnings: updatedList,
      latestRealtimeEarning: newEarning,
    ));
  }

  Future<void> _onFetchEarningDetail(
    FetchEarningDetailEvent event,
    Emitter<EarningsState> emit,
  ) async {
    emit(state.copyWith(
      loadingDetailId: event.earning.id,
      clearDetail: true,
    ));

    try {
      final detail = await _api.fetchDetail(event.earning.id, event.earning);
      event.earning.detail = detail;

      emit(state.copyWith(
        loadingDetailId: null,
        currentDetail: detail,
      ));
    } catch (e) {
      emit(state.copyWith(
        loadingDetailId: null,
        errorMessage: 'Failed to load details: $e',
      ));
    }
  }

  @override
  Future<void> close() {
    _walletSubscription?.cancel();
    return super.close();
  }
}
