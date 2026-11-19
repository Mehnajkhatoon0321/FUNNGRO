import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funngro_assessment/models/earning.dart';
import 'package:funngro_assessment/screens/detail_screen.dart';
import 'package:funngro_assessment/screens/earnings_screen.dart';
import 'package:funngro_assessment/services/earnings_api.dart';

class ControllableEarningsApi implements EarningsApi {
  final StreamController<WalletUpdate> _walletController =
      StreamController<WalletUpdate>.broadcast();

  bool shouldFail = false;
  List<Earning> itemsToReturn;

  ControllableEarningsApi({List<Earning>? items})
      : itemsToReturn = items ??
            [
              Earning(
                id: 'e1',
                title: 'Content Writing Project',
                amount: 500,
                date: DateTime(2025, 1, 1),
                category: 'Writing',
              ),
              Earning(
                id: 'e2',
                title: 'Logo Design Review',
                amount: 1200,
                date: DateTime(2025, 1, 2),
                category: 'Design',
              ),
            ];

  @override
  Future<List<Earning>> fetchEarnings(
    String userId, {
    int? page,
    int? pageSize,
  }) async {
    if (shouldFail) {
      throw Exception('Network timeout');
    }
    return itemsToReturn;
  }

  @override
  Stream<WalletUpdate> walletUpdates(String userId) {
    return _walletController.stream;
  }

  @override
  Future<EarningDetail> fetchDetail(String earningId, [Earning? earning]) async {
    return EarningDetail(
      id: earningId,
      projectTitle: earning?.title ?? 'Content Writing Project',
      clientName: 'Funngro Test Client',
      payout: earning?.amount ?? 500,
      completedAt: earning?.date ?? DateTime(2025, 1, 1),
      paymentRef: 'TXN12345',
      status: 'Paid',
    );
  }

  void emitUpdate(WalletUpdate update) {
    _walletController.add(update);
  }

  void dispose() {
    _walletController.close();
  }
}

void main() {
  group('EarningsScreen Widget Tests', () {
    late ControllableEarningsApi api;

    setUp(() {
      api = ControllableEarningsApi();
    });

    tearDown(() {
      api.dispose();
    });

    testWidgets('renders earnings list correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EarningsScreen(userId: 'test_user', api: api),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Content Writing Project'), findsOneWidget);
      expect(find.text('Logo Design Review'), findsOneWidget);
      expect(find.text('₹500'), findsOneWidget);
      expect(find.text('₹1,200'), findsOneWidget);
    });

    testWidgets('navigates to DetailScreen upon tile tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EarningsScreen(userId: 'test_user', api: api),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Content Writing Project'));
      await tester.pumpAndSettle();

      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('Earnings Detail'), findsOneWidget);
      expect(find.text('Funngro Test Client'), findsOneWidget);
    });

    testWidgets('inserts real-time wallet update at top of list',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EarningsScreen(userId: 'test_user', api: api),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Real-time Bug Bounty'), findsNothing);

      // Emit new real-time payout
      api.emitUpdate(
        WalletUpdate(
          id: 'rt_1',
          title: 'Real-time Bug Bounty',
          amount: 800,
          timestamp: DateTime.now(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Real-time Bug Bounty'), findsOneWidget);
      expect(find.text('₹800'), findsOneWidget);
    });
  });
}
