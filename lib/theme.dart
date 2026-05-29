import 'package:flutter/material.dart';

/// Hovuz palette — based on the logo's corporate blue with crypto chain
/// accents (BTC orange, ETH violet, TRX red, BNB yellow, SOL purple).
/// Gold is reserved for monetary highlights.
class HovuzTheme {
  // Backgrounds — cool, light, premium
  static const Color bg = Color(0xFFF4F7FB);
  static const Color bgSoft = Color(0xFFEEF3FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF7FAFC);
  static const Color border = Color(0xFFE1E7F0);
  static const Color borderSoft = Color(0xFFEEF2F7);

  // Text
  static const Color text = Color(0xFF0F1F38);
  static const Color textDim = Color(0xFF5A6A85);

  // Brand — pulled from logo (corporate blue)
  static const Color brand = Color(0xFF1E62D8);
  static const Color brandSoft = Color(0xFF4F86E8);
  static const Color brandDeep = Color(0xFF154AAB);

  // Crypto chain accents
  static const Color btc = Color(0xFFF7931A);
  static const Color eth = Color(0xFF627EEA);
  static const Color tron = Color(0xFFEF1924);
  static const Color bnb = Color(0xFFF0B90B);
  static const Color sol = Color(0xFF9945FF);
  static const Color polygon = Color(0xFF8247E5);
  static const Color arbitrum = Color(0xFF28A0F0);
  static const Color optimism = Color(0xFFFF0420);
  static const Color base = Color(0xFF0052FF);

  // Money — gold for amounts
  static const Color gold = Color(0xFFE4A300);
  static const Color goldLight = Color(0xFFFFC83D);
  static const Color goldDark = Color(0xFFB57E00);

  // Status
  static const Color green = Color(0xFF10A85B);
  static const Color red = Color(0xFFE0394A);
  static const Color amber = Color(0xFFCC8400);

  // Gradients
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFD), Color(0xFFEDF2F9)],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F86E8), Color(0xFF1E62D8)],
  );

  static const LinearGradient brandDeepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2F77E8), Color(0xFF0F3E92)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD86B), Color(0xFFE4A300)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEEF4FD), Color(0xFFDDE9F9)],
  );

  static const LinearGradient btcGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB347), Color(0xFFF7931A)],
  );

  static const LinearGradient ethGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8FA4F0), Color(0xFF627EEA)],
  );

  static const LinearGradient bnbGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD955), Color(0xFFF0B90B)],
  );

  static const LinearGradient tronGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5D67), Color(0xFFEF1924)],
  );

  static const LinearGradient solGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9945FF), Color(0xFF14F195)],
  );

  static const LinearGradient polygonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA476FF), Color(0xFF8247E5)],
  );

  static const LinearGradient arbitrumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF61C0FF), Color(0xFF28A0F0)],
  );

  static const LinearGradient optimismGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5470), Color(0xFFFF0420)],
  );

  static const LinearGradient baseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3F86FF), Color(0xFF0052FF)],
  );

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x14154AAB),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0A102A4A),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];

  static ThemeData build() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: brand,
        secondary: gold,
        surface: surface,
        onSurface: text,
        error: red,
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),
      dividerColor: border,
      textTheme: base.textTheme.apply(
        bodyColor: text,
        displayColor: text,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brand, width: 1.6),
        ),
        hintStyle: const TextStyle(color: textDim),
      ),
      iconTheme: const IconThemeData(color: text),
    );
  }

  static ThemeData buildDark() {
    final base = ThemeData.dark(useMaterial3: true);
    const dBg = Color(0xFF0E1118);
    const dSurface = Color(0xFF161B22);
    const dSurface2 = Color(0xFF1F2630);
    const dBorder = Color(0xFF2A313C);
    const dText = Color(0xFFE6EDF3);
    return base.copyWith(
      scaffoldBackgroundColor: dBg,
      colorScheme: const ColorScheme.dark(
        primary: brand,
        secondary: gold,
        surface: dSurface,
        onSurface: dText,
        error: red,
      ),
      cardTheme: CardTheme(
        color: dSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: dBorder),
        ),
      ),
      dividerColor: dBorder,
      textTheme: base.textTheme.apply(bodyColor: dText, displayColor: dText),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dSurface2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brand, width: 1.6),
        ),
        hintStyle: const TextStyle(color: Color(0xFF8B949E)),
      ),
      iconTheme: const IconThemeData(color: dText),
    );
  }

  /// Per-chain accent color helper.
  static Color chainColor(String code) {
    switch (code) {
      case 'BTC':
        return btc;
      case 'ETH':
        return eth;
      case 'TRX':
      case 'TRON':
        return tron;
      case 'BNB':
      case 'BSC':
        return bnb;
      case 'SOL':
      case 'WSOL':
        return sol;
      case 'POL':
      case 'MATIC':
        return polygon;
      case 'ARB':
        return arbitrum;
      case 'OP':
        return optimism;
      case 'BASE':
        return base;
      default:
        return brand;
    }
  }

  static LinearGradient chainGradient(String code) {
    switch (code) {
      case 'BTC':
        return btcGradient;
      case 'ETH':
        return ethGradient;
      case 'TRX':
      case 'TRON':
        return tronGradient;
      case 'BNB':
      case 'BSC':
        return bnbGradient;
      case 'SOL':
      case 'WSOL':
        return solGradient;
      case 'POL':
      case 'MATIC':
        return polygonGradient;
      case 'ARB':
        return arbitrumGradient;
      case 'OP':
        return optimismGradient;
      case 'BASE':
        return baseGradient;
      default:
        return brandGradient;
    }
  }
}
