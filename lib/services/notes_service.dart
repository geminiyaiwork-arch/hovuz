import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chain.dart';

/// User-attached private notes per (chain, address).
/// Stored locally in SharedPreferences — no cloud sync.
class AddressNote {
  final String address;
  final Chain chain;
  final String text;
  final DateTime updatedAt;

  const AddressNote({
    required this.address,
    required this.chain,
    required this.text,
    required this.updatedAt,
  });

  String get key => '${chain.name}:$address';

  Map<String, dynamic> toJson() => {
        'address': address,
        'chain': chain.name,
        'text': text,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory AddressNote.fromJson(Map<String, dynamic> j) {
    return AddressNote(
      address: j['address'] as String,
      chain: Chain.values.firstWhere(
        (e) => e.name == (j['chain'] as String? ?? 'bitcoin'),
        orElse: () => Chain.bitcoin,
      ),
      text: j['text'] as String? ?? '',
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
          (j['updatedAt'] as int?) ?? 0),
    );
  }
}

class NotesService extends ChangeNotifier {
  NotesService._(this._prefs, this._items);

  final SharedPreferences _prefs;
  final Map<String, AddressNote> _items;

  static const _prefsKey = 'hovuz.notes.v1';

  static Future<NotesService> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final items = <String, AddressNote>{};
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        for (final j in list) {
          final n = AddressNote.fromJson(j as Map<String, dynamic>);
          items[n.key] = n;
        }
      } catch (_) {}
    }
    return NotesService._(prefs, items);
  }

  Iterable<AddressNote> get all => _items.values;
  int get length => _items.length;

  AddressNote? get(String address, Chain chain) =>
      _items['${chain.name}:$address'];

  Future<void> set(String address, Chain chain, String text) async {
    final k = '${chain.name}:$address';
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _items.remove(k);
    } else {
      _items[k] = AddressNote(
        address: address,
        chain: chain,
        text: trimmed,
        updatedAt: DateTime.now(),
      );
    }
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String address, Chain chain) =>
      set(address, chain, '');

  Future<void> _persist() async {
    final list = _items.values.map((n) => n.toJson()).toList();
    await _prefs.setString(_prefsKey, jsonEncode(list));
  }
}
