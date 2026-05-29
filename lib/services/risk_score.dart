import '../models/chain.dart';
import '../models/transfer.dart';
import 'sanctions_list.dart';
import 'timezone_analyzer.dart';

/// Aggregated risk score for an address (0..100).
/// 0 = clean / institutional, 100 = highly suspicious.
class RiskScore {
  final int score;
  final RiskLevel level;
  final List<RiskFactor> factors;
  const RiskScore({
    required this.score,
    required this.level,
    required this.factors,
  });
}

enum RiskLevel { veryLow, low, medium, high, critical }

class RiskFactor {
  final String key;
  final String displayKey;
  final int weight;
  final bool isPositive;
  const RiskFactor({
    required this.key,
    required this.displayKey,
    required this.weight,
    this.isPositive = false,
  });
}

class RiskAssessor {
  static RiskScore assess(AddressSummary a) {
    int score = 0;
    final factors = <RiskFactor>[];

    // Self is directly sanctioned → instant critical.
    final selfSanctioned = _isSanctioned(a.address, a.chain);
    if (selfSanctioned) {
      factors.add(const RiskFactor(
          key: 'self_sanctioned',
          displayKey: 'riskSelfSanctioned',
          weight: 100));
      return RiskScore(
        score: 100,
        level: RiskLevel.critical,
        factors: factors,
      );
    }

    // Counterparty sanctions
    int sanctionHits = 0;
    for (final t in a.recentTransfers) {
      if (_isSanctioned(t.from, a.chain) ||
          _isSanctioned(t.to, a.chain)) {
        sanctionHits++;
      }
    }
    if (sanctionHits > 0) {
      final w = (sanctionHits * 25).clamp(25, 80);
      score += w;
      factors.add(RiskFactor(
          key: 'counterparty_sanctioned',
          displayKey: 'riskCounterpartySanctioned',
          weight: w));
    }

    // Exchange-labeled → safer (deducts up to 15 points)
    if (a.label != null) {
      score -= 15;
      factors.add(const RiskFactor(
        key: 'known_exchange',
        displayKey: 'riskKnownExchange',
        weight: 15,
        isPositive: true,
      ));
    }

    // Algorithmic 24-h activity → -10 (hot wallet / bot)
    final tz = TimezoneAnalyzer.analyze(a.recentTransfers);
    if (tz.algorithmic) {
      score -= 10;
      factors.add(const RiskFactor(
        key: 'algorithmic',
        displayKey: 'riskAlgorithmic',
        weight: 10,
        isPositive: true,
      ));
    }

    // Very low activity (1-3 tx) → moderate risk (could be one-shot wallet)
    if (a.txCount >= 1 && a.txCount <= 3 && a.balanceNative > 0) {
      score += 15;
      factors.add(const RiskFactor(
        key: 'low_activity',
        displayKey: 'riskLowActivity',
        weight: 15,
      ));
    }

    // Huge net inflow with no outflow → "burn / dust" pattern (small risk)
    if (a.totalReceivedNative > 0 &&
        a.totalSentNative / a.totalReceivedNative < 0.05 &&
        a.txCount > 5) {
      score += 10;
      factors.add(const RiskFactor(
        key: 'one_way_flow',
        displayKey: 'riskOneWayFlow',
        weight: 10,
      ));
    }

    // Mixer-like burst pattern
    if (_looksLikeMixerBurst(a.recentTransfers)) {
      score += 30;
      factors.add(const RiskFactor(
        key: 'mixer_pattern',
        displayKey: 'riskMixerPattern',
        weight: 30,
      ));
    }

    if (score < 0) score = 0;
    if (score > 100) score = 100;

    return RiskScore(
      score: score,
      level: _level(score),
      factors: factors,
    );
  }

  static bool _isSanctioned(String addr, Chain chain) {
    if (addr.isEmpty || addr == '—') return false;
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

  static bool _looksLikeMixerBurst(List<Transfer> transfers) {
    if (transfers.length < 8) return false;
    final amounts = transfers.map((t) => t.amount).toList();
    var equalPairs = 0;
    for (var i = 0; i < amounts.length - 1; i++) {
      for (var j = i + 1; j < amounts.length; j++) {
        if (amounts[i] == 0) continue;
        final delta = (amounts[i] - amounts[j]).abs() / amounts[i];
        if (delta < 0.03) equalPairs++;
      }
    }
    return equalPairs > amounts.length;
  }

  static RiskLevel _level(int score) {
    if (score >= 80) return RiskLevel.critical;
    if (score >= 60) return RiskLevel.high;
    if (score >= 35) return RiskLevel.medium;
    if (score >= 15) return RiskLevel.low;
    return RiskLevel.veryLow;
  }
}
