import 'package:flutter/material.dart';

import '../services/coin_registry.dart';

/// Circular badge per coin/token symbol. Uses real brand colors and
/// a recognizable glyph (₿ Ξ ₮ etc.).
class CoinLogo extends StatelessWidget {
  const CoinLogo({
    super.key,
    required this.symbol,
    this.size = 36,
    this.fontSize,
    this.glow = true,
    this.showSymbolBelow = false,
  });

  final String symbol;
  final double size;
  final double? fontSize;
  final bool glow;
  final bool showSymbolBelow;

  @override
  Widget build(BuildContext context) {
    final coin = CoinRegistry.resolve(symbol);
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: coin.linearGradient,
        shape: BoxShape.circle,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: coin.primary.withOpacity(0.32),
                  blurRadius: size * 0.35,
                  offset: Offset(0, size * 0.10),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          coin.glyph,
          style: TextStyle(
            color: coin.foreground,
            fontSize: fontSize ?? size * 0.55,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        ),
      ),
    );

    if (!showSymbolBelow) return circle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        const SizedBox(height: 4),
        Text(
          symbol,
          style: TextStyle(
            color: coin.primary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
