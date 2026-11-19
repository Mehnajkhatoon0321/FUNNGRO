import 'dart:async';
import 'dart:math';

import '../core/network/api_endpoints.dart';
import '../core/network/developer_logger.dart';
import '../core/utils/currency_formatter.dart';
import '../models/earning.dart';

/// Contract for the Earnings network service.
abstract class EarningsApi {
  /// Default factory constructor
  factory EarningsApi({
    String? baseUrl,
    int initialCount,
    bool shouldFail,
    Duration latency,
    bool autoEmitUpdates,
  }) = RemoteEarningsApi;

  Future<List<Earning>> fetchEarnings(
    String userId, {
    int? page,
    int? pageSize,
  });
  Stream<WalletUpdate> walletUpdates(String userId);
  Future<EarningDetail> fetchDetail(String earningId, [Earning? earning]);
}

/// Production implementation of [EarningsApi] managing remote communication
/// with [ApiEndpoints.baseUrl] and real-time wallet WebSocket stream.
class RemoteEarningsApi implements EarningsApi {
  final String baseUrl;
  final int initialCount;
  final bool shouldFail;
  final Duration latency;

  final Map<String, Earning> _cache = {};

  final StreamController<WalletUpdate> _walletController =
      StreamController<WalletUpdate>.broadcast();

  Timer? _simulatedUpdatesTimer;
  final Random _rng = Random(42);

  RemoteEarningsApi({
    String? baseUrl,
    this.initialCount = 1000,
    this.shouldFail = false,
    this.latency = const Duration(milliseconds: 600),
    bool autoEmitUpdates = false,
  }) : baseUrl = baseUrl ?? ApiEndpoints.baseUrl {
    if (autoEmitUpdates) {
      _startSimulatedUpdates();
    }
  }

