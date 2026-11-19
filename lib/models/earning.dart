import '../core/utils/currency_formatter.dart';

/// Represents a single earning entry.
class Earning {
  final String id;
  final String title;
  final num amount;
  final DateTime date;
  final String? category;
  EarningDetail? detail;

  // Cached formatted string to prevent expensive locale parsing during list render
  late final String formattedAmount;

  Earning({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category,
    this.detail,
    String? preformattedAmount,
  }) {
    formattedAmount = preformattedAmount ?? formatCurrency(amount);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        if (category != null) 'category': category,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Earning && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents detail information for an earning entry.
class EarningDetail {
  final String id;
  final String projectTitle;
  final String clientName;
  final num payout;
  final DateTime completedAt;
  final String paymentRef;
  final String status;
  final String? category;
  final String? paymentMode;

  EarningDetail({
    required this.id,
    required this.projectTitle,
    required this.clientName,
    required this.payout,
    required this.completedAt,
    required this.paymentRef,
    required this.status,
    this.category,
    this.paymentMode,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectTitle': projectTitle,
        'clientName': clientName,
        'payout': payout,
        'completedAt': completedAt.toIso8601String(),
        'paymentRef': paymentRef,
        'status': status,
        if (category != null) 'category': category,
        if (paymentMode != null) 'paymentMode': paymentMode,
      };
}

/// Real-time wallet update emitted by the walletUpdates stream.
class WalletUpdate {
  final String id;
  final String title;
  final num amount;
  final DateTime timestamp;

  WalletUpdate({
    required this.id,
    required this.title,
    required this.amount,
    required this.timestamp,
  });

  /// Converts the real-time update into a full [Earning] entity.
  Earning toEarning() {
    return Earning(
      id: id,
      title: title,
      amount: amount,
      date: timestamp,
      category: 'Real-time Payout',
    );
  }
}
