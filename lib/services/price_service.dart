import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Resolves coin/token symbols → USD price using CoinGecko's free API.
///
/// Caching:
///  - Native chain prices (BTC, ETH, BNB, TRX, SOL) keshlanadi 5 daqiqaga
///  - SPL/ERC20 stable'lar (USDT, USDC, DAI, etc.) ~$1 deb belgilanadi
///  - Noma'lum tokenlar uchun null qaytadi (UI uni ko'rsatmaydi)
class PriceService extends ChangeNotifier {
  PriceService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _cacheTtl = Duration(minutes: 5);

  // symbol → (price USD, when fetched)
  final Map<String, _CacheEntry> _cache = {};

  // CoinGecko coin IDs for top symbols.
  static const Map<String, String> _coingeckoIds = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'BNB': 'binancecoin',
    'TRX': 'tron',
    'SOL': 'solana',
    'WBTC': 'wrapped-bitcoin',
    'WETH': 'weth',
    'WBNB': 'wbnb',
    'WSOL': 'wrapped-solana',
  };

  // Stablecoins anchored to $1.
  static const Set<String> _stables = {
    'USDT', 'USDC', 'DAI', 'BUSD', 'TUSD', 'FDUSD', 'PYUSD', 'USDP'
  };

  bool get isEnabled => true;

  /// Fetch USD price for one symbol. Returns null if unknown / API failed.
  Future<double?> getPrice(String symbol) async {
    final s = symbol.toUpperCase();
    if (_stables.contains(s)) return 1.0;
    final cached = _cache[s];
    if (cached != null && cached.isFresh) return cached.price;

    final id = _coingeckoIds[s];
    if (id == null) return null;

    try {
      final r = await _client
          .get(
            Uri.parse(
                'https://api.coingecko.com/api/v3/simple/price?ids=$id&vs_currencies=usd'),
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return cached?.price;
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final price = ((body[id] as Map?)?['usd'] as num?)?.toDouble();
      if (price == null) return cached?.price;
      _cache[s] = _CacheEntry(price: price, fetchedAt: DateTime.now());
      notifyListeners();
      return price;
    } catch (_) {
      return cached?.price;
    }
  }

  /// Batch fetch many symbols at once (one API call when possible).
  Future<Map<String, double>> getPrices(Iterable<String> symbols) async {
    final out = <String, double>{};
    final needFetch = <String>{};
    for (final raw in symbols) {
      final s = raw.toUpperCase();
      if (_stables.contains(s)) {
        out[s] = 1.0;
        continue;
      }
      final cached = _cache[s];
      if (cached != null && cached.isFresh) {
        out[s] = cached.price;
        continue;
      }
      if (_coingeckoIds.containsKey(s)) needFetch.add(s);
    }
    if (needFetch.isEmpty) return out;

    final ids = needFetch.map((s) => _coingeckoIds[s]!).toSet().join(',');
    try {
      final r = await _client
          .get(
            Uri.parse(
                'https://api.coingecko.com/api/v3/simple/price?ids=$ids&vs_currencies=usd'),
          )
          .timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) return out;
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      for (final s in needFetch) {
        final id = _coingeckoIds[s]!;
        final price = ((body[id] as Map?)?['usd'] as num?)?.toDouble();
        if (price != null) {
          _cache[s] = _CacheEntry(price: price, fetchedAt: DateTime.now());
          out[s] = price;
        }
      }
      notifyListeners();
    } catch (_) {
      // Use whatever we have cached
    }
    return out;
  }

  /// Synchronous lookup (UI helper). Returns cached price if fresh, else null.
  double? cachedPrice(String symbol) {
    final s = symbol.toUpperCase();
    if (_stables.contains(s)) return 1.0;
    final c = _cache[s];
    if (c == null || !c.isFresh) return null;
    return c.price;
  }

  /// Pre-warm cache with native chain prices.
  Future<void> warmup() async {
    await getPrices(_coingeckoIds.keys);
  }
}

class _CacheEntry {
  final double price;
  final DateTime fetchedAt;
  const _CacheEntry({required this.price, required this.fetchedAt});
  bool get isFresh =>
      DateTime.now().difference(fetchedAt) < PriceService._cacheTtl;
}
