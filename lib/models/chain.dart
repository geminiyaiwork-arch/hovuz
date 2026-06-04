enum Chain {
  bitcoin('BTC', 'Bitcoin', 'BTC'),
  ethereum('ETH', 'Ethereum', 'ETH'),
  tron('TRX', 'TRON', 'TRX'),
  bsc('BSC', 'BNB Chain', 'BNB'),
  solana('SOL', 'Solana', 'SOL'),
  polygon('POL', 'Polygon', 'POL'),
  arbitrum('ARB', 'Arbitrum One', 'ETH'),
  optimism('OP', 'Optimism', 'ETH'),
  base('BASE', 'Base', 'ETH');

  final String code;
  final String label;
  final String nativeSymbol;

  const Chain(this.code, this.label, this.nativeSymbol);

  /// True for EVM L2/L1 chains that use Etherscan-compatible APIs and
  /// 0x-prefixed addresses.
  bool get isEvm =>
      this == ethereum ||
      this == bsc ||
      this == polygon ||
      this == arbitrum ||
      this == optimism ||
      this == base;
}

enum InputKind { txHash, address, unknown }

class DetectionResult {
  final Chain? chain;
  final InputKind kind;
  final String normalized;

  /// True when the detector picked the chain heuristically without a user
  /// hint (e.g. defaulted EVM addresses to Ethereum). When set, lookup()
  /// can probe other compatible chains if the default has no activity.
  final bool autoDetected;

  const DetectionResult({
    required this.chain,
    required this.kind,
    required this.normalized,
    this.autoDetected = false,
  });

  bool get ok => chain != null && kind != InputKind.unknown;
}
