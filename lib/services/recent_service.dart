import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chain.dart';

class RecentEntry {
  final String query;
  final Chain? chain;
  final DateTime visitedAt;

  const RecentEntry({
    required this.query,
    required this.chain,
    required this.visitedAt,
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'chain': chain?.name,
        'visitedAt': visitedAt.millisecondsSinceEpoch,
      };

  factory RecentEntry.fromJson(Map<String, dynamic> j) {
    final c = j['chain'] as String?;
    return RecentEntry(
      query: j['query'] as String,
      chain: c == null
          ? null
          : Chain.values.firstWhere((e) => e.name == c,
              orElse: () => Chain.bitcoin),
      visitedAt: DateTime.fromMillisecondsSinceEpoch(j['visitedAt'] as int),
    );
  }
}

class RecentService extends ChangeNotifier {
  RecentService._(this._prefs, this._items);

  final SharedPreferences _prefs;
  final List<RecentEntry> _items;

  static const _prefsKey = 'hovuz.recent.v1';
  static const _maxItems = 50;

  static Future<RecentService> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final list = <RecentEntry>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        final js = jsonDecode(raw) as List;
        for (final j in js) {
          list.add(RecentEntry.fromJson(j as Map<String, dynamic>));
        }
      } catch (_) {}
    }
    return RecentService._(prefs, list);
  }

  List<RecentEntry> get all => List.unmodifiable(_items);

  Future<void> record(String query, Chain? chain) async {
    final q = query.trim();
    if (q.isEmpty) return;
    _items.removeWhere((e) => e.query == q);
    _items.insert(
        0, RecentEntry(query: q, chain: chain, visitedAt: DateTime.now()));
    if (_items.length > _maxItems) {
      _items.removeRange(_maxItems, _items.length);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs.setString(
        _prefsKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }
}
