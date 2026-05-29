import 'dart:math';

import '../models/transfer.dart';

/// Statistical estimate of which UTC offset a wallet is likely operating from,
/// based on the distribution of transfer timestamps across the 24-hour day.
///
/// Assumption: human-operated wallets show a heavy diurnal pattern (active
/// during ~08:00–22:00 local time, quiet at night). Algorithmic / exchange
/// hot wallets show uniform 24h activity and are flagged as `algorithmic`.
class TimezoneEstimate {
  /// Best-guess UTC offset in hours (-12 .. +14). Null if undetermined.
  final int? offsetHours;

  /// 0..1 confidence that this wallet is human-operated with a clear pattern.
  final double confidence;

  /// True when the activity looks 24/7 / uniform (likely algorithmic).
  final bool algorithmic;

  /// Number of timestamps analyzed.
  final int sampleSize;

  /// Active hours interval (local time, 0..23) when confidence is high.
  final int? activeStart;
  final int? activeEnd;

  /// Hour-of-day histogram in UTC (24 buckets).
  final List<int> hourHistogramUtc;

  const TimezoneEstimate({
    required this.offsetHours,
    required this.confidence,
    required this.algorithmic,
    required this.sampleSize,
    required this.hourHistogramUtc,
    this.activeStart,
    this.activeEnd,
  });

  /// Human-friendly region label for the offset.
  String? get regionHint {
    if (offsetHours == null) return null;
    final o = offsetHours!;
    if (o >= -10 && o <= -7) return 'Americas (Pacific/Mountain)';
    if (o >= -6 && o <= -4) return 'Americas (Central/Eastern)';
    if (o >= -3 && o <= -1) return 'Atlantic / Brazil';
    if (o == 0) return 'UK / Western Europe';
    if (o >= 1 && o <= 2) return 'Europe (CET / EET)';
    if (o == 3) return 'Russia (MSK) / Turkey / East Africa';
    if (o == 4) return 'Gulf / Caucasus';
    if (o == 5) return 'Central Asia / Pakistan';
    if (o == 6) return 'Bangladesh / Kazakhstan';
    if (o == 7) return 'SE Asia (Vietnam / Indonesia)';
    if (o == 8) return 'China / Singapore / Philippines';
    if (o == 9) return 'Japan / Korea';
    if (o >= 10 && o <= 12) return 'Australia / Pacific';
    return null;
  }
}

class TimezoneAnalyzer {
  /// Build histogram + estimate offset from a list of Transfers.
  static TimezoneEstimate analyze(List<Transfer> transfers) {
    final times = transfers
        .map((t) => t.time)
        .whereType<DateTime>()
        .toList();
    return analyzeTimes(times);
  }

  /// Same, but accepts raw DateTimes.
  static TimezoneEstimate analyzeTimes(List<DateTime> times) {
    final hist = List<int>.filled(24, 0);
    for (final t in times) {
      final h = t.toUtc().hour;
      hist[h] = hist[h] + 1;
    }
    final n = times.length;
    if (n < 5) {
      return TimezoneEstimate(
        offsetHours: null,
        confidence: 0,
        algorithmic: false,
        sampleSize: n,
        hourHistogramUtc: hist,
      );
    }

    // Find the contiguous 14-hour window with the highest count.
    // The window center indicates the wallet's local midday.
    int bestStart = 0;
    int bestSum = -1;
    for (var start = 0; start < 24; start++) {
      var sum = 0;
      for (var i = 0; i < 14; i++) {
        sum += hist[(start + i) % 24];
      }
      if (sum > bestSum) {
        bestSum = sum;
        bestStart = start;
      }
    }

    // Confidence = how much of activity is concentrated in the window.
    final windowShare = bestSum / n;
    final confidence = ((windowShare - 14 / 24) * 2.6).clamp(0.0, 1.0);

    // If activity is essentially uniform → algorithmic.
    final mean = n / 24;
    var variance = 0.0;
    for (final c in hist) {
      variance += pow(c - mean, 2);
    }
    variance /= 24;
    final stdDev = sqrt(variance);
    final relStdDev = mean == 0 ? 0 : stdDev / mean;
    final algorithmic = relStdDev < 0.45 && n >= 10;

    if (algorithmic || confidence < 0.15) {
      return TimezoneEstimate(
        offsetHours: null,
        confidence: confidence,
        algorithmic: algorithmic,
        sampleSize: n,
        hourHistogramUtc: hist,
      );
    }

    // Center of the active window in UTC hours.
    final centerUtc = (bestStart + 7) % 24;
    // Assume local "midday" = 13:00 local time → offset = 13 - centerUtc.
    var offset = 13 - centerUtc;
    if (offset > 14) offset -= 24;
    if (offset < -11) offset += 24;

    return TimezoneEstimate(
      offsetHours: offset,
      confidence: confidence,
      algorithmic: false,
      sampleSize: n,
      hourHistogramUtc: hist,
      activeStart: bestStart,
      activeEnd: (bestStart + 14) % 24,
    );
  }
}
