/// Centralized network configurations and endpoint routes.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.funngro.com/v1';

  // Endpoints
  static const String earnings = '/teen/earnings';
  static const String walletUpdatesStream = '/teen/wallet/stream';
  static String earningDetail(String earningId) => '/teen/earnings/$earningId';

  static const String projects = '/projects/browse';
}
