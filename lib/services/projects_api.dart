import 'dart:math';

import '../core/network/api_endpoints.dart';
import '../core/network/developer_logger.dart';
import '../core/network/network_exceptions.dart';
import '../models/project.dart';

/// Exception thrown by the projects API, matching the assessment prompt contract.
class ApiException extends NetworkException {
  ApiException(String message, {int? statusCode})
      : super(
          message: message,
          statusCode: statusCode ?? 500,
        );

  @override
  String toString() => message;
}

/// Service handling project retrieval from [ApiEndpoints.baseUrl].
/// Matches the assessment specification while providing developer request/response logs.
class ProjectsApi {
  final String baseUrl;
  final Random _rng;
  final Duration _latency;

  ProjectsApi({
    String? baseUrl,
    Random? rng,
    Duration latency = const Duration(milliseconds: 900),
  })  : baseUrl = baseUrl ?? ApiEndpoints.baseUrl,
        _rng = rng ?? Random(),
        _latency = latency;

  /// Returns 20 projects per page. Pages 0..7 exist.
  /// ~900ms latency. Fails (throws ApiException) roughly 1 in 5 calls.
  /// Target endpoint: [ApiEndpoints.baseUrl] + [ApiEndpoints.projects]?page=[page]
  Future<List<Project>> fetchProjects(int page) async {
    final url = '$baseUrl${ApiEndpoints.projects}?page=$page';

    DeveloperLogger.logRequest(method: 'GET', url: url);

    try {
      await Future.delayed(_latency);

      // Simulated 1-in-5 failure rate (20% flaky network error)
      if (_rng.nextInt(5) == 0) {
        const errorMsg =
            'Funngro servers are temporarily busy (HTTP 500). Please tap retry.';
        DeveloperLogger.logError(method: 'GET', url: url, error: errorMsg);
        throw ApiException(errorMsg, statusCode: 500);
      }

      // Pages 0..7 exist; page > 7 returns empty list
      if (page > 7) {
        DeveloperLogger.logResponse(
          method: 'GET',
          url: url,
          statusCode: 200,
          statusMessage: 'OK (End of catalog)',
        );
        return [];
      }

      final results = List.generate(
        20,
        (i) => Project(
          id: 'p${page * 20 + i}',
          title: 'Project ${page * 20 + i}',
          company: 'Company ${_rng.nextInt(50)}',
          payout: 200 + _rng.nextInt(1800),
        ),
      );

      DeveloperLogger.logResponse(
        method: 'GET',
        url: url,
        statusCode: 200,
        statusMessage: 'OK',
        responseData: '${results.length} projects loaded',
      );

      return results;
    } catch (e) {
      if (e is ApiException) rethrow;
      final networkError = NetworkException.fromError(e);
      DeveloperLogger.logError(
        method: 'GET',
        url: url,
        error: networkError.message,
        statusCode: networkError.statusCode ?? 500,
      );
      throw networkError;
    }
  }
}
