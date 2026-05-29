import 'package:flutter/material.dart';

/// Brand colors and recognizable glyphs for each supported coin / token.
/// Used by CoinLogo to render a distinctive circular badge per symbol.
class CoinInfo {
  final String symbol;
  final String glyph;
  final List<Color> gradient;
  final Color foreground;
  final bool monospace;

  const CoinInfo({
    required this.symbol,
    required this.glyph,
    required this.gradient,
    this.foreground = Colors.white,
    this.monospace = false,
  });

  LinearGradient get linearGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradient,
      );

  Color get primary => gradient.last;
}

class CoinRegistry {
  static const _table = <String, CoinInfo>{
    // Native chains
    'BTC': CoinInfo(
      symbol: 'BTC',
      glyph: '₿',
      gradient: [Color(0xFFFFB347), Color(0xFFF7931A)],
    ),
    'ETH': CoinInfo(
      symbol: 'ETH',
      glyph: 'Ξ',
      gradient: [Color(0xFF8FA4F0), Color(0xFF627EEA)],
    ),
    'TRX': CoinInfo(
      symbol: 'TRX',
      glyph: 'T',
      gradient: [Color(0xFFFF5D67), Color(0xFFEF1924)],
    ),
    'BNB': CoinInfo(
      symbol: 'BNB',
      glyph: 'B',
      gradient: [Color(0xFFFFD955), Color(0xFFF0B90B)],
      foreground: Color(0xFF202020),
    ),
    'SOL': CoinInfo(
      symbol: 'SOL',
      glyph: 'S',
      gradient: [Color(0xFF9945FF), Color(0xFF14F195)],
    ),
    'POL': CoinInfo(
      symbol: 'POL',
      glyph: 'P',
      gradient: [Color(0xFFA476FF), Color(0xFF8247E5)],
    ),
    'MATIC': CoinInfo(
      symbol: 'MATIC',
      glyph: 'M',
      gradient: [Color(0xFFA476FF), Color(0xFF8247E5)],
    ),
    'ARB': CoinInfo(
      symbol: 'ARB',
      glyph: 'A',
      gradient: [Color(0xFF61C0FF), Color(0xFF28A0F0)],
    ),
    'OP': CoinInfo(
      symbol: 'OP',
      glyph: 'O',
      gradient: [Color(0xFFFF5470), Color(0xFFFF0420)],
    ),
    'BASE': CoinInfo(
      symbol: 'BASE',
      glyph: 'B',
      gradient: [Color(0xFF3F86FF), Color(0xFF0052FF)],
    ),

    // Wrapped natives
    'WBTC': CoinInfo(
      symbol: 'WBTC',
      glyph: '₿',
      gradient: [Color(0xFFE99950), Color(0xFFCC7A12)],
    ),
    'WETH': CoinInfo(
      symbol: 'WETH',
      glyph: 'Ξ',
      gradient: [Color(0xFF7E92D6), Color(0xFF455FB8)],
    ),
    'WBNB': CoinInfo(
      symbol: 'WBNB',
      glyph: 'B',
      gradient: [Color(0xFFFFD955), Color(0xFFF0B90B)],
      foreground: Color(0xFF202020),
    ),
    'WSOL': CoinInfo(
      symbol: 'WSOL',
      glyph: 'S',
      gradient: [Color(0xFF9945FF), Color(0xFF14F195)],
    ),

    // Stablecoins
    'USDT': CoinInfo(
      symbol: 'USDT',
      glyph: '₮',
      gradient: [Color(0xFF50AF95), Color(0xFF26A17B)],
    ),
    'USDC': CoinInfo(
      symbol: 'USDC',
      glyph: '\$',
      gradient: [Color(0xFF54A5E3), Color(0xFF2775CA)],
    ),
    'BUSD': CoinInfo(
      symbol: 'BUSD',
      glyph: 'B',
      gradient: [Color(0xFFFFD955), Color(0xFFF0B90B)],
      foreground: Color(0xFF202020),
    ),
    'DAI': CoinInfo(
      symbol: 'DAI',
      glyph: '◈',
      gradient: [Color(0xFFFFCB57), Color(0xFFF5AC37)],
      foreground: Color(0xFF202020),
    ),
    'TUSD': CoinInfo(
      symbol: 'TUSD',
      glyph: 'T',
      gradient: [Color(0xFF7FA9E3), Color(0xFF002868)],
    ),
    'FDUSD': CoinInfo(
      symbol: 'FDUSD',
      glyph: 'F',
      gradient: [Color(0xFFA6B8DB), Color(0xFF353B7B)],
    ),
    'PYUSD': CoinInfo(
      symbol: 'PYUSD',
      glyph: '₱',
      gradient: [Color(0xFF7B5BD6), Color(0xFF253B80)],
    ),

    // Generic token fallbacks (chain-aware)
    'TOKEN': CoinInfo(
      symbol: '?',
      glyph: '◐',
      gradient: [Color(0xFFB0B8C8), Color(0xFF6B7689)],
    ),
    'TRC20': CoinInfo(
      symbol: 'TRC20',
      glyph: 'T',
      gradient: [Color(0xFFFF5D67), Color(0xFFEF1924)],
    ),
    'SPL': CoinInfo(
      symbol: 'SPL',
      glyph: 'S',
      gradient: [Color(0xFF9945FF), Color(0xFF14F195)],
    ),
  };

  static CoinInfo? lookup(String symbol) =>
      _table[symbol.toUpperCase()];

  /// Always returns something — falls back to a neutral "?" coin.
  static CoinInfo resolve(String symbol) =>
      lookup(symbol) ??
      CoinInfo(
        symbol: symbol,
        glyph: symbol.isEmpty ? '?' : symbol[0].toUpperCase(),
        gradient: const [Color(0xFFB0B8C8), Color(0xFF6B7689)],
      );
}
