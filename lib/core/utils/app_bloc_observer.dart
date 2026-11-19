import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Global BLoC observer that logs all events, transitions, and errors to the terminal.
class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('🔷 [BLoC Event] ${bloc.runtimeType} -> $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('🔄 [BLoC State] ${bloc.runtimeType} ➔ ${change.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('❌ [BLoC Error] ${bloc.runtimeType} -> $error');
  }
}