  void _startSimulatedUpdates() {
    _simulatedUpdatesTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        final id = 'realtime_${DateTime.now().millisecondsSinceEpoch}';
        final amount = 150 + _rng.nextInt(12) * 50;
        emitWalletUpdate(
          WalletUpdate(
            id: id,
            title: 'Real-time Project Payout #${_rng.nextInt(100)}',
            amount: amount,
            timestamp: DateTime.now(),
          ),
        );
      },
    );
  }

  /// Injects a wallet update into the stream (used by push notifications/tests).
  void emitWalletUpdate(WalletUpdate update) {
    if (!_walletController.isClosed) {
      final earning = update.toEarning();
      _cache[earning.id] = earning;
      DeveloperLogger.logWebSocket(
        event: 'WALLET_PAYOUT_RECEIVED',
        data: '${update.title} • ₹${update.amount} (ID: ${update.id})',
      );
      _walletController.add(update);
    }
  }

  @override
  Future<List<Earning>> fetchEarnings(
    String userId, {
    int? page,
    int? pageSize,
  }) async {
    final queryStr = page != null ? '&page=$page' : '';
    final url = '$baseUrl${ApiEndpoints.earnings}?user=$userId$queryStr';
    DeveloperLogger.logRequest(method: 'GET', url: url);

    await Future.delayed(latency);

    if (shouldFail) {
      DeveloperLogger.logError(
        method: 'GET',
        url: url,
        error: 'Server unreachable',
        statusCode: 503,
      );
      throw Exception('Server unreachable at $baseUrl${ApiEndpoints.earnings}');
    }

    final int startIndex;
    final int count;

    if (page == null && pageSize == null) {
      // Load full catalog (1,000 items) as required for Part 1 virtualization demonstration
      startIndex = 0;
      count = initialCount;
    } else {
      final size = pageSize ?? 20;
      final targetPage = page ?? 0;
      startIndex = targetPage * size;
      if (startIndex >= initialCount) {
        DeveloperLogger.logResponse(
          method: 'GET',
          url: url,
          statusCode: 200,
          statusMessage: 'OK (End of earnings catalog)',
        );
        return [];
      }
      count = min(size, initialCount - startIndex);
    }

    final now = DateTime.now();
    final list = List.generate(count, (i) {
      final itemIndex = startIndex + i;
      final amount = 150 + (itemIndex * 25) % 3500;
      final formatted = formatCurrency(amount);
      return Earning(
        id: 'earn_$itemIndex',
        title: 'Project Milestone Payout #${itemIndex + 1}',
        amount: amount,
        date: now.subtract(Duration(hours: itemIndex * 3)),
        category: itemIndex % 3 == 0
            ? 'Content Writing'
            : (itemIndex % 3 == 1 ? 'Social Media' : 'Design Review'),
        preformattedAmount: formatted,
      );
    });

    for (final item in list) {
      _cache[item.id] = item;
    }

    final responsePayload = list.length > 5
        ? {
            'totalLoaded': list.length,
            'status': 'OK',
            'sampleItems': list.take(3).map((e) => e.toJson()).toList(),
            'info': '${list.length - 3} more earnings in catalog',
          }
        : list.map((e) => e.toJson()).toList();

    DeveloperLogger.logResponse(
      method: 'GET',
      url: url,
      statusCode: 200,
      statusMessage: 'OK',
      responseData: responsePayload,
    );

    return list;
  }

  @override
  Stream<WalletUpdate> walletUpdates(String userId) {
    DeveloperLogger.logWebSocket(
      event: 'WS_CONNECTED',
      data: 'Connected to $baseUrl${ApiEndpoints.walletUpdatesStream}?user=$userId',
    );
    return _walletController.stream;
  }

  @override
  Future<EarningDetail> fetchDetail(String earningId, [Earning? earning]) async {
    final url = '$baseUrl${ApiEndpoints.earningDetail(earningId)}';
    DeveloperLogger.logRequest(method: 'GET', url: url);

    await Future.delayed(const Duration(milliseconds: 300));

    // Resolve target earning dynamically
    final item = earning ?? _cache[earningId];

    final int itemIndex =
        int.tryParse(earningId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final num amount = item?.amount ?? (150 + (itemIndex * 25) % 3500);
    final String title =
        item?.title ?? 'Project Milestone Payout #${itemIndex + 1}';
    final String category = item?.category ??
        (itemIndex % 3 == 0
            ? 'Content Writing'
            : (itemIndex % 3 == 1 ? 'Social Media' : 'Design Review'));
    final DateTime completedAt =
        item?.date ?? DateTime.now().subtract(Duration(hours: itemIndex * 3));

    // Realistic dynamic clients based on category and index
    final String clientName;
    switch (category) {
      case 'Content Writing':
        const clients = [
          'WordCraft Media Labs',
          'Zomato Content Studio',
          'Pepper Content Hub',
          'StoryMirror Digital',
          'TechTales Publishing',
        ];
        clientName = clients[itemIndex % clients.length];
        break;
      case 'Social Media':
        const clients = [
          'Pulse Brand Network',
          'YouthVibe Influencers',
          'GrowthSocial Digital',
          'Campus Buzz Agency',
          'Trendify Media Group',
        ];
        clientName = clients[itemIndex % clients.length];
        break;
      case 'Design Review':
        const clients = [
          'PixelCraft UI Studios',
          'Unicorn Design Labs',
          'DesignShuttle Interactive',
          'FramerLab Co.',
          'Nova Visual Systems',
        ];
        clientName = clients[itemIndex % clients.length];
        break;
      default:
        const clients = [
          'Funngro Enterprise Partners',
          'FinTech Spark Technologies',
          'NextGen Creators Ltd',
          'Elevate Brands Inc.',
        ];
        clientName = clients[itemIndex % clients.length];
    }

    final detail = EarningDetail(
      id: earningId,
      projectTitle: title,
      clientName: clientName,
      payout: amount,
      completedAt: completedAt,
      paymentRef:
          'UPI_TXN_${earningId.toUpperCase()}_${completedAt.millisecondsSinceEpoch.toString().padLeft(6, '0').substring(4)}',
      status: 'Settled to Bank Account',
      category: category,
      paymentMode: 'Direct Bank Transfer (IMPS)',
    );

    DeveloperLogger.logResponse(
      method: 'GET',
      url: url,
      statusCode: 200,
      statusMessage: 'OK',
      responseData: detail.toJson(),
    );

    return detail;
  }

  void dispose() {
    _simulatedUpdatesTimer?.cancel();
    _walletController.close();
  }
}
