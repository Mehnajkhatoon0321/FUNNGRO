import 'package:equatable/equatable.dart';

import '../../models/earning.dart';

abstract class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the screen is first opened or refreshed.
class LoadEarningsEvent extends EarningsEvent {
  final String userId;

  const LoadEarningsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Triggered when scrolling down to load the next page of earnings.
class FetchNextEarningsPageEvent extends EarningsEvent {
  final String userId;

  const FetchNextEarningsPageEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Triggered when a real-time event arrives from the WebSocket wallet stream.
class WalletUpdateReceivedEvent extends EarningsEvent {
  final WalletUpdate update;

  const WalletUpdateReceivedEvent(this.update);

  @override
  List<Object?> get props => [update.id, update.amount];
}

/// Triggered when the user taps on an earning tile to fetch detailed transaction info.
class FetchEarningDetailEvent extends EarningsEvent {
  final Earning earning;

  const FetchEarningDetailEvent(this.earning);

  @override
  List<Object?> get props => [earning.id];
}
