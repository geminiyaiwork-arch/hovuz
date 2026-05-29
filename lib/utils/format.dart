import 'package:intl/intl.dart';

String fmtAmount(double v, {int max = 8}) {
  if (v == 0) return '0';
  final f = NumberFormat.decimalPattern('en_US');
  f.maximumFractionDigits = max;
  f.minimumFractionDigits = 0;
  return f.format(v);
}

String shortAddr(String? a, {int head = 8, int tail = 6}) {
  if (a == null || a.isEmpty) return '—';
  if (a.length <= head + tail + 3) return a;
  return '${a.substring(0, head)}…${a.substring(a.length - tail)}';
}

String fmtTime(DateTime? t) {
  if (t == null) return '—';
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(t.toLocal());
}

/// Format a USD amount with compact suffixes (K / M / B) for readability.
/// Examples:
///   0.42        → "$0.42"
///   42          → "$42"
///   1234        → "$1,234"
///   1234567     → "$1.23M"
///   2300000000  → "$2.30B"
String fmtUsd(double v) {
  if (v.abs() < 0.01) return '\$0';
  if (v.abs() < 1) return '\$${v.toStringAsFixed(2)}';
  if (v.abs() < 1000) {
    final f = NumberFormat.decimalPattern('en_US');
    f.maximumFractionDigits = 2;
    f.minimumFractionDigits = 0;
    return '\$${f.format(v)}';
  }
  if (v.abs() < 1e6) {
    return '\$${NumberFormat.decimalPattern('en_US').format(v.round())}';
  }
  if (v.abs() < 1e9) return '\$${(v / 1e6).toStringAsFixed(2)}M';
  if (v.abs() < 1e12) return '\$${(v / 1e9).toStringAsFixed(2)}B';
  return '\$${(v / 1e12).toStringAsFixed(2)}T';
}
