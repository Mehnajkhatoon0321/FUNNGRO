import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Developer logging utility that formats and prints structured HTTP requests,
/// responses, errors, and WebSocket events in the terminal.
class DeveloperLogger {
  DeveloperLogger._();

  static void logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic body,
  }) {
    final buffer = StringBuffer()
      ..writeln(
          '┌──────────────────────────────────────────────────────────────')
      ..writeln('│ 🌐 [HTTP REQUEST] $method $url');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      buffer.writeln('│ Query: $queryParameters');
    }
    if (body != null) {
      if (body is Map || body is List) {
        final formattedJson =
            const JsonEncoder.withIndent('  ').convert(body);
        for (final line in formattedJson.split('\n')) {
          buffer.writeln('│ $line');
        }
      } else {
        buffer.writeln('│ Body: $body');
      }
    }
    buffer.write(
        '└──────────────────────────────────────────────────────────────');
    debugPrint(buffer.toString());
  }

  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    required String statusMessage,
    dynamic responseData,
  }) {
    final buffer = StringBuffer()
      ..writeln(
          '┌──────────────────────────────────────────────────────────────')
      ..writeln('│ ✅ [HTTP RESPONSE] $statusCode $statusMessage')
      ..writeln('│ URL: $method $url');
    if (responseData != null) {
      if (responseData is Map || responseData is List) {
        final formattedJson =
            const JsonEncoder.withIndent('  ').convert(responseData);
        for (final line in formattedJson.split('\n')) {
          buffer.writeln('│ $line');
        }
      } else {
        buffer.writeln('│ Response: $responseData');
      }
    }
    buffer.write(
        '└──────────────────────────────────────────────────────────────');
    debugPrint(buffer.toString());
  }

  static void logError({
    required String method,
    required String url,
    required dynamic error,
    int statusCode = 500,
  }) {
    final buffer = StringBuffer()
      ..writeln(
          '┌──────────────────────────────────────────────────────────────')
      ..writeln('│ ❌ [HTTP ERROR] $statusCode')
      ..writeln('│ URL: $method $url')
      ..writeln('│ Error: $error')
      ..write(
          '└──────────────────────────────────────────────────────────────');
    debugPrint(buffer.toString());
  }

  static void logWebSocket({
    required String event,
    required dynamic data,
  }) {
    debugPrint('⚡ [WEBSOCKET] $event -> $data');
  }
}
