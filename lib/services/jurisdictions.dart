/// Maps each exchange name → (ISO country code, flag emoji, regulator hint).
/// These are the exchanges' legal-entity registrations (HQ / corporate seat),
/// not the country of any individual user.
/// Sources: each exchange's "About us" / "Terms of service" pages.
class Jurisdiction {
  final String countryIso;
  final String flag;
  final String country;
  final String? regulator;
  const Jurisdiction({
    required this.countryIso,
    required this.flag,
    required this.country,
    this.regulator,
  });
}

class Jurisdictions {
  static const Map<String, Jurisdiction> _map = {
    'Binance': Jurisdiction(
      countryIso: 'KY',
      flag: '🇰🇾',
      country: 'Cayman Islands',
      regulator: 'CIMA',
    ),
    'OKX': Jurisdiction(
      countryIso: 'SC',
      flag: '🇸🇨',
      country: 'Seychelles',
      regulator: 'FSA',
    ),
    'Bybit': Jurisdiction(
      countryIso: 'AE',
      flag: '🇦🇪',
      country: 'UAE (Dubai)',
      regulator: 'VARA',
    ),
    'KuCoin': Jurisdiction(
      countryIso: 'SC',
      flag: '🇸🇨',
      country: 'Seychelles',
      regulator: 'FSA',
    ),
    'Bitget': Jurisdiction(
      countryIso: 'SC',
      flag: '🇸🇨',
      country: 'Seychelles',
      regulator: 'FSA',
    ),
    'HTX (Huobi)': Jurisdiction(
      countryIso: 'SC',
      flag: '🇸🇨',
      country: 'Seychelles',
      regulator: 'FSA',
    ),
    'MEXC': Jurisdiction(
      countryIso: 'SC',
      flag: '🇸🇨',
      country: 'Seychelles',
      regulator: 'FSA',
    ),
    'Gate.io': Jurisdiction(
      countryIso: 'KY',
      flag: '🇰🇾',
      country: 'Cayman Islands',
      regulator: 'CIMA',
    ),
    'Coinbase': Jurisdiction(
      countryIso: 'US',
      flag: '🇺🇸',
      country: 'USA',
      regulator: 'FinCEN / NYDFS',
    ),
    'Kraken': Jurisdiction(
      countryIso: 'US',
      flag: '🇺🇸',
      country: 'USA',
      regulator: 'FinCEN',
    ),
    'Bitfinex': Jurisdiction(
      countryIso: 'VG',
      flag: '🇻🇬',
      country: 'British Virgin Islands',
    ),
    'Crypto.com': Jurisdiction(
      countryIso: 'SG',
      flag: '🇸🇬',
      country: 'Singapore',
      regulator: 'MAS',
    ),
    'Gemini': Jurisdiction(
      countryIso: 'US',
      flag: '🇺🇸',
      country: 'USA',
      regulator: 'NYDFS',
    ),
    'Bitstamp': Jurisdiction(
      countryIso: 'LU',
      flag: '🇱🇺',
      country: 'Luxembourg',
      regulator: 'CSSF',
    ),
    'Poloniex': Jurisdiction(
      countryIso: 'SC',
      flag: '🇸🇨',
      country: 'Seychelles',
    ),
    'Bittrex': Jurisdiction(
      countryIso: 'US',
      flag: '🇺🇸',
      country: 'USA',
      regulator: 'FinCEN',
    ),
    'BingX': Jurisdiction(
      countryIso: 'SG',
      flag: '🇸🇬',
      country: 'Singapore',
    ),
  };

  static Jurisdiction? lookup(String exchangeName) {
    // Match exact then prefix (e.g. "HTX (Huobi)" matches itself).
    final exact = _map[exchangeName];
    if (exact != null) return exact;
    for (final e in _map.entries) {
      if (exchangeName.startsWith(e.key)) return e.value;
    }
    return null;
  }
}
