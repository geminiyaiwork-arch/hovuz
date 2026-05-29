import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../main.dart';
import '../models/chain.dart';
import '../models/transfer.dart';
import '../services/blockchain_service.dart';
import '../services/chain_detector.dart';
import '../services/name_resolver.dart';
import '../services/notes_service.dart';
import '../services/recent_service.dart';
import '../services/watchlist_service.dart';
import '../theme.dart';
import '../widgets/details_panel.dart';
import '../widgets/search_header.dart';
import '../widgets/summary_sidebar.dart';
import '../widgets/watchlist_panel.dart';
import 'about_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.watchlist,
    required this.notes,
    required this.recent,
  });

  final WatchlistService watchlist;
  final NotesService notes;
  final RecentService recent;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _NavEntry {
  final String query;
  final Chain? hint;
  final LookupResult result;
  final String? filterCounterparty;
  const _NavEntry({
    required this.query,
    required this.hint,
    required this.result,
    this.filterCounterparty,
  });
}

class _HomePageState extends State<HomePage> {
  final _detector = ChainDetector();
  final _service = BlockchainService();
  final _names = NameResolver();
  final _searchFocus = FocusNode();

  final List<_NavEntry> _history = [];
  int _index = -1;
  bool _busy = false;

  LookupResult? get _result => _index >= 0 ? _history[_index].result : null;
  String? get _filter =>
      _index >= 0 ? _history[_index].filterCounterparty : null;

  bool get _canBack => _index > 0;
  bool get _canForward => _index < _history.length - 1;

