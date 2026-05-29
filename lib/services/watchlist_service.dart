import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chain.dart';

class WatchedAddress {
  final String address;
  final Chain chain;

  /// Balance (native) at last poll. Null until first refresh.
  final double? lastBalance;
  final double? lastReceived;
  final double? lastSent;

  /// Last time we polled this address.
  final DateTime? lastChecked;

  /// Optional human note (e.g. "Binance hot wallet").
  final String? note;

  /// Most recent change detected. UI may display this once and clear it.
  final WatchedChange? unseenChange;

  const WatchedAddress({
    required this.address,
    required this.chain,
    this.lastBalance,
    this.lastReceived,
    this.lastSent,
    this.lastChecked,
    this.note,
    this.unseenChange,
  });

  String get key => '${chain.name}:$address';

  WatchedAddress copyWith({
    double? lastBalance,
    double? lastReceived,
    double? lastSent,
    DateTime? lastChecked,
    String? note,
    WatchedChange? unseenChange,
    bool clearUnseen = false,
  }) =>
      WatchedAddress(
        address: address,
        chain: chain,
        lastBalance: lastBalance ?? this.lastBalance,
        lastReceived: lastReceived ?? this.lastReceived,
        lastSent: lastSent ?? this.lastSent,
        lastChecked: lastChecked ?? this.lastChecked,
        note: note ?? this.note,
        unseenChange:
            clearUnseen ? null : (unseenChange ?? this.unseenChange),
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'chain': chain.name,
        'lastBalance': lastBalance,
        'lastReceived': lastReceived,
        'lastSent': lastSent,
        'lastChecked': lastChecked?.millisecondsSinceEpoch,
        'note': note,
        // unseenChange is in-memory; do not persist (would re-fire alerts)
      };

  factory WatchedAddress.fromJson(Map<String, dynamic> j) {
    final chainName = j['chain'] as String? ?? Chain.bitcoin.name;
    final c = Chain.values.firstWhere(
      (e) => e.name == chainName,
      orElse: () => Chain.bitcoin,
    );
    return WatchedAddress(
      address: j['address'] as String,
      chain: c,
      lastBalance: (j['lastBalance'] as num?)?.toDouble(),
      lastReceived: (j['lastReceived'] as num?)?.toDouble(),
      lastSent: (j['lastSent'] as num?)?.toDouble(),
      lastChecked: j['lastChecked'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(j['lastChecked'] as int),
      note: j['note'] as String?,
    );
  }
}

enum WatchedChangeKind { received, sent, generic }

class WatchedChange {
  final WatchedChangeKind kind;
  final double delta; // signed: positive = received, negative = sent
  final double newBalance;
  final DateTime detectedAt;

  const WatchedChange({
    required this.kind,
    required this.delta,
    required this.newBalance,
    required this.detectedAt,
  });
}

class WatchlistService extends ChangeNotifier {
  WatchlistService._(this._prefs, this._items);

  final SharedPreferences _prefs;
  final Map<String, WatchedAddress> _items;

  static const _prefsKey = 'hovuz.watchlist.v1';

  static Future<WatchlistService> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final items = <String, WatchedAddress>{};
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        for (final j in list) {
          final w = WatchedAddress.fromJson(j as Map<String, dynamic>);
          items[w.key] = w;
        }
      } catch (_) {
        // corrupted, start fresh
      }
    }
    return WatchlistService._(prefs, items);
  }

  Iterable<WatchedAddress> get all => _items.values;
  int get length => _items.length;

  bool contains(String address, Chain chain) =>
      _items.containsKey('${chain.name}:$address');

  WatchedAddress? get(String address, Chain chain) =>
      _items['${chain.name}:$address'];

  Future<void> add(String address, Chain chain, {String? note}) async {
    final k = '${chain.name}:$address';
    if (_items.containsKey(k)) return;
    _items[k] = WatchedAddress(
      address: address,
      chain: chain,
      note: note,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String address, Chain chain) async {
    final k = '${chain.name}:$address';
    if (_items.remove(k) != null) {
      await _persist();
      notifyListeners();
    }
  }

  Future<void> toggle(String address, Chain chain) async {
    contains(address, chain)
        ? await remove(address, chain)
        : await add(address, chain);
  }

  /// Update the recorded balance for an address after a successful refresh.
  /// Detects change vs previous lastBalance and stores it as unseenChange.
  Future<WatchedChange?> recordPoll(
    String address,
    Chain chain, {
    required double balance,
    required double received,
    required double sent,
    required DateTime at,
  }) async {
    final k = '${chain.name}:$address';
    final prev = _items[k];
    if (prev == null) return null;

    WatchedChange? change;
    if (prev.lastBalance != null) {
      final delta = balance - prev.lastBalance!;
      if (delta.abs() > 1e-12) {
        change = WatchedChange(
          kind: delta > 0
              ? WatchedChangeKind.received
              : WatchedChangeKind.sent,
          delta: delta,
          newBalance: balance,
          detectedAt: at,
        );
      }
    }
    _items[k] = prev.copyWith(
      lastBalance: balance,
      lastReceived: received,
      lastSent: sent,
      lastChecked: at,
      unseenChange: change ?? prev.unseenChange,
    );
    await _persist();
    notifyListeners();
    return change;
  }

  /// Mark the unseen change as acknowledged (clears the alert badge).
  Future<void> acknowledgeChange(String address, Chain chain) async {
    final k = '${chain.name}:$address';
    final prev = _items[k];
    if (prev == null || prev.unseenChange == null) return;
    _items[k] = prev.copyWith(clearUnseen: true);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final list = _items.values.map((w) => w.toJson()).toList();
    await _prefs.setString(_prefsKey, jsonEncode(list));
  }
}
