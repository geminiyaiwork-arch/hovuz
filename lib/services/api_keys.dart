/// Optional API keys for higher rate limits. Free public keys ship as default.
/// User can override via Settings → save to SharedPreferences and pass into services.
class ApiKeys {
  /// Etherscan V2 multi-chain key — works for ETH, BSC, Polygon, Arbitrum,
  /// Optimism, Base under a single endpoint (api.etherscan.io/v2/api).
  /// Users can override at runtime via Settings page → ApiKeysService.
  static const String etherscanDefault =
      'WXKXNECDDGVX18TKM28495KJF6XA4ERWT7';

  /// Legacy BscScan key — V2 unifies under etherscanDefault, but kept for
  /// older code paths.
  static const String bscscanDefault =
      'WXKXNECDDGVX18TKM28495KJF6XA4ERWT7';

  /// TronGrid is keyless for low-traffic. Optional for production.
  /// https://www.trongrid.io/
  static const String tronGridDefault = '';
}
