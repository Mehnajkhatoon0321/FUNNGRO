import 'dart:async';
import 'dart:io';

/// Centralized exception class providing clear, human-readable error messages
/// for all network, HTTP, socket, and parsing failures across the app.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;

  /// Translates raw exceptions into friendly, actionable messages for teen users.
  factory NetworkException.fromError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }

    if (error is SocketException) {
      return const NetworkException(
        message:
            'No internet connection. Please check your mobile data or Wi-Fi network and tap retry.',
        statusCode: 0,
      );
    }

    if (error is TimeoutException) {
      return const NetworkException(
        message:
            'Connection timed out. Please check your network connection and try again.',
        statusCode: 408,
      );
    }

    if (error is FormatException) {
      return const NetworkException(
        message: 'Unable to process server response. Please try again.',
      );
    }

    // String check for common network/DNS failure messages
    final errorStr = error.toString().replaceFirst('Exception: ', '');
    final lower = errorStr.toLowerCase();
    if (lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('no address associated') ||
        lower.contains('clientexception') ||
        lower.contains('socket') ||
        lower.contains('network error') ||
        lower.contains('offline')) {
      return const NetworkException(
        message:
            'No internet connection. Please check your mobile data or Wi-Fi network and tap retry.',
        statusCode: 0,
      );
    }
    return NetworkException(
      message:
          errorStr.isEmpty ? 'An unexpected network error occurred.' : errorStr,
    );
  }
}