  Future<void> _search(String q, Chain? hint) async {
    setState(() => _busy = true);
    var query = q.trim();
    // Try ENS / SNS resolution first
    if (NameResolver.looksLikeEns(query) ||
        NameResolver.looksLikeSns(query)) {
      final resolved = await _names.resolve(query);
      if (resolved != null) {
        query = resolved.address;
        hint = resolved.chain;
      }
    }
    final d = _detector.detect(query, hint: hint);
    final r = await _service.lookup(d);
    await widget.recent.record(query, d.chain ?? hint);

    // If the lookup matches a watched address, record the poll.
    if (r.address != null) {
      final a = r.address!;
      if (widget.watchlist.contains(a.address, a.chain)) {
        await widget.watchlist.recordPoll(
          a.address,
          a.chain,
          balance: a.balanceNative,
          received: a.totalReceivedNative,
          sent: a.totalSentNative,
          at: DateTime.now(),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      // Trim forward history when starting a new branch.
      if (_canForward) {
        _history.removeRange(_index + 1, _history.length);
      }
      _history.add(_NavEntry(query: q.trim(), hint: hint, result: r));
      _index = _history.length - 1;
      _busy = false;
    });
  }

  void _back() {
    if (!_canBack) return;
    setState(() => _index--);
  }

  void _forward() {
    if (!_canForward) return;
    setState(() => _index++);
  }

  void _openAddress(String address) {
    if (address.isEmpty || address == '—') return;
    _search(address, null);
  }

  void _toggleFilter(String counterparty) {
    if (_index < 0) return;
    final current = _history[_index];
    final next = current.filterCounterparty == counterparty
        ? null
        : counterparty;
    setState(() {
      _history[_index] = _NavEntry(
        query: current.query,
        hint: current.hint,
        result: current.result,
        filterCounterparty: next,
      );
    });
  }

  Future<void> _showWatchlist() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WatchlistPanel(
        watchlist: widget.watchlist,
        onOpenAddress: (a) {
          Navigator.of(ctx).pop();
          _search(a, null);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyL):
            const _FocusSearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowLeft):
            const _BackIntent(),
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowRight):
            const _ForwardIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE):
            const _ExportIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyW):
            const _OpenWatchlistIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyT):
            const _CycleThemeIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(
            onInvoke: (_) {
              _searchFocus.requestFocus();
              return null;
            },
          ),
          _BackIntent: CallbackAction<_BackIntent>(
            onInvoke: (_) {
              _back();
              return null;
            },
          ),
          _ForwardIntent: CallbackAction<_ForwardIntent>(
            onInvoke: (_) {
              _forward();
              return null;
            },
          ),
          _OpenWatchlistIntent: CallbackAction<_OpenWatchlistIntent>(
            onInvoke: (_) {
              _showWatchlist();
              return null;
            },
          ),
          _CycleThemeIntent: CallbackAction<_CycleThemeIntent>(
            onInvoke: (_) {
              ThemeScope.of(context).cycle();
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: _buildScaffold(context)),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          SearchHeader(
            busy: _busy,
            canBack: _canBack,
            canForward: _canForward,
            onBack: _back,
            onForward: _forward,
            onSearch: _search,
            onAboutPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutPage()),
            ),
            onWatchlistPressed: _showWatchlist,
            watchlist: widget.watchlist,
            searchFocusNode: _searchFocus,
          ),
          // Alert banner if any watched address has an unseen change
          AnimatedBuilder(
            animation: widget.watchlist,
            builder: (context, _) {
              final pending = widget.watchlist.all
                  .where((w) => w.unseenChange != null)
                  .toList();
              if (pending.isEmpty) return const SizedBox.shrink();
              return _WatchAlertBanner(
                items: pending,
                onTap: (w) {
                  widget.watchlist.acknowledgeChange(w.address, w.chain);
                  _search(w.address, w.chain);
                },
                onDismiss: (w) => widget.watchlist
                    .acknowledgeChange(w.address, w.chain),
              );
            },
          ),
          Expanded(
            child: Row(
              children: [
                SummarySidebar(result: _result),
                Expanded(
                  child: DetailsPanel(
                    result: _result,
                    busy: _busy,
                    filterCounterparty: _filter,
                    onAddressTap: _openAddress,
                    onFilterToggle: _toggleFilter,
                    onClearFilter: () => _toggleFilter(_filter ?? ''),
                    watchlist: widget.watchlist,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
}

class _BackIntent extends Intent {
  const _BackIntent();
}

class _ForwardIntent extends Intent {
  const _ForwardIntent();
}

class _ExportIntent extends Intent {
  const _ExportIntent();
}

class _OpenWatchlistIntent extends Intent {
  const _OpenWatchlistIntent();
}

class _CycleThemeIntent extends Intent {
  const _CycleThemeIntent();
}

class _WatchAlertBanner extends StatelessWidget {
  const _WatchAlertBanner({
    required this.items,
    required this.onTap,
    required this.onDismiss,
  });

  final List<WatchedAddress> items;
  final void Function(WatchedAddress) onTap;
  final void Function(WatchedAddress) onDismiss;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: HovuzTheme.amber.withOpacity(0.10),
        border:
            Border(bottom: BorderSide(color: HovuzTheme.amber.withOpacity(0.4))),
      ),
      child: Column(
        children: [
          for (final w in items)
            InkWell(
              onTap: () => onTap(w),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded,
                        color: HovuzTheme.amber, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: w.unseenChange!.kind ==
                                    WatchedChangeKind.received
                                ? '${s.alertReceivedTitle}: '
                                : '${s.alertSentTitle}: ',
                            style: const TextStyle(
                              color: HovuzTheme.amber,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: w.address,
                            style: const TextStyle(
                              color: HovuzTheme.text,
                              fontFamily: 'monospace',
                              fontSize: 12.5,
                            ),
                          ),
                          TextSpan(
                            text: '  '
                                '${w.unseenChange!.delta >= 0 ? '+' : ''}${w.unseenChange!.delta.toStringAsFixed(8)} ${w.chain.nativeSymbol}',
                            style: TextStyle(
                              color: w.unseenChange!.delta >= 0
                                  ? HovuzTheme.green
                                  : HovuzTheme.red,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ]),
                      ),
                    ),
                    IconButton(
                      iconSize: 18,
                      tooltip: 'OK',
                      onPressed: () => onDismiss(w),
                      icon: const Icon(Icons.close_rounded,
                          color: HovuzTheme.textDim),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
