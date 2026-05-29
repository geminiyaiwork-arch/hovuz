import 'package:flutter/material.dart';

import '../main.dart';
import '../theme.dart';
import '../utils/format.dart';

/// Small USD value badge next to crypto amounts. Self-updates when the
/// PriceScope cache refreshes. Renders nothing when the price is unknown.
class UsdTag extends StatelessWidget {
  const UsdTag({
    super.key,
    required this.symbol,
    required this.amount,
    this.fontSize = 12,
    this.inverse = false,
  });

  final String symbol;
  final double amount;
  final double fontSize;

  /// If true, renders with white-on-color for use over coloured backgrounds.
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final price = PriceScope.of(context).cachedPrice(symbol);
    if (price == null) return const SizedBox.shrink();
    final usd = amount * price;
    final color = inverse ? Colors.white.withOpacity(0.85) : HovuzTheme.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: inverse
            ? Colors.white.withOpacity(0.18)
            : HovuzTheme.green.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '≈ ${fmtUsd(usd)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
