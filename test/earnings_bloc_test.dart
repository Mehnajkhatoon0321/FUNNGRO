import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:funngro_assessment/blocs/earnings/earnings_bloc.dart';
import 'package:funngro_assessment/blocs/earnings/earnings_event.dart';
import 'package:funngro_assessment/blocs/earnings/earnings_state.dart';
import 'package:funngro_assessment/models/earning.dart';
import 'package:funngro_assessment/services/earnings_api.dart';

class MockTestEarningsApi implements EarningsApi {
  final StreamController<WalletUpdate> _controller =
      StreamController<WalletUpdate>.broadcast();

  bool shouldFail = false;

  @override
  Future<List<Earning>> fetchEarnings(
    String userId, {
    int? page,
    int? pageSize,
  }) async {
    if (shouldFail) throw Exception('API Error');
    return [
      Earning(
        id: 'e1',
        title: 'Project 1',
        amount: 500,
        date: DateTime(2025, 1, 1),
      ),
    ];
  }

  @override
  Stream<WalletUpdate> walletUpdates(String userId) => _controller.stream;

  @override
  Future<EarningDetail> fetchDetail(String earningId, [Earning? earning]) async {
    return EarningDetail(
      id: earningId,
      projectTitle: earning?.title ?? 'Project 1',
      clientName: 'Client X',
      payout: earning?.amount ?? 500,
      completedAt: earning?.date ?? DateTime(2025, 1, 1),
      paymentRef: 'TX123',
      status: 'Paid',
    );
  }

  void emit(WalletUpdate update) => _controller.add(update);
  void dispose() => _controller.close();
}

void main() {
  group('EarningsBloc Unit Tests', () {
    late MockTestEarningsApi api;
    late EarningsBloc bloc;

    setUp(() {
      api = MockTestEarningsApi();
      bloc = EarningsBloc(api: api);
    });

    tearDown(() {
      bloc.close();
      api.dispose();
    });

    test('initial state has initial status and empty list', () {
      expect(bloc.state.status, EarningsStatus.initial);
      expect(bloc.state.earnings, isEmpty);
    });

    test('LoadEarningsEvent emits [loading, success] on successful fetch',
        () async {
      bloc.add(const LoadEarningsEvent('user_1'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const EarningsState(status: EarningsStatus.loading),
          predicate<EarningsState>((state) =>
              state.status == EarningsStatus.success &&
              state.earnings.length == 1 &&
              state.earnings.first.id == 'e1'),
        ]),
      );
    });

    test('LoadEarningsEvent emits [loading, failure] when API throws',
        () async {
      api.shouldFail = true;
      bloc.add(const LoadEarningsEvent('user_1'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const EarningsState(status: EarningsStatus.loading),
          predicate<EarningsState>((state) =>
              state.status == EarningsStatus.failure &&
              state.errorMessage!.contains('API Error')),
        ]),
      );
    });

    test(
        'WalletUpdateReceivedEvent prepends update without duplicating existing IDs',
        () async {
      bloc.add(const LoadEarningsEvent('user_1'));
      await Future.delayed(const Duration(milliseconds: 50));

      final newUpdate = WalletUpdate(
        id: 'rt_new',
        title: 'New Gig Payout',
        amount: 800,
        timestamp: DateTime.now(),
      );

      bloc.add(WalletUpdateReceivedEvent(newUpdate));

      await expectLater(
        bloc.stream,
        emits(
          predicate<EarningsState>((state) =>
              state.earnings.length == 2 &&
              state.earnings.first.id == 'rt_new' &&
              state.latestRealtimeEarning?.id == 'rt_new'),
        ),
      );
    });
  });
}
