import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chain.dart';

/// Resolves human-readable domain names → on-chain addresses:
///   - ENS:  vitalik.eth        → 0xd8da6bf26964af9d7eed9e03e53415d37aa96045
///   - SNS:  toly.sol           → CKfatsPMUf8SkiURsDXs7eK6GWb4Jsd6UDbs7twMCWxo
///   - TRON: not standardized; we expose a no-op for that chain.
///
/// Caching is per-session; valid domain → address is permanent enough.
class NameResolver {
  NameResolver({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, String> _cache = {};

  /// Returns true if input looks like an ENS-style domain ("foo.eth").
  static bool looksLikeEns(String s) =>
      RegExp(r'^[a-z0-9-]+(\.[a-z0-9-]+)*\.eth$').hasMatch(s.toLowerCase());

  /// "foo.sol" → SNS.
  static bool looksLikeSns(String s) =>
      RegExp(r'^[a-z0-9-]+\.sol$').hasMatch(s.toLowerCase());

  /// Resolve any supported domain → (address, chain). Null if nothing resolves.
  Future<NameResolution?> resolve(String input) async {
    final raw = input.trim().toLowerCase();
    if (raw.isEmpty) return null;
    final cached = _cache[raw];
    if (cached != null) {
      return NameResolution(
        name: raw,
        address: cached,
        chain: looksLikeSns(raw) ? Chain.solana : Chain.ethereum,
      );
    }

    if (looksLikeEns(raw)) {
      final addr = await _resolveEns(raw);
      if (addr == null) return null;
      _cache[raw] = addr;
      return NameResolution(
          name: raw, address: addr, chain: Chain.ethereum);
    }
    if (looksLikeSns(raw)) {
      final addr = await _resolveSns(raw);
      if (addr == null) return null;
      _cache[raw] = addr;
      return NameResolution(
          name: raw, address: addr, chain: Chain.solana);
    }
    return null;
  }

  // ENS via public ensideas API (no key, generous limits).
  Future<String?> _resolveEns(String name) async {
    try {
      final r = await _client
          .get(Uri.parse('https://api.ensideas.com/ens/resolve/$name'))
          .timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return null;
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final addr = body['address'] as String?;
      if (addr == null || addr.isEmpty) return null;
      return addr.toLowerCase();
    } catch (_) {
      return null;
    }
  }

  // SNS via the public Bonfida API.
  Future<String?> _resolveSns(String name) async {
    try {
      // Strip the .sol suffix — SNS API expects the bare label.
      final label = name.endsWith('.sol')
          ? name.substring(0, name.length - 4)
          : name;
      final r = await _client
          .get(Uri.parse('https://sns-api.bonfida.com/v2/domains/$label'))
          .timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return null;
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final result = body['result'] as Map<String, dynamic>?;
      return result?['owner'] as String?;
    } catch (_) {
      return null;
    }
  }
}

class NameResolution {
  final String name;
  final String address;
  final Chain chain;
  const NameResolution({
    required this.name,
    required this.address,
    required this.chain,
  });
}
