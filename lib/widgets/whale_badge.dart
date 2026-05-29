import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../main.dart';

/// Renders a 🐋 WHALE badge when a transfer's USD value exceeds threshold.
/// Threshold is per-symbol context-aware:
///   - Default: $100,000
class WhaleBadge extends StatelessWidget {
  const WhaleBadge({
    super.key,
    required this.symbol,
    required this.amount,
    this.thresholdUsd = 100000,
  });

  final String symbol;
  final double amount;
  final double thresholdUsd;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final price = PriceScope.of(context).cachedPrice(symbol);
    if (price == null) return const SizedBox.shrink();
    final usd = amount * price;
    if (usd < thresholdUsd) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E62D8), Color(0xFF0E3A88)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55154AAB),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🐋', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            s.whaleBadge,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
