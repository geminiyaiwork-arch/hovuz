import '../models/chain.dart';

class ChainDetector {
  static final _hex64 = RegExp(r'^[0-9a-fA-F]{64}$');
  static final _hex64Prefixed = RegExp(r'^0x[0-9a-fA-F]{64}$');
  static final _ethAddr = RegExp(r'^0x[0-9a-fA-F]{40}$');
  static final _tronAddr = RegExp(r'^T[1-9A-HJ-NP-Za-km-z]{33}$');
  static final _btcLegacy = RegExp(r'^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$');
  static final _btcBech32 = RegExp(r'^bc1[ac-hj-np-z02-9]{6,87}$');
  // Solana — base58 (Bitcoin alphabet), pubkeys are 32–44 chars, signatures 86–88.
  static final _solBase58 = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');

  DetectionResult detect(String raw, {Chain? hint}) {
    final v = raw.trim();
    if (v.isEmpty) {
      return const DetectionResult(
        chain: null,
        kind: InputKind.unknown,
        normalized: '',
      );
    }

    if (_tronAddr.hasMatch(v)) {
      return DetectionResult(
        chain: Chain.tron,
        kind: InputKind.address,
        normalized: v,
      );
    }

    if (_ethAddr.hasMatch(v)) {
      final chain = hint == Chain.bsc ? Chain.bsc : Chain.ethereum;
      return DetectionResult(
        chain: chain,
        kind: InputKind.address,
        normalized: v.toLowerCase(),
      );
    }

    if (_btcBech32.hasMatch(v.toLowerCase())) {
      return DetectionResult(
        chain: Chain.bitcoin,
        kind: InputKind.address,
        normalized: v,
      );
    }

    if (_btcLegacy.hasMatch(v)) {
      // Could in theory be Solana if length ≥ 32. Default to BTC; hint overrides.
      if (hint == Chain.solana && v.length >= 32) {
        return DetectionResult(
          chain: Chain.solana,
          kind: InputKind.address,
          normalized: v,
        );
      }
      return DetectionResult(
        chain: Chain.bitcoin,
        kind: InputKind.address,
        normalized: v,
      );
    }

    // Solana signature (base58, 86–88 chars).
    if (v.length >= 86 && v.length <= 88 && _solBase58.hasMatch(v)) {
      return DetectionResult(
        chain: Chain.solana,
        kind: InputKind.txHash,
        normalized: v,
      );
    }

    // Solana address (base58, 32–44 chars). Apply AFTER BTC checks so
    // legacy BTC addresses don't get hijacked.
    if (v.length >= 32 && v.length <= 44 && _solBase58.hasMatch(v)) {
      return DetectionResult(
        chain: Chain.solana,
        kind: InputKind.address,
        normalized: v,
      );
    }

    if (_hex64Prefixed.hasMatch(v)) {
      final chain = hint == Chain.bsc ? Chain.bsc : Chain.ethereum;
      return DetectionResult(
        chain: chain,
        kind: InputKind.txHash,
        normalized: v.toLowerCase(),
      );
    }

    if (_hex64.hasMatch(v)) {
      final chain = hint ?? Chain.bitcoin;
      return DetectionResult(
        chain: chain,
        kind: InputKind.txHash,
        normalized: v.toLowerCase(),
      );
    }

    return DetectionResult(
      chain: null,
      kind: InputKind.unknown,
      normalized: v,
    );
  }
}
