import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chain.dart';
import 'api_keys.dart';

/// Fetches the list of ERC20/BEP20/TRC20/SPL tokens an address holds,
/// with balance and best-effort USD value (when CoinGecko has the symbol).
class PortfolioToken {
  final String symbol;
  final String name;
  final double balance;
  final String contract;
  final int decimals;

  const PortfolioToken({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.contract,
    required this.decimals,
  });
}

class PortfolioService {
  PortfolioService({http.Client? client, this.etherscanKey})
      : _client = client ?? http.Client();

  final http.Client _client;
  // Runtime-mutable so HomePage can refresh from ApiKeysService.
  String? etherscanKey;

  Future<List<PortfolioToken>> fetch(String address, Chain chain) async {
    if (chain.isEvm) return _fetchEvm(address, chain);
    if (chain == Chain.tron) return _fetchTron(address);
    if (chain == Chain.solana) return _fetchSolana(address);
    return const [];
  }

  /// Etherscan V2 unified endpoint + chainid. Same key for all EVM chains.
  int _chainId(Chain c) {
    switch (c) {
      case Chain.bsc:
        return 56;
      case Chain.polygon:
        return 137;
      case Chain.arbitrum:
        return 42161;
      case Chain.optimism:
        return 10;
      case Chain.base:
        return 8453;
      case Chain.ethereum:
      default:
        return 1;
    }
  }

  Future<List<PortfolioToken>> _fetchEvm(String addr, Chain chain) async {
    const base = 'https://api.etherscan.io/v2/api';
    final cid = _chainId(chain);
    final key = etherscanKey ?? ApiKeys.etherscanDefault;
    try {
      // Use tokentx to enumerate tokens that have ever touched the address.
      final r = await _client
          .get(Uri.parse(
              '$base?chainid=$cid&module=account&action=tokentx&address=$addr&page=1&offset=200&sort=desc&apikey=$key'))
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) return const [];
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final txRaw = body['result'];
      final txs = txRaw is List ? txRaw : const [];
      // For each unique contract, sum signed flow (received - sent).
      final agg = <String, _EvmAgg>{};
      final me = addr.toLowerCase();
      for (final t in txs) {
        final m = t as Map;
        final contract = (m['contractAddress'] as String? ?? '').toLowerCase();
        if (contract.isEmpty) continue;
        final dec = int.tryParse(
                (m['tokenDecimal'] as String? ?? '18')) ??
            18;
        final raw = BigInt.tryParse(
                (m['value'] as String? ?? '0')) ??
            BigInt.zero;
        final amount = raw / BigInt.from(10).pow(dec);
        final from = (m['from'] as String? ?? '').toLowerCase();
        final to = (m['to'] as String? ?? '').toLowerCase();
        final sign = to == me ? 1 : (from == me ? -1 : 0);
        if (sign == 0) continue;
        final symbol = (m['tokenSymbol'] as String? ?? '').toUpperCase();
        final name = m['tokenName'] as String? ?? symbol;
        agg.update(
          contract,
          (a) => _EvmAgg(
            symbol: a.symbol,
            name: a.name,
            balance: a.balance + sign * amount,
            decimals: a.decimals,
            contract: a.contract,
          ),
          ifAbsent: () => _EvmAgg(
            symbol: symbol,
            name: name,
            balance: sign * amount,
            decimals: dec,
            contract: contract,
          ),
        );
      }
      final out = agg.values
          .where((a) => a.balance > 0.000001)
          .map((a) => PortfolioToken(
                symbol: a.symbol,
                name: a.name,
                balance: a.balance.toDouble(),
                contract: a.contract,
                decimals: a.decimals,
              ))
          .toList()
        ..sort((a, b) => b.balance.compareTo(a.balance));
      return out;
    } catch (_) {
      return const [];
    }
  }

  Future<List<PortfolioToken>> _fetchTron(String addr) async {
    try {
      final r = await _client
          .get(Uri.parse('https://api.trongrid.io/v1/accounts/$addr'))
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) return const [];
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final data = (body['data'] as List?) ?? const [];
      if (data.isEmpty) return const [];
      final m = data.first as Map;
      final trc20 = ((m['trc20'] as List?) ?? const []).cast<Map>();
      final out = <PortfolioToken>[];
      for (final entry in trc20) {
        entry.forEach((contract, raw) {
          final amount = (BigInt.tryParse('$raw') ?? BigInt.zero) /
              BigInt.from(10).pow(6);
          if (amount > BigInt.zero / BigInt.one) {
            out.add(PortfolioToken(
              symbol: contract == 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
                  ? 'USDT'
                  : 'TRC20',
              name: 'TRC20',
              balance: amount.toDouble(),
              contract: contract.toString(),
              decimals: 6,
            ));
          }
        });
      }
      out.sort((a, b) => b.balance.compareTo(a.balance));
      return out;
    } catch (_) {
      return const [];
    }
  }

  Future<List<PortfolioToken>> _fetchSolana(String addr) async {
    try {
      final body = jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'getTokenAccountsByOwner',
        'params': [
          addr,
          {'programId': 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'},
          {'encoding': 'jsonParsed'}
        ],
      });
      final r = await _client
          .post(Uri.parse('https://api.mainnet-beta.solana.com'),
              headers: const {'Content-Type': 'application/json'},
              body: body)
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) return const [];
      final decoded = jsonDecode(r.body) as Map<String, dynamic>;
      final result = decoded['result'] as Map<String, dynamic>?;
      final value = (result?['value'] as List?) ?? const [];
      final out = <PortfolioToken>[];
      for (final entry in value) {
        final info = ((entry as Map)['account'] as Map)['data'] as Map;
        final parsed = (info['parsed'] as Map)['info'] as Map;
        final ta = parsed['tokenAmount'] as Map;
        final uiAmount = (ta['uiAmount'] as num?)?.toDouble() ?? 0;
        if (uiAmount == 0) continue;
        final mint = parsed['mint'] as String? ?? '';
        out.add(PortfolioToken(
          symbol: _knownSolMintSymbol(mint) ?? 'SPL',
          name: 'SPL',
          balance: uiAmount,
          contract: mint,
          decimals: (ta['decimals'] as int?) ?? 0,
        ));
      }
      out.sort((a, b) => b.balance.compareTo(a.balance));
      return out;
    } catch (_) {
      return const [];
    }
  }

  static String? _knownSolMintSymbol(String mint) {
    const m = {
      'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v': 'USDC',
      'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB': 'USDT',
      'So11111111111111111111111111111111111111112': 'WSOL',
    };
    return m[mint];
  }
}

class _EvmAgg {
  final String symbol;
  final String name;
  final double balance;
  final int decimals;
  final String contract;
  _EvmAgg({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.decimals,
    required this.contract,
  });
}
