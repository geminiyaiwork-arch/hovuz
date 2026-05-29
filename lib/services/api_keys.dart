/// Optional API keys for higher rate limits. Free public keys ship as default.
/// User can override via Settings → save to SharedPreferences and pass into services.
class ApiKeys {
  /// Etherscan free public key (low rate limit ~5 req/s).
  /// Get a personal one at https://etherscan.io/myapikey and override at runtime.
  static const String etherscanDefault = 'YourApiKeyToken';

  /// BscScan free public key (~5 req/s).
  /// https://bscscan.com/myapikey
  static const String bscscanDefault = 'YourApiKeyToken';

  /// TronGrid is keyless for low-traffic. Optional for production.
  /// https://www.trongrid.io/
  static const String tronGridDefault = '';
}
