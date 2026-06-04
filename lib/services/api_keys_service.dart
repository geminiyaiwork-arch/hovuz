import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_keys.dart';

/// In-app override for blockchain API keys. Persists in SharedPreferences.
/// When the user pastes their Etherscan/TronGrid key in Settings, it's saved
/// here and the blockchain services pick it up automatically.
class ApiKeysService extends ChangeNotifier {
  ApiKeysService._(this._prefs, this._etherscan, this._tronGrid);

  final SharedPreferences _prefs;
  String _etherscan;
  String _tronGrid;

  static const _kEtherscan = 'hovuz.apikey.etherscan.v1';
  static const _kTronGrid = 'hovuz.apikey.trongrid.v1';

  static Future<ApiKeysService> load() async {
    final p = await SharedPreferences.getInstance();
    return ApiKeysService._(
      p,
      p.getString(_kEtherscan) ?? '',
      p.getString(_kTronGrid) ?? '',
    );
  }

  /// User-provided Etherscan V2 key (works for ETH, BSC, Polygon, Arbitrum,
  /// Optimism, Base under the same V2 multi-chain API). Falls back to the
  /// bundled placeholder if empty.
  String get etherscan =>
      _etherscan.isNotEmpty ? _etherscan : ApiKeys.etherscanDefault;

  /// True when the user has set a real (non-placeholder) Etherscan key.
  bool get hasEtherscan =>
      _etherscan.isNotEmpty && _etherscan != 'YourApiKeyToken';

  String get tronGrid =>
      _tronGrid.isNotEmpty ? _tronGrid : ApiKeys.tronGridDefault;

  bool get hasTronGrid => _tronGrid.isNotEmpty;

  /// Returns the raw, user-typed value (for showing it in the input field).
  String get rawEtherscan => _etherscan;
  String get rawTronGrid => _tronGrid;

  Future<void> setEtherscan(String value) async {
    final v = value.trim();
    if (v == _etherscan) return;
    _etherscan = v;
    if (v.isEmpty) {
      await _prefs.remove(_kEtherscan);
    } else {
      await _prefs.setString(_kEtherscan, v);
    }
    notifyListeners();
  }

  Future<void> setTronGrid(String value) async {
    final v = value.trim();
    if (v == _tronGrid) return;
    _tronGrid = v;
    if (v.isEmpty) {
      await _prefs.remove(_kTronGrid);
    } else {
      await _prefs.setString(_kTronGrid, v);
    }
    notifyListeners();
  }

  Future<void> clearAll() async {
    _etherscan = '';
    _tronGrid = '';
    await _prefs.remove(_kEtherscan);
    await _prefs.remove(_kTronGrid);
    notifyListeners();
  }
}
