import '../models/chain.dart';
import '../models/transfer.dart';
import 'blockchain_service.dart';
import 'chain_detector.dart';
import 'sanctions_list.dart';

/// Multi-hop fund tracing. Follows the biggest single outflow from each
/// address for up to N hops, until we hit an exchange, a sanctioned address,
/// or run out of meaningful transfers.
class TraceService {
  TraceService({BlockchainService? service})
      : _service = service ?? BlockchainService(),
        _detector = ChainDetector();

  final BlockchainService _service;
  final ChainDetector _detector;

  /// Follow the trail starting from [startAddress] on [chain].
  /// Stops when:
  ///   - max [hops] reached
  ///   - terminal address (labeled exchange) reached
  ///   - sanctioned address reached
  ///   - no outflow found
  Future<TraceResult> trace(
    String startAddress,
    Chain chain, {
    int hops = 3,
  }) async {
    final visited = <String>{startAddress.toLowerCase()};
    final steps = <TraceStep>[];
    String current = startAddress;
    bool hitTerminal = false;
    String? terminalReason;

    for (var i = 0; i < hops; i++) {
      final detection =
          _detector.detect(current, hint: chain);
      final r = await _service.lookup(detection);
      if (r.hasError || r.address == null) break;
      final a = r.address!;

      // Find the biggest single transfer where this address is sender.
      Transfer? biggestOut;
      for (final t in a.recentTransfers) {
        if (t.from.toLowerCase() == current.toLowerCase() &&
            t.amount > 0) {
          if (biggestOut == null || t.amount > biggestOut.amount) {
            biggestOut = t;
          }
        }
      }
      if (biggestOut == null) {
        steps.add(TraceStep(
          fromAddress: current,
          toAddress: null,
          amount: 0,
          symbol: a.chain.nativeSymbol,
          time: null,
          label: a.label,
          isMixer: _detectMixer(a.recentTransfers),
        ));
        break;
      }

      final isSanctioned = _isSanctioned(biggestOut.to, chain);
      final hasLabel = biggestOut.toLabel != null;
      final isMixerHop = _looksLikeMixerHop(biggestOut, a.recentTransfers);

      steps.add(TraceStep(
        fromAddress: current,
        toAddress: biggestOut.to,
        amount: biggestOut.amount,
        symbol: biggestOut.symbol,
        time: biggestOut.time,
        label: biggestOut.toLabel,
        isSanctioned: isSanctioned,
        isMixer: isMixerHop,
      ));

      if (isSanctioned) {
        hitTerminal = true;
        terminalReason = 'sanctioned';
        break;
      }
      if (hasLabel) {
        hitTerminal = true;
        terminalReason = 'exchange';
        break;
      }
      if (visited.contains(biggestOut.to.toLowerCase())) {
        hitTerminal = true;
        terminalReason = 'cycle';
        break;
      }
      visited.add(biggestOut.to.toLowerCase());
      current = biggestOut.to;
    }

    return TraceResult(
      start: startAddress,
      chain: chain,
      steps: steps,
      hitTerminal: hitTerminal,
      terminalReason: terminalReason,
    );
  }

  static bool _isSanctioned(String addr, Chain chain) {
    SanctionEntry? hit;
    if (addr.startsWith('0x')) {
      hit = SanctionsList.lookupEvm(addr);
    } else if (addr.startsWith('T') && addr.length == 34) {
      hit = SanctionsList.lookupTron(addr);
    } else {
      hit = SanctionsList.lookupBtc(addr);
    }
    return hit != null;
  }

  /// Heuristic: addresses that send/receive equal-sized batches with
  /// dozens of counterparties in a short window look mixer-like.
  static bool _detectMixer(List<Transfer> transfers) {
    if (transfers.length < 10) return false;
    final amounts = transfers.map((t) => t.amount).toList();
    // Many equal amounts (within 5%) → suggestive
    var equalCount = 0;
    for (var i = 0; i < amounts.length - 1; i++) {
      for (var j = i + 1; j < amounts.length; j++) {
        final a = amounts[i], b = amounts[j];
        if (a == 0) continue;
        if ((a - b).abs() / a < 0.05) equalCount++;
      }
    }
    return equalCount > amounts.length;
  }

  static bool _looksLikeMixerHop(
      Transfer t, List<Transfer> siblings) {
    // If the same address sends N near-identical amounts to N different
    // addresses around the same time → mixer pattern.
    final near = siblings.where((x) =>
        x.from == t.from &&
        x.to != t.to &&
        x.amount > 0 &&
        (x.amount - t.amount).abs() / t.amount < 0.05);
    return near.length >= 5;
  }
}

class TraceStep {
  final String fromAddress;
  final String? toAddress;
  final double amount;
  final String symbol;
  final DateTime? time;
  final String? label;
  final bool isSanctioned;
  final bool isMixer;

  const TraceStep({
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.symbol,
    this.time,
    this.label,
    this.isSanctioned = false,
    this.isMixer = false,
  });
}

class TraceResult {
  final String start;
  final Chain chain;
  final List<TraceStep> steps;
  final bool hitTerminal;

  /// One of: `exchange`, `sanctioned`, `cycle`, `dead-end`, null (max hops).
  final String? terminalReason;

  const TraceResult({
    required this.start,
    required this.chain,
    required this.steps,
    required this.hitTerminal,
    this.terminalReason,
  });

  bool get hasResults => steps.isNotEmpty;
}
