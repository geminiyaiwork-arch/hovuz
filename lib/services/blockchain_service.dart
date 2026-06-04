import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../l10n/strings.dart';
import '../models/chain.dart';
import '../models/transfer.dart';
import 'api_keys.dart';
import 'exchange_addresses.dart';

/// Service-level exception that carries a translatable error code.
class LookupException implements Exception {
  final LookupErrorCode code;
  final String? extra;
  const LookupException(this.code, [this.extra]);
  @override
  String toString() => 'LookupException($code, $extra)';
}

class BlockchainService {
  BlockchainService({
    http.Client? client,
    this.etherscanKey,
    this.bscscanKey,
    this.tronGridKey,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String? etherscanKey;
  final String? bscscanKey;
  final String? tronGridKey;

  // ============================================================
  // PUBLIC API
  // ============================================================

  Future<LookupResult> lookup(DetectionResult d) async {
    if (!d.ok) {
      return LookupResult(
        detection: d,
        errorCode: LookupErrorCode.invalidFormat,
      );
    }
    try {
      if (d.kind == InputKind.txHash) {
        switch (d.chain!) {
          case Chain.bitcoin:
            return LookupResult(
              detection: d,
              transaction: await _btcTransaction(d.normalized),
            );
          case Chain.ethereum:
            return LookupResult(
              detection: d,
              transaction: await _evmTransaction(d.normalized, Chain.ethereum),
            );
          case Chain.bsc:
            return LookupResult(
              detection: d,
              transaction: await _evmTransaction(d.normalized, Chain.bsc),
            );
          case Chain.tron:
            return LookupResult(
              detection: d,
              transaction: await _tronTransaction(d.normalized),
            );
          case Chain.solana:
            return LookupResult(
              detection: d,
              transaction: await _solTransaction(d.normalized),
            );
          case Chain.polygon:
          case Chain.arbitrum:
          case Chain.optimism:
          case Chain.base:
            return LookupResult(
              detection: d,
              transaction: await _evmTransaction(d.normalized, d.chain!),
            );
        }
      } else if (d.kind == InputKind.address) {
        switch (d.chain!) {
          case Chain.bitcoin:
            return LookupResult(
              detection: d,
              address: await _btcAddress(d.normalized),
            );
          case Chain.ethereum:
            return LookupResult(
              detection: d,
              address: await _evmAddress(d.normalized, Chain.ethereum),
            );
          case Chain.bsc:
            return LookupResult(
              detection: d,
              address: await _evmAddress(d.normalized, Chain.bsc),
            );
          case Chain.tron:
            return LookupResult(
              detection: d,
              address: await _tronAddress(d.normalized),
            );
          case Chain.solana:
            return LookupResult(
              detection: d,
              address: await _solAddress(d.normalized),
            );
          case Chain.polygon:
          case Chain.arbitrum:
          case Chain.optimism:
          case Chain.base:
            return LookupResult(
              detection: d,
              address: await _evmAddress(d.normalized, d.chain!),
            );
        }
      }
      return LookupResult(
          detection: d, errorCode: LookupErrorCode.unsupported);
    } on TimeoutException {
      return LookupResult(detection: d, errorCode: LookupErrorCode.timeout);
    } on LookupException catch (e) {
      return LookupResult(
          detection: d, errorCode: e.code, errorExtra: e.extra);
    } catch (e) {
      return LookupResult(
          detection: d,
          errorCode: LookupErrorCode.generic,
          errorExtra: e.toString());
    }
  }

  // ============================================================
  // BITCOIN  (Blockstream — public, no key)
  // ============================================================

  static const _btcBase = 'https://blockstream.info/api';

  Future<TransactionInfo> _btcTransaction(String hash) async {
    final tx = await _getJson('$_btcBase/tx/$hash');
    final status = tx['status'] as Map<String, dynamic>?;
    final blockTime = status?['block_time'] as int?;
    final time = blockTime != null
        ? DateTime.fromMillisecondsSinceEpoch(blockTime * 1000)
        : null;

    final vin = (tx['vin'] as List?) ?? const [];
    final vout = (tx['vout'] as List?) ?? const [];

    int totalIn = 0;
    for (final i in vin) {
      final p = (i as Map)['prevout'] as Map?;
      if (p != null) totalIn += (p['value'] as num?)?.toInt() ?? 0;
    }
    int totalOut = 0;
    for (final o in vout) {
      totalOut += ((o as Map)['value'] as num?)?.toInt() ?? 0;
    }
    final fee = (totalIn - totalOut) / 1e8;

    final transfers = <Transfer>[];
    final senders = <String>{};
    for (final i in vin) {
      final p = (i as Map)['prevout'] as Map?;
      if (p == null) continue;
      final addr = p['scriptpubkey_address'] as String?;
      if (addr != null) senders.add(addr);
    }
    final senderList = senders.join(', ');

    for (final o in vout) {
      final addr = (o as Map)['scriptpubkey_address'] as String?;
      final val = ((o['value'] as num?)?.toInt() ?? 0) / 1e8;
      if (addr == null || val == 0) continue;
      transfers.add(Transfer(
        from: senderList.isEmpty ? '—' : senderList,
        to: addr,
        amount: val,
        symbol: 'BTC',
        fromLabel: _labelMulti(senders, Chain.bitcoin),
        toLabel: ExchangeAddressBook.lookup(addr, Chain.bitcoin)?.display,
        time: time,
        txHash: hash,
      ));
    }

    return TransactionInfo(
      chain: Chain.bitcoin,
      hash: hash,
      time: time,
      blockHeight: status?['block_height'] as int?,
      confirmations: null,
      status: (status?['confirmed'] == true) ? 'confirmed' : 'unconfirmed',
      feeNative: fee,
      transfers: transfers,
      rawSender: senderList,
      rawReceiver: vout.isNotEmpty
          ? ((vout.first as Map)['scriptpubkey_address'] as String?)
          : null,
    );
  }

  Future<AddressSummary> _btcAddress(String addr) async {
    final info = await _getJson('$_btcBase/address/$addr');
    final chain = info['chain_stats'] as Map<String, dynamic>?;
    final mempool = info['mempool_stats'] as Map<String, dynamic>?;
    final funded = ((chain?['funded_txo_sum'] as num?)?.toInt() ?? 0) +
        ((mempool?['funded_txo_sum'] as num?)?.toInt() ?? 0);
    final spent = ((chain?['spent_txo_sum'] as num?)?.toInt() ?? 0) +
        ((mempool?['spent_txo_sum'] as num?)?.toInt() ?? 0);
    final txCount = ((chain?['tx_count'] as num?)?.toInt() ?? 0) +
        ((mempool?['tx_count'] as num?)?.toInt() ?? 0);

    final txs = await _getJsonList('$_btcBase/address/$addr/txs');
    final transfers = <Transfer>[];
    for (final tx in txs.take(15)) {
      final m = tx as Map;
      final time = (m['status'] as Map?)?['block_time'] as int?;
      final t = time != null
          ? DateTime.fromMillisecondsSinceEpoch(time * 1000)
          : null;
      final vouts = (m['vout'] as List?) ?? const [];
      double sentToOthers = 0;
      double receivedHere = 0;
      String? counterparty;
      for (final o in vouts) {
        final a = (o as Map)['scriptpubkey_address'] as String?;
        final v = ((o['value'] as num?)?.toInt() ?? 0) / 1e8;
        if (a == addr) {
          receivedHere += v;
        } else if (a != null) {
          sentToOthers += v;
          counterparty ??= a;
        }
      }
      final vins = (m['vin'] as List?) ?? const [];
      bool addressIsSender = false;
      for (final i in vins) {
        final p = (i as Map)['prevout'] as Map?;
        if ((p?['scriptpubkey_address'] as String?) == addr) {
          addressIsSender = true;
          break;
        }
      }

      if (addressIsSender && sentToOthers > 0 && counterparty != null) {
        transfers.add(Transfer(
          from: addr,
          to: counterparty,
          amount: sentToOthers,
          symbol: 'BTC',
          toLabel: ExchangeAddressBook.lookup(counterparty, Chain.bitcoin)?.display,
          time: t,
          txHash: m['txid'] as String?,
        ));
      } else if (!addressIsSender && receivedHere > 0) {
        // Try to find a sender label from inputs
        String? sender;
        for (final i in vins) {
          final p = (i as Map)['prevout'] as Map?;
          final a = p?['scriptpubkey_address'] as String?;
          if (a != null && a != addr) {
            sender = a;
            break;
          }
        }
        transfers.add(Transfer(
          from: sender ?? '—',
          to: addr,
          amount: receivedHere,
          symbol: 'BTC',
          fromLabel: sender == null
              ? null
              : ExchangeAddressBook.lookup(sender, Chain.bitcoin)?.display,
          time: t,
          txHash: m['txid'] as String?,
        ));
      }
    }

    return AddressSummary(
      chain: Chain.bitcoin,
      address: addr,
      balanceNative: (funded - spent) / 1e8,
      totalReceivedNative: funded / 1e8,
      totalSentNative: spent / 1e8,
      txCount: txCount,
      label: ExchangeAddressBook.lookup(addr, Chain.bitcoin)?.display,
      recentTransfers: transfers,
    );
  }

  // ============================================================
  // ETHEREUM / BSC  (Etherscan-compatible v2)
  // ============================================================

  String _evmBase(Chain c) {
    switch (c) {
      case Chain.bsc:
        return 'https://api.bscscan.com/api';
      case Chain.polygon:
        return 'https://api.polygonscan.com/api';
      case Chain.arbitrum:
        return 'https://api.arbiscan.io/api';
      case Chain.optimism:
        return 'https://api-optimistic.etherscan.io/api';
      case Chain.base:
        return 'https://api.basescan.org/api';
      default:
        return 'https://api.etherscan.io/api';
    }
  }

  String _evmKey(Chain c) {
    if (c == Chain.bsc) return bscscanKey ?? ApiKeys.bscscanDefault;
    return etherscanKey ?? ApiKeys.etherscanDefault;
  }

  /// BscScan/Etherscan return a 200 even on logical errors — the body is
  /// `{"status":"0","message":"NOTOK","result":"…explanation…"}`.
  /// Surface those as proper LookupException instead of a casting crash.
  void _evmGuard(Map<String, dynamic> resp) {
    final status = resp['status'];
    final msg = resp['message'];
    if (status == '0' && msg == 'NOTOK') {
      final result = resp['result'];
      final hint = result is String ? result : msg.toString();
      // "No transactions found" is a normal empty result, not an error.
      if (hint.toLowerCase().contains('no transactions found')) return;
      throw LookupException(LookupErrorCode.generic, hint);
    }
  }

  Future<TransactionInfo> _evmTransaction(String hash, Chain chain) async {
    final base = _evmBase(chain);
    final key = _evmKey(chain);

    // Get the transaction
    final txResp = await _getJson(
      '$base?module=proxy&action=eth_getTransactionByHash&txhash=$hash&apikey=$key',
    );
    _evmGuard(txResp);
    // `result` may be a String error message instead of the tx object.
    final txRaw = txResp['result'];
    final tx = txRaw is Map<String, dynamic> ? txRaw : null;
    if (tx == null) {
      throw LookupException(
          LookupErrorCode.txNotFound, txRaw is String ? txRaw : null);
    }
    final receiptResp = await _getJson(
      '$base?module=proxy&action=eth_getTransactionReceipt&txhash=$hash&apikey=$key',
    );
    _evmGuard(receiptResp);
    final receiptRaw = receiptResp['result'];
    final receipt =
        receiptRaw is Map<String, dynamic> ? receiptRaw : null;

    final from = (tx['from'] as String?) ?? '';
    final to = (tx['to'] as String?) ?? '';
    final valueWei = _hexBigInt(tx['value'] as String? ?? '0x0');
    final valueNative = valueWei / BigInt.from(10).pow(18);
    final gasUsed = _hexBigInt(receipt?['gasUsed'] as String? ?? '0x0');
    final gasPrice = _hexBigInt(tx['gasPrice'] as String? ?? '0x0');
    final feeNative = (gasUsed * gasPrice) / BigInt.from(10).pow(18);
    final blockNum = _hexInt(tx['blockNumber'] as String? ?? '0x0');
    final status = receipt?['status'] == '0x1' ? 'success' : 'failed';

    // Get block time
    DateTime? time;
    if (blockNum > 0) {
      final blk = await _getJson(
        '$base?module=proxy&action=eth_getBlockByNumber&tag=0x${blockNum.toRadixString(16)}&boolean=false&apikey=$key',
      );
      final ts = _hexInt(((blk['result'] as Map?)?['timestamp'] as String?) ?? '0x0');
      if (ts > 0) time = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    }

    final transfers = <Transfer>[];

    if (valueNative > 0) {
      transfers.add(Transfer(
        from: from,
        to: to,
        amount: valueNative.toDouble(),
        symbol: chain.nativeSymbol,
        fromLabel: ExchangeAddressBook.lookup(from, chain)?.display,
        toLabel: ExchangeAddressBook.lookup(to, chain)?.display,
        time: time,
        txHash: hash,
      ));
    }

    // ERC20 / BEP20 token transfers in the same tx
    final logs = (receipt?['logs'] as List?) ?? const [];
    const transferTopic =
        '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';
    for (final l in logs) {
      final m = l as Map;
      final topics = (m['topics'] as List?) ?? const [];
      if (topics.isEmpty || topics[0] != transferTopic) continue;
      if (topics.length < 3) continue;
      final tFrom = _addrFromTopic(topics[1] as String);
      final tTo = _addrFromTopic(topics[2] as String);
      final dataHex = m['data'] as String? ?? '0x0';
      final amount = _hexBigInt(dataHex);
      final token = (m['address'] as String?) ?? '';
      final symbol = _knownTokenSymbol(token, chain) ?? 'TOKEN';
      final decimals = _knownTokenDecimals(token, chain) ?? 18;
      final value = amount / BigInt.from(10).pow(decimals);
      transfers.add(Transfer(
        from: tFrom,
        to: tTo,
        amount: value.toDouble(),
        symbol: symbol,
        fromLabel: ExchangeAddressBook.lookup(tFrom, chain)?.display,
        toLabel: ExchangeAddressBook.lookup(tTo, chain)?.display,
        time: time,
        txHash: hash,
        contractAddress: token,
      ));
    }

    return TransactionInfo(
      chain: chain,
      hash: hash,
      time: time,
      blockHeight: blockNum,
      confirmations: null,
      status: status,
      feeNative: feeNative.toDouble(),
      transfers: transfers,
      rawSender: from,
      rawReceiver: to,
    );
  }

  Future<AddressSummary> _evmAddress(String addr, Chain chain) async {
    final base = _evmBase(chain);
    final key = _evmKey(chain);

    final balResp = await _getJson(
      '$base?module=account&action=balance&address=$addr&tag=latest&apikey=$key',
    );
    _evmGuard(balResp);
    final balRaw = balResp['result'];
    final wei = (balRaw is String)
        ? (BigInt.tryParse(balRaw) ?? BigInt.zero)
        : BigInt.zero;
    final balance = wei / BigInt.from(10).pow(18);

    final txResp = await _getJson(
      '$base?module=account&action=txlist&address=$addr&page=1&offset=20&sort=desc&apikey=$key',
    );
    _evmGuard(txResp);
    // BscScan/Etherscan return result as String when there's an error
    // ("Max rate limit", "Invalid API key"). Safe-check instead of casting.
    final txRaw = txResp['result'];
    final txs = (txRaw is List) ? txRaw : const [];

    double totalIn = 0;
    double totalOut = 0;
    final transfers = <Transfer>[];
    for (final t in txs) {
      final m = t as Map;
      final value = (BigInt.tryParse((m['value'] as String?) ?? '0') ?? BigInt.zero) /
          BigInt.from(10).pow(18);
      final from = (m['from'] as String? ?? '').toLowerCase();
      final to = (m['to'] as String? ?? '').toLowerCase();
      final ts = int.tryParse((m['timeStamp'] as String?) ?? '0') ?? 0;
      final time =
          ts > 0 ? DateTime.fromMillisecondsSinceEpoch(ts * 1000) : null;
      final me = addr.toLowerCase();
      if (from == me) totalOut += value.toDouble();
      if (to == me) totalIn += value.toDouble();
      if (value > 0) {
        transfers.add(Transfer(
          from: from,
          to: to,
          amount: value.toDouble(),
          symbol: chain.nativeSymbol,
          fromLabel: ExchangeAddressBook.lookup(from, chain)?.display,
          toLabel: ExchangeAddressBook.lookup(to, chain)?.display,
          time: time,
          txHash: m['hash'] as String?,
        ));
      }
    }

    return AddressSummary(
      chain: chain,
      address: addr,
      balanceNative: balance.toDouble(),
      totalReceivedNative: totalIn,
      totalSentNative: totalOut,
      txCount: txs.length,
      label: ExchangeAddressBook.lookup(addr, chain)?.display,
      recentTransfers: transfers,
    );
  }

  // ============================================================
  // TRON  (TronGrid public)
  // ============================================================

  static const _tronBase = 'https://api.trongrid.io';

  Map<String, String> get _tronHeaders {
    final key = tronGridKey ?? ApiKeys.tronGridDefault;
    return key.isEmpty ? const {} : {'TRON-PRO-API-KEY': key};
  }

  Future<TransactionInfo> _tronTransaction(String hash) async {
    final info = await _getJson(
      '$_tronBase/v1/transactions/$hash',
      headers: _tronHeaders,
    );
    final list = (info['data'] as List?) ?? const [];
    if (list.isEmpty) {
      throw const LookupException(LookupErrorCode.txNotFound);
    }
    final tx = list.first as Map;
    final rawData = (tx['raw_data'] as Map?) ?? const {};
    final contracts = (rawData['contract'] as List?) ?? const [];
    final ts = (tx['block_timestamp'] as int?);
    final time = ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
    final ret = (tx['ret'] as List?)?.cast<Map>();
    final status = (ret != null && ret.isNotEmpty)
        ? (ret.first['contractRet'] as String? ?? 'UNKNOWN')
        : 'UNKNOWN';
    final feeSun = (tx['ret'] as List?)?.fold<int>(
            0,
            (a, b) =>
                a + ((b as Map)['fee'] as int? ?? 0)) ??
        0;

    final transfers = <Transfer>[];
    String? rawFrom;
    String? rawTo;

    for (final c in contracts) {
      final m = (c as Map);
      final type = m['type'] as String? ?? '';
      final params = (m['parameter'] as Map?)?['value'] as Map?;
      if (params == null) continue;
      if (type == 'TransferContract') {
        final from = _hexToBase58(params['owner_address'] as String? ?? '');
        final to = _hexToBase58(params['to_address'] as String? ?? '');
        final amount = ((params['amount'] as num?) ?? 0) / 1e6;
        rawFrom = from;
        rawTo = to;
        transfers.add(Transfer(
          from: from,
          to: to,
          amount: amount.toDouble(),
          symbol: 'TRX',
          fromLabel: ExchangeAddressBook.lookup(from, Chain.tron)?.display,
          toLabel: ExchangeAddressBook.lookup(to, Chain.tron)?.display,
          time: time,
          txHash: hash,
        ));
      } else if (type == 'TriggerSmartContract') {
        rawFrom = _hexToBase58(params['owner_address'] as String? ?? '');
        rawTo = _hexToBase58(params['contract_address'] as String? ?? '');
      }
    }

    // TRC20 transfers
    final trc20Resp = await _getJson(
      '$_tronBase/v1/transactions/$hash/events',
      headers: _tronHeaders,
    );
    final events = (trc20Resp['data'] as List?) ?? const [];
    for (final e in events) {
      final m = e as Map;
      if ((m['event_name'] as String?) != 'Transfer') continue;
      final res = (m['result'] as Map?) ?? const {};
      final from = _hexToBase58OrPass(res['from'] as String? ?? '');
      final to = _hexToBase58OrPass(res['to'] as String? ?? '');
      final amountStr = res['value'] as String? ?? '0';
      final amount = (BigInt.tryParse(amountStr) ?? BigInt.zero) /
          BigInt.from(10).pow(6);
      final contract = m['contract_address'] as String? ?? '';
      final symbol = _knownTrc20Symbol(contract) ?? 'TRC20';
      transfers.add(Transfer(
        from: from,
        to: to,
        amount: amount.toDouble(),
        symbol: symbol,
        fromLabel: ExchangeAddressBook.lookup(from, Chain.tron)?.display,
        toLabel: ExchangeAddressBook.lookup(to, Chain.tron)?.display,
        time: time,
        txHash: hash,
        contractAddress: contract.isEmpty ? null : contract,
      ));
    }

    return TransactionInfo(
      chain: Chain.tron,
      hash: hash,
      time: time,
      blockHeight: tx['blockNumber'] as int?,
      confirmations: null,
      status: status,
      feeNative: feeSun / 1e6,
      transfers: transfers,
      rawSender: rawFrom,
      rawReceiver: rawTo,
    );
  }

  Future<AddressSummary> _tronAddress(String addr) async {
    final acc = await _getJson(
      '$_tronBase/v1/accounts/$addr',
      headers: _tronHeaders,
    );
    final data = (acc['data'] as List?) ?? const [];
    final m = data.isNotEmpty ? data.first as Map : const {};
    final balanceSun = (m['balance'] as num?)?.toInt() ?? 0;

    final txs = await _getJson(
      '$_tronBase/v1/accounts/$addr/transactions/trc20?limit=30',
      headers: _tronHeaders,
    );
    final list = (txs['data'] as List?) ?? const [];

    double totalIn = 0;
    double totalOut = 0;
    final transfers = <Transfer>[];
    for (final t in list) {
      final tm = t as Map;
      final from = tm['from'] as String? ?? '';
      final to = tm['to'] as String? ?? '';
      final value = (BigInt.tryParse((tm['value'] as String?) ?? '0') ??
              BigInt.zero) /
          BigInt.from(10).pow((tm['token_info'] as Map?)?['decimals'] as int? ?? 6);
      final symbol =
          (tm['token_info'] as Map?)?['symbol'] as String? ?? 'TRC20';
      final tokenContract =
          (tm['token_info'] as Map?)?['address'] as String?;
      final ts = (tm['block_timestamp'] as int?);
      final time = ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
      if (from == addr) totalOut += value.toDouble();
      if (to == addr) totalIn += value.toDouble();
      transfers.add(Transfer(
        from: from,
        to: to,
        amount: value.toDouble(),
        symbol: symbol,
        fromLabel: ExchangeAddressBook.lookup(from, Chain.tron)?.display,
        toLabel: ExchangeAddressBook.lookup(to, Chain.tron)?.display,
        time: time,
        txHash: tm['transaction_id'] as String?,
        contractAddress: tokenContract,
      ));
    }

    return AddressSummary(
      chain: Chain.tron,
      address: addr,
      balanceNative: balanceSun / 1e6,
      totalReceivedNative: totalIn,
      totalSentNative: totalOut,
      txCount: list.length,
      label: ExchangeAddressBook.lookup(addr, Chain.tron)?.display,
      recentTransfers: transfers,
    );
  }

  // ============================================================
  // SOLANA  (mainnet-beta JSON-RPC, no key required)
  // ============================================================

  static const _solRpc = 'https://api.mainnet-beta.solana.com';

  Future<Map<String, dynamic>> _solRpcCall(String method,
      List<dynamic> params) async {
    final body = jsonEncode({
      'jsonrpc': '2.0',
      'id': 1,
      'method': method,
      'params': params,
    });
    final r = await _client
        .post(
          Uri.parse(_solRpc),
          headers: const {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 20));
    if (r.statusCode >= 400) {
      throw LookupException(LookupErrorCode.http, '${r.statusCode}');
    }
    final decoded = jsonDecode(r.body) as Map<String, dynamic>;
    if (decoded['error'] != null) {
      throw LookupException(
          LookupErrorCode.generic, decoded['error'].toString());
    }
    return decoded;
  }

  Future<TransactionInfo> _solTransaction(String sig) async {
    final resp = await _solRpcCall('getTransaction', [
      sig,
      {
        'encoding': 'jsonParsed',
        'maxSupportedTransactionVersion': 0,
        'commitment': 'confirmed',
      }
    ]);
    final result = resp['result'] as Map<String, dynamic>?;
    if (result == null) {
      throw const LookupException(LookupErrorCode.txNotFound);
    }
    final meta = result['meta'] as Map<String, dynamic>?;
    final blockTime = result['blockTime'] as int?;
    final time = blockTime != null
        ? DateTime.fromMillisecondsSinceEpoch(blockTime * 1000)
        : null;
    final slot = result['slot'] as int?;
    final feeLamports = (meta?['fee'] as num?)?.toInt() ?? 0;
    final status = meta?['err'] == null ? 'success' : 'failed';

    final transaction = result['transaction'] as Map<String, dynamic>?;
    final message = transaction?['message'] as Map<String, dynamic>?;
    final accountKeysRaw = (message?['accountKeys'] as List?) ?? const [];
    final accountKeys = <String>[
      for (final k in accountKeysRaw)
        (k is Map ? (k['pubkey'] as String?) : k as String?) ?? '',
    ];

    final preBalances =
        ((meta?['preBalances'] as List?) ?? const []).cast<int>();
    final postBalances =
        ((meta?['postBalances'] as List?) ?? const []).cast<int>();

    final transfers = <Transfer>[];
    String? rawSender;
    String? rawReceiver;

    // Native SOL net flows.
    if (preBalances.length == postBalances.length &&
        preBalances.length == accountKeys.length) {
      for (var i = 0; i < accountKeys.length; i++) {
        final delta = postBalances[i] - preBalances[i];
        if (i == 0) {
          // fee payer; subtract the fee from delta to expose actual movement
          final adjusted = delta + feeLamports;
          if (adjusted < 0) rawSender ??= accountKeys[i];
        } else if (delta > 0) {
          rawReceiver ??= accountKeys[i];
        }
      }
      // Emit one aggregated SOL transfer between fee payer and largest receiver.
      if (rawSender != null && rawReceiver != null) {
        final receiverIdx = accountKeys.indexOf(rawReceiver);
        final amountLamports =
            postBalances[receiverIdx] - preBalances[receiverIdx];
        if (amountLamports > 0) {
          transfers.add(Transfer(
            from: rawSender,
            to: rawReceiver,
            amount: amountLamports / 1e9,
            symbol: 'SOL',
            fromLabel:
                ExchangeAddressBook.lookup(rawSender, Chain.solana)?.display,
            toLabel:
                ExchangeAddressBook.lookup(rawReceiver, Chain.solana)?.display,
            time: time,
            txHash: sig,
          ));
        }
      }
    }

    // SPL token transfers from meta.preTokenBalances / postTokenBalances.
    final pre = (meta?['preTokenBalances'] as List?) ?? const [];
    final post = (meta?['postTokenBalances'] as List?) ?? const [];
    final byAccount = <int, Map<String, dynamic>>{};
    for (final p in post) {
      final m = p as Map<String, dynamic>;
      byAccount[m['accountIndex'] as int] = m;
    }
    for (final p in pre) {
      final m = p as Map<String, dynamic>;
      final idx = m['accountIndex'] as int;
      final preAmt = BigInt.tryParse(
              (m['uiTokenAmount'] as Map?)?['amount'] as String? ?? '0') ??
          BigInt.zero;
      final postEntry = byAccount[idx];
      final postAmt = BigInt.tryParse(
              (postEntry?['uiTokenAmount'] as Map?)?['amount'] as String? ??
                  '0') ??
          BigInt.zero;
      final delta = postAmt - preAmt;
      if (delta == BigInt.zero) continue;
      final decimals =
          (m['uiTokenAmount'] as Map?)?['decimals'] as int? ?? 0;
      final mint = m['mint'] as String? ?? '';
      final symbol = _knownSplSymbol(mint) ?? 'SPL';
      final owner = m['owner'] as String? ??
          (idx < accountKeys.length ? accountKeys[idx] : '');
      final amount = delta.abs() /
          BigInt.from(10).pow(decimals == 0 ? 1 : decimals);
      // Direction: negative delta → sender; positive → receiver.
      final isSender = delta < BigInt.zero;
      transfers.add(Transfer(
        from: isSender ? owner : '—',
        to: isSender ? '—' : owner,
        amount: amount.toDouble(),
        symbol: symbol,
        fromLabel: isSender
            ? ExchangeAddressBook.lookup(owner, Chain.solana)?.display
            : null,
        toLabel: !isSender
            ? ExchangeAddressBook.lookup(owner, Chain.solana)?.display
            : null,
        time: time,
        txHash: sig,
        contractAddress: mint.isEmpty ? null : mint,
      ));
    }

    return TransactionInfo(
      chain: Chain.solana,
      hash: sig,
      time: time,
      blockHeight: slot,
      confirmations: null,
      status: status,
      feeNative: feeLamports / 1e9,
      transfers: transfers,
      rawSender: rawSender,
      rawReceiver: rawReceiver,
    );
  }

  Future<AddressSummary> _solAddress(String addr) async {
    final balResp = await _solRpcCall('getBalance', [addr]);
    final lamports =
        ((balResp['result'] as Map?)?['value'] as num?)?.toInt() ?? 0;

    final sigResp = await _solRpcCall(
      'getSignaturesForAddress',
      [addr, {'limit': 20}],
    );
    final sigs = (sigResp['result'] as List?) ?? const [];

    final transfers = <Transfer>[];
    int txCount = sigs.length;
    for (final s in sigs.take(8)) {
      final m = s as Map;
      final sigStr = m['signature'] as String?;
      final ts = m['blockTime'] as int?;
      if (sigStr == null) continue;
      try {
        final tx = await _solTransaction(sigStr);
        for (final t in tx.transfers) {
          // Filter to transfers involving this address.
          if (t.from == addr || t.to == addr) {
            transfers.add(t);
          }
        }
      } catch (_) {
        // Skip individual tx failures.
      }
      if (transfers.length >= 15) break;
      // unused warn: keep ts for future enhancements
      ts;
    }

    double totalIn = 0;
    double totalOut = 0;
    for (final t in transfers) {
      if (t.symbol == 'SOL') {
        if (t.from == addr) totalOut += t.amount;
        if (t.to == addr) totalIn += t.amount;
      }
    }

    return AddressSummary(
      chain: Chain.solana,
      address: addr,
      balanceNative: lamports / 1e9,
      totalReceivedNative: totalIn,
      totalSentNative: totalOut,
      txCount: txCount,
      label: ExchangeAddressBook.lookup(addr, Chain.solana)?.display,
      recentTransfers: transfers,
    );
  }

  String? _knownSplSymbol(String mint) {
    const m = {
      'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v': 'USDC',
      'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB': 'USDT',
      'So11111111111111111111111111111111111111112': 'WSOL',
      '7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs': 'WETH',
    };
    return m[mint];
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Future<Map<String, dynamic>> _getJson(
    String url, {
    Map<String, String>? headers,
  }) async {
    final r = await _client
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 20));
    if (r.statusCode >= 400) {
      throw LookupException(LookupErrorCode.http, '${r.statusCode}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> _getJsonList(
    String url, {
    Map<String, String>? headers,
  }) async {
    final r = await _client
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 20));
    if (r.statusCode >= 400) {
      throw LookupException(LookupErrorCode.http, '${r.statusCode}');
    }
    return jsonDecode(r.body) as List<dynamic>;
  }

  String? _labelMulti(Iterable<String> addrs, Chain chain) {
    for (final a in addrs) {
      final l = ExchangeAddressBook.lookup(a, chain);
      if (l != null) return l.display;
    }
    return null;
  }

  BigInt _hexBigInt(String hex) {
    final h = hex.startsWith('0x') ? hex.substring(2) : hex;
    if (h.isEmpty) return BigInt.zero;
    return BigInt.parse(h, radix: 16);
  }

  int _hexInt(String hex) {
    final h = hex.startsWith('0x') ? hex.substring(2) : hex;
    if (h.isEmpty) return 0;
    return int.parse(h, radix: 16);
  }

  String _addrFromTopic(String topic) {
    final h = topic.startsWith('0x') ? topic.substring(2) : topic;
    if (h.length < 40) return '0x$h';
    return '0x${h.substring(h.length - 40)}';
  }

  String? _knownTokenSymbol(String addr, Chain chain) {
    final a = addr.toLowerCase();
    if (chain == Chain.ethereum) {
      const m = {
        '0xdac17f958d2ee523a2206206994597c13d831ec7': 'USDT',
        '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48': 'USDC',
        '0x6b175474e89094c44da98b954eedeac495271d0f': 'DAI',
        '0x2260fac5e5542a773aa44fbcfedf7c193bc2c599': 'WBTC',
        '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2': 'WETH',
      };
      return m[a];
    }
    if (chain == Chain.bsc) {
      const m = {
        '0x55d398326f99059ff775485246999027b3197955': 'USDT',
        '0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d': 'USDC',
        '0xe9e7cea3dedca5984780bafc599bd69add087d56': 'BUSD',
        '0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c': 'WBNB',
      };
      return m[a];
    }
    return null;
  }

  int? _knownTokenDecimals(String addr, Chain chain) {
    final a = addr.toLowerCase();
    if (chain == Chain.ethereum) {
      const m = {
        '0xdac17f958d2ee523a2206206994597c13d831ec7': 6, // USDT
        '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48': 6, // USDC
        '0x2260fac5e5542a773aa44fbcfedf7c193bc2c599': 8, // WBTC
      };
      return m[a];
    }
    if (chain == Chain.bsc) {
      const m = {
        '0x55d398326f99059ff775485246999027b3197955': 18,
        '0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d': 18,
        '0xe9e7cea3dedca5984780bafc599bd69add087d56': 18,
      };
      return m[a];
    }
    return null;
  }

  String? _knownTrc20Symbol(String contract) {
    const m = {
      'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t': 'USDT',
      'TEkxiTehnzSmSe2XqrBj4w32RUN966rdz8': 'USDC',
    };
    return m[contract];
  }

  // Convert TRON 41-prefixed hex address → base58 (T...)
  // Lightweight base58check implementation to avoid dependencies.
  String _hexToBase58(String hex) {
    if (hex.isEmpty) return '';
    if (hex.startsWith('T')) return hex;
    final h = hex.startsWith('0x') ? hex.substring(2) : hex;
    final bytes = <int>[];
    for (var i = 0; i < h.length; i += 2) {
      bytes.add(int.parse(h.substring(i, i + 2), radix: 16));
    }
    return _base58CheckEncode(bytes);
  }

  String _hexToBase58OrPass(String s) {
    if (s.isEmpty) return s;
    if (s.startsWith('T') && s.length >= 30) return s;
    if (s.length == 42 || s.length == 40) return _hexToBase58(s);
    if (s.startsWith('0x') && s.length == 42) {
      // EVM-style address embedded in TRON event: replace 0x → 41 prefix
      return _hexToBase58('41${s.substring(2)}');
    }
    return s;
  }

  static const _b58 =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  String _base58CheckEncode(List<int> payload) {
    final hash1 = _sha256(_sha256(payload));
    final checksum = hash1.sublist(0, 4);
    final full = [...payload, ...checksum];
    return _base58Encode(full);
  }

  String _base58Encode(List<int> bytes) {
    var x = BigInt.zero;
    for (final b in bytes) {
      x = (x << 8) | BigInt.from(b);
    }
    final base = BigInt.from(58);
    var s = '';
    while (x > BigInt.zero) {
      final r = (x % base).toInt();
      x = x ~/ base;
      s = _b58[r] + s;
    }
    for (final b in bytes) {
      if (b == 0) {
        s = '1$s';
      } else {
        break;
      }
    }
    return s;
  }

  // Minimal SHA-256
  List<int> _sha256(List<int> data) {
    return _Sha256.hash(data);
  }
}

// ----------------------------------------------------------
// SHA-256 (small standalone implementation — keeps deps minimal)
// ----------------------------------------------------------
class _Sha256 {
  static List<int> hash(List<int> data) {
    final msg = List<int>.from(data);
    final origLen = msg.length;
    msg.add(0x80);
    while (msg.length % 64 != 56) {
      msg.add(0);
    }
    final bitLen = origLen * 8;
    for (var i = 7; i >= 0; i--) {
      msg.add((bitLen >> (i * 8)) & 0xff);
    }
    final k = [
      0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
      0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
      0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
      0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
      0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
      0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
      0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
      0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
      0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
      0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
      0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    ];
    var h = [
      0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
      0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
    ];

    for (var i = 0; i < msg.length; i += 64) {
      final w = List<int>.filled(64, 0);
      for (var j = 0; j < 16; j++) {
        w[j] = (msg[i + j * 4] << 24) |
            (msg[i + j * 4 + 1] << 16) |
            (msg[i + j * 4 + 2] << 8) |
            msg[i + j * 4 + 3];
        w[j] &= 0xffffffff;
      }
      for (var j = 16; j < 64; j++) {
        final s0 = _rotr(w[j - 15], 7) ^ _rotr(w[j - 15], 18) ^ (w[j - 15] >> 3);
        final s1 = _rotr(w[j - 2], 17) ^ _rotr(w[j - 2], 19) ^ (w[j - 2] >> 10);
        w[j] = (w[j - 16] + s0 + w[j - 7] + s1) & 0xffffffff;
      }
      var a = h[0], b = h[1], c = h[2], d = h[3];
      var e = h[4], f = h[5], g = h[6], hh = h[7];
      for (var j = 0; j < 64; j++) {
        final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
        final ch = (e & f) ^ ((~e) & g);
        final t1 = (hh + s1 + ch + k[j] + w[j]) & 0xffffffff;
        final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
        final mj = (a & b) ^ (a & c) ^ (b & c);
        final t2 = (s0 + mj) & 0xffffffff;
        hh = g;
        g = f;
        f = e;
        e = (d + t1) & 0xffffffff;
        d = c;
        c = b;
        b = a;
        a = (t1 + t2) & 0xffffffff;
      }
      h[0] = (h[0] + a) & 0xffffffff;
      h[1] = (h[1] + b) & 0xffffffff;
      h[2] = (h[2] + c) & 0xffffffff;
      h[3] = (h[3] + d) & 0xffffffff;
      h[4] = (h[4] + e) & 0xffffffff;
      h[5] = (h[5] + f) & 0xffffffff;
      h[6] = (h[6] + g) & 0xffffffff;
      h[7] = (h[7] + hh) & 0xffffffff;
      for (var x = 0; x < 8; x++) {
        h[x] &= 0xffffffff;
      }
    }
    final out = <int>[];
    for (final v in h) {
      out.add((v >> 24) & 0xff);
      out.add((v >> 16) & 0xff);
      out.add((v >> 8) & 0xff);
      out.add(v & 0xff);
    }
    return out;
  }

  static int _rotr(int x, int n) =>
      ((x >> n) | (x << (32 - n))) & 0xffffffff;
}
