import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/strings.dart';
import '../models/chain.dart';
import '../models/transfer.dart';
import '../services/export_service.dart';
import '../services/jurisdictions.dart';
import '../services/pdf_report_service.dart';
import '../services/sanctions_list.dart';
import '../services/timezone_analyzer.dart';
import '../services/watchlist_service.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'coin_logo.dart';
import 'flow_diagram.dart';
import 'note_card.dart';
import 'portfolio_card.dart';
import 'risk_badge.dart';
import 'trace_card.dart';
import 'usd_tag.dart';
import 'whale_badge.dart';

class DetailsPanel extends StatelessWidget {
  const DetailsPanel({
    super.key,
    required this.result,
    required this.busy,
    required this.filterCounterparty,
    required this.onAddressTap,
    required this.onFilterToggle,
    required this.onClearFilter,
    required this.watchlist,
  });

  final LookupResult? result;
  final bool busy;
  final String? filterCounterparty;
  final void Function(String address) onAddressTap;
  final void Function(String counterparty) onFilterToggle;
  final VoidCallback onClearFilter;
  final WatchlistService watchlist;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    Widget body;
    if (busy) {
      body = _BusyView(s: s);
    } else if (result == null) {
      body = _EmptyView(s: s);
    } else if (result!.hasError) {
      body = _ErrorView(
        s: s,
        error: s.translateError(result!.errorCode!, result!.errorExtra),
      );
    } else if (result!.address != null) {
      body = _AddressView(
        a: result!.address!,
        s: s,
        filter: filterCounterparty,
        onAddressTap: onAddressTap,
        onFilterToggle: onFilterToggle,
        onClearFilter: onClearFilter,
        watchlist: watchlist,
        onExport: () => _exportAddress(context, result!.address!, s),
        onPdfExport: () => _exportPdf(context, result!.address!, s),
      );
    } else {
      body = _TxView(
        t: result!.transaction!,
        s: s,
        onAddressTap: onAddressTap,
        onExport: () => _exportTransaction(context, result!.transaction!, s),
      );
    }
    return Container(
      decoration: const BoxDecoration(gradient: HovuzTheme.bgGradient),
      child: body,
    );
  }

  Future<void> _exportAddress(
      BuildContext context, AddressSummary a, S s) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      content: Text(s.exportInProgress),
      duration: const Duration(seconds: 1),
    ));
    try {
      final tz = TimezoneAnalyzer.analyze(a.recentTransfers);
      final r = await ExportService.exportAddress(a, s: s, tz: tz);
      if (r == null) return;
      messenger.showSnackBar(SnackBar(
        backgroundColor: HovuzTheme.green,
        content: Text(s.exportSuccess(r.path),
            style: const TextStyle(color: Colors.white)),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        backgroundColor: HovuzTheme.red,
        content: Text('${s.exportFailed}: $e',
            style: const TextStyle(color: Colors.white)),
      ));
    }
  }

  Future<void> _exportPdf(
      BuildContext context, AddressSummary a, S s) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      content: Text(s.exportInProgress),
      duration: const Duration(seconds: 1),
    ));
    try {
      final r = await PdfReportService.exportAddress(a, s: s);
      if (r == null) return;
      messenger.showSnackBar(SnackBar(
        backgroundColor: HovuzTheme.green,
        content: Text(s.exportSuccess(r.path),
            style: const TextStyle(color: Colors.white)),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        backgroundColor: HovuzTheme.red,
        content: Text('${s.exportFailed}: $e',
            style: const TextStyle(color: Colors.white)),
      ));
    }
  }

  Future<void> _exportTransaction(
      BuildContext context, TransactionInfo t, S s) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      content: Text(s.exportInProgress),
      duration: const Duration(seconds: 1),
    ));
    try {
      final r = await ExportService.exportTransaction(t, s: s);
      if (r == null) return;
      messenger.showSnackBar(SnackBar(
        backgroundColor: HovuzTheme.green,
        content: Text(s.exportSuccess(r.path),
            style: const TextStyle(color: Colors.white)),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        backgroundColor: HovuzTheme.red,
        content: Text('${s.exportFailed}: $e',
            style: const TextStyle(color: Colors.white)),
      ));
    }
  }
}

// =====================================================================
// Empty / Busy / Error
// =====================================================================

class _BusyView extends StatelessWidget {
  const _BusyView({required this.s});
  final S s;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: HovuzTheme.brand),
            const SizedBox(height: 16),
            Text(
              s.loadingBlockchain,
              style: const TextStyle(color: HovuzTheme.textDim),
            ),
          ],
        ),
      );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.s});
  final S s;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Image.asset(
                'images/logo.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              s.appName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: HovuzTheme.brand,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              s.appDescription,
              style:
                  const TextStyle(color: HovuzTheme.textDim, fontSize: 14),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 540,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HovuzTheme.surface,
                  border: Border.all(color: HovuzTheme.border),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: HovuzTheme.softShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      s.appLongDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: HovuzTheme.text,
                        height: 1.6,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: const [
                        _ChainPill(code: 'BTC'),
                        _ChainPill(code: 'ETH'),
                        _ChainPill(code: 'TRX'),
                        _ChainPill(code: 'BNB'),
                        _ChainPill(code: 'SOL'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChainPill extends StatelessWidget {
  const _ChainPill({required this.code});
  final String code;
  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
      decoration: BoxDecoration(
        color: HovuzTheme.chainColor(code).withOpacity(0.08),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
            color: HovuzTheme.chainColor(code).withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CoinLogo(symbol: code, size: 24, glow: false),
          const SizedBox(width: 8),
          Text(
            s.chainLong(code),
            style: TextStyle(
              color: HovuzTheme.chainColor(code),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.s});
  final String error;
  final S s;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Container(
          padding: const EdgeInsets.all(28),
          constraints: const BoxConstraints(maxWidth: 540),
          decoration: BoxDecoration(
            color: HovuzTheme.surface,
            border: Border.all(color: HovuzTheme.red.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: HovuzTheme.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: HovuzTheme.red.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: HovuzTheme.red, size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                s.requestFailed,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: HovuzTheme.textDim, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Transaction view
// =====================================================================

class _TxView extends StatefulWidget {
  const _TxView({
    required this.t,
    required this.s,
    required this.onAddressTap,
    required this.onExport,
  });
  final TransactionInfo t;
  final S s;
  final void Function(String) onAddressTap;
  final VoidCallback onExport;

  @override
  State<_TxView> createState() => _TxViewState();
}

class _TxViewState extends State<_TxView> {
  static const _pageSize = 10;
  int _shown = _pageSize;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final s = widget.s;
    final isOk = t.status == 'success' ||
        t.status == 'confirmed' ||
        t.status == 'SUCCESS';
    final visible = t.transfers.take(_shown).toList();
    final hasMore = _shown < t.transfers.length;

    final sanctionHits = _scanSanctionsInTx(t);
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        _Header(
          icon: Icons.receipt_long_rounded,
          title: s.transactionTitle,
          chainCode: t.chain.nativeSymbol,
          chainLabel: t.chain.label,
          explorerUrl: _explorerTx(t.chain, t.hash),
          onExport: widget.onExport,
        ),
        if (sanctionHits.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SanctionsBanner(hits: sanctionHits, s: s),
        ],
        const SizedBox(height: 18),
        _KvCard(rows: [
          _Kv(s.txId, t.hash, copyable: true),
          _Kv(s.status, t.status ?? '—', isStatus: true, ok: isOk),
          _Kv(s.block, '${t.blockHeight ?? '—'}'),
          _Kv(s.time, fmtTime(t.time)),
          if (t.feeNative != null)
            _Kv(s.fee,
                '${fmtAmount(t.feeNative!)} ${t.chain.nativeSymbol}'),
          if (t.rawSender != null)
            _Kv(s.sender, t.rawSender!,
                copyable: true,
                clickable: true,
                onClick: () => widget.onAddressTap(t.rawSender!)),
          if (t.rawReceiver != null)
            _Kv(s.receiver, t.rawReceiver!,
                copyable: true,
                clickable: true,
                onClick: () => widget.onAddressTap(t.rawReceiver!)),
          if (t.rawReceiver != null)
            _Kv(s.currentLocation, t.rawReceiver!,
                isLocation: true,
                onClick: () => widget.onAddressTap(t.rawReceiver!)),
        ]),
        const SizedBox(height: 28),
        _SectionTitle(s.transfersCount, count: t.transfers.length),
        const SizedBox(height: 12),
        if (t.transfers.isEmpty)
          _muted(s.noValueTransferInTx)
        else ...[
          ...visible.map((tr) => _TransferTile(
                t: tr,
                s: s,
                owner: null,
                onAddressTap: widget.onAddressTap,
              )),
          if (hasMore)
            _LoadMoreButton(
              label: s.loadMore,
              remaining: t.transfers.length - _shown,
              onTap: () => setState(() => _shown += _pageSize),
            ),
        ],
      ],
    );
  }
}

// =====================================================================
// Address view
// =====================================================================

class _AddressView extends StatefulWidget {
  const _AddressView({
    required this.a,
    required this.s,
    required this.filter,
    required this.onAddressTap,
    required this.onFilterToggle,
    required this.onClearFilter,
    required this.watchlist,
    required this.onExport,
    required this.onPdfExport,
  });
  final AddressSummary a;
  final S s;
  final String? filter;
  final void Function(String) onAddressTap;
  final void Function(String) onFilterToggle;
  final VoidCallback onClearFilter;
  final WatchlistService watchlist;
  final VoidCallback onExport;
  final VoidCallback onPdfExport;

  @override
  State<_AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<_AddressView> {
  static const _pageSize = 12;
  int _shown = _pageSize;

  @override
  Widget build(BuildContext context) {
    final a = widget.a;
    final s = widget.s;
    final sym = a.chain.nativeSymbol;

    // Apply filter if active
    List<Transfer> filtered = a.recentTransfers;
    if (widget.filter != null && widget.filter!.isNotEmpty) {
      final f = widget.filter!.toLowerCase();
      filtered = a.recentTransfers
          .where((t) =>
              t.from.toLowerCase() == f || t.to.toLowerCase() == f)
          .toList();
    }

    // Group remaining transfers by counterparty (for first display).
    final grouped = _groupByCounterparty(a.address, filtered);
    final visible = grouped.take(_shown).toList();
    final hasMore = _shown < grouped.length;

    final sanctionHits = _scanSanctionsInAddress(a);
    final tz = TimezoneAnalyzer.analyze(a.recentTransfers);
    final jurisdiction = a.label != null
        ? Jurisdictions.lookup(a.label!.split('·').first.trim())
        : null;
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        _Header(
          icon: Icons.account_balance_wallet_rounded,
          title: s.walletTitle,
          chainCode: sym,
          chainLabel: a.chain.label,
          explorerUrl: _explorerAddr(a.chain, a.address),
          watchTarget: a.address,
          watchChain: a.chain,
          watchlist: widget.watchlist,
          onExport: widget.onExport,
          onPdfExport: widget.onPdfExport,
        ),
        if (sanctionHits.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SanctionsBanner(hits: sanctionHits, s: s),
        ],
        const SizedBox(height: 18),
        _KvCard(rows: [
          _Kv(s.addressField, a.address, copyable: true),
          if (a.label != null) _Kv(s.labelField, a.label!, isLabel: true),
          if (jurisdiction != null)
            _Kv(
              s.jurisdictionLabel,
              '${jurisdiction.flag} ${jurisdiction.country}'
              '${jurisdiction.regulator != null ? ' · ${jurisdiction.regulator}' : ''}',
              isJurisdiction: true,
            ),
          _Kv(s.currentBalance, '${fmtAmount(a.balanceNative)} $sym'),
          _Kv(s.totalReceived, '${fmtAmount(a.totalReceivedNative)} $sym'),
          _Kv(s.totalSent, '${fmtAmount(a.totalSentNative)} $sym'),
          _Kv(s.transactionsField, '${a.txCount}'),
        ]),
        const SizedBox(height: 16),
        RiskBadge(address: a),
        if (a.chain.isEvm ||
            a.chain == Chain.tron ||
            a.chain == Chain.solana) ...[
          const SizedBox(height: 16),
          PortfolioCard(address: a.address, chain: a.chain),
        ],
        if (a.recentTransfers.length >= 2) ...[
          const SizedBox(height: 16),
          FlowDiagram(
            address: a.address,
            transfers: a.recentTransfers,
            onAddressTap: widget.onAddressTap,
          ),
        ],
        const SizedBox(height: 16),
        NoteCard(address: a.address, chain: a.chain),
        const SizedBox(height: 16),
        TraceCard(
          address: a.address,
          chain: a.chain,
          onAddressTap: widget.onAddressTap,
        ),
        if (tz.sampleSize >= 5) ...[
          const SizedBox(height: 16),
          _TimezoneCard(tz: tz, s: s),
        ],
        if (widget.filter != null) ...[
          const SizedBox(height: 18),
          _FilterChip(
            target: widget.filter!,
            label: s.filteredBy,
            clearLabel: s.clearFilter,
            onClear: widget.onClearFilter,
          ),
        ],
        const SizedBox(height: 28),
        _SectionTitle(s.recentTransfers, count: filtered.length),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          _muted(s.noTransfersFound)
        else ...[
          ...visible.map((g) => _GroupBlock(
                group: g,
                s: s,
                owner: a.address,
                onAddressTap: widget.onAddressTap,
                onFilterToggle: widget.onFilterToggle,
              )),
          if (hasMore)
            _LoadMoreButton(
              label: s.loadMore,
              remaining: grouped.length - _shown,
              onTap: () => setState(() => _shown += _pageSize),
            ),
        ],
      ],
    );
  }
}

class _TransferGroup {
  final String? counterparty; // null = self/unrelated bucket
  final List<Transfer> transfers;
  const _TransferGroup(this.counterparty, this.transfers);
  int get count => transfers.length;
}

List<_TransferGroup> _groupByCounterparty(
    String owner, List<Transfer> all) {
  final map = <String, List<Transfer>>{};
  for (final t in all) {
    final cp = t.counterpartyFor(owner) ?? '__self__';
    (map[cp] ??= []).add(t);
  }
  final groups = map.entries
      .map((e) => _TransferGroup(
            e.key == '__self__' ? null : e.key,
            e.value,
          ))
      .toList();
  // Sort by latest activity desc.
  groups.sort((a, b) {
    final at = a.transfers.first.time;
    final bt = b.transfers.first.time;
    if (at == null || bt == null) return 0;
    return bt.compareTo(at);
  });
  return groups;
}

class _GroupBlock extends StatelessWidget {
  const _GroupBlock({
    required this.group,
    required this.s,
    required this.owner,
    required this.onAddressTap,
    required this.onFilterToggle,
  });

  final _TransferGroup group;
  final S s;
  final String owner;
  final void Function(String) onAddressTap;
  final void Function(String) onFilterToggle;

  @override
  Widget build(BuildContext context) {
    final cp = group.counterparty;
    if (cp != null && group.count > 1) {
      // Multi-tx header + first transfer expanded
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: HovuzTheme.brand.withOpacity(0.06),
              border: Border.all(color: HovuzTheme.brand.withOpacity(0.18)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.dynamic_feed_rounded,
                    size: 14, color: HovuzTheme.brand),
                const SizedBox(width: 6),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text(
                        s.txCountWith(group.count),
                        style: const TextStyle(
                          color: HovuzTheme.brand,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '·',
                        style: TextStyle(
                            color: HovuzTheme.brand.withOpacity(0.5)),
                      ),
                      SelectableText(
                        cp,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: HovuzTheme.text,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => onFilterToggle(cp),
                  icon: const Icon(Icons.filter_alt_rounded, size: 14),
                  label: Text(
                    s.filterByAddress,
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: HovuzTheme.brand,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),
          ...group.transfers.map((t) => _TransferTile(
                t: t,
                s: s,
                owner: owner,
                onAddressTap: onAddressTap,
              )),
        ],
      );
    }
    // Single transfer or self group — render directly
    return Column(
      children: group.transfers
          .map((t) => _TransferTile(
                t: t,
                s: s,
                owner: owner,
                onAddressTap: onAddressTap,
              ))
          .toList(),
    );
  }
}

// =====================================================================
// Header (with watchlist heart)
// =====================================================================

class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.title,
    required this.chainCode,
    required this.chainLabel,
    this.explorerUrl,
    this.watchTarget,
    this.watchChain,
    this.watchlist,
    this.onExport,
    this.onPdfExport,
  });

  final IconData icon;
  final String title;
  final String chainCode;
  final String chainLabel;
  final String? explorerUrl;
  final String? watchTarget;
  final Chain? watchChain;
  final WatchlistService? watchlist;
  final VoidCallback? onExport;
  final VoidCallback? onPdfExport;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = HovuzTheme.chainColor(chainCode);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HovuzTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HovuzTheme.border),
        boxShadow: HovuzTheme.softShadow,
      ),
      child: Row(
        children: [
          CoinLogo(symbol: chainCode, size: 52),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(icon, size: 14, color: c),
                    const SizedBox(width: 6),
                    Text(chainLabel,
                        style: TextStyle(
                            color: c,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          if (watchTarget != null && watchChain != null && watchlist != null)
            AnimatedBuilder(
              animation: watchlist!,
              builder: (context, _) {
                final on = watchlist!.contains(watchTarget!, watchChain!);
                return Tooltip(
                  message:
                      on ? s.removeFromWatchlist : s.addToWatchlist,
                  child: Material(
                    color: on
                        ? HovuzTheme.red.withOpacity(0.10)
                        : HovuzTheme.surface2,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => watchlist!
                          .toggle(watchTarget!, watchChain!),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          on
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: on ? HovuzTheme.red : HovuzTheme.textDim,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          if (watchTarget != null) const SizedBox(width: 8),
          if (onExport != null)
            Container(
              decoration: BoxDecoration(
                color: HovuzTheme.green.withOpacity(0.10),
                border: Border.all(color: HovuzTheme.green.withOpacity(0.30)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onExport,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.table_chart_rounded,
                            size: 16, color: HovuzTheme.green),
                        const SizedBox(width: 6),
                        Text(s.exportButton,
                            style: const TextStyle(
                              color: HovuzTheme.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (onExport != null) const SizedBox(width: 8),
          if (onPdfExport != null)
            Container(
              decoration: BoxDecoration(
                color: HovuzTheme.red.withOpacity(0.10),
                border: Border.all(color: HovuzTheme.red.withOpacity(0.30)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPdfExport,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded,
                            size: 16, color: HovuzTheme.red),
                        const SizedBox(width: 6),
                        Text(s.pdfExportButton,
                            style: const TextStyle(
                              color: HovuzTheme.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (onPdfExport != null) const SizedBox(width: 8),
          if (explorerUrl != null)
            Container(
              decoration: BoxDecoration(
                color: HovuzTheme.surface2,
                border: Border.all(color: HovuzTheme.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => launchUrl(Uri.parse(explorerUrl!),
                      mode: LaunchMode.externalApplication),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.open_in_new_rounded,
                            size: 16, color: HovuzTheme.text),
                        const SizedBox(width: 6),
                        Text(s.explorerButton,
                            style: const TextStyle(
                              color: HovuzTheme.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =====================================================================
// KV
// =====================================================================

class _Kv {
  final String k;
  final String v;
  final bool copyable;
  final bool isStatus;
  final bool ok;
  final bool isLabel;
  final bool isLocation;
  final bool clickable;
  final bool isJurisdiction;
  final VoidCallback? onClick;
  const _Kv(this.k, this.v,
      {this.copyable = false,
      this.isStatus = false,
      this.ok = false,
      this.isLabel = false,
      this.isLocation = false,
      this.clickable = false,
      this.isJurisdiction = false,
      this.onClick});
}

class _KvCard extends StatelessWidget {
  const _KvCard({required this.rows});
  final List<_Kv> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HovuzTheme.surface,
        border: Border.all(color: HovuzTheme.border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: HovuzTheme.softShadow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      rows[i].k,
                      style: const TextStyle(
                          color: HovuzTheme.textDim,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(child: _kvValue(rows[i])),
                  if (rows[i].copyable)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => Clipboard.setData(
                            ClipboardData(text: rows[i].v)),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.copy_rounded,
                              size: 14, color: HovuzTheme.textDim),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              const Divider(height: 1, color: HovuzTheme.borderSoft),
          ],
        ],
      ),
    );
  }

  Widget _kvValue(_Kv r) {
    if (r.isStatus) {
      final color = r.ok ? HovuzTheme.green : HovuzTheme.amber;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              r.v,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
      );
    }
    if (r.isLabel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: HovuzTheme.goldGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                r.v,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
    if (r.isJurisdiction) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: HovuzTheme.brand.withOpacity(0.08),
          border: Border.all(color: HovuzTheme.brand.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          r.v,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: HovuzTheme.brandDeep,
          ),
        ),
      );
    }
    if (r.isLocation) {
      return InkWell(
        onTap: r.onClick,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: HovuzTheme.green.withOpacity(0.10),
            border: Border.all(color: HovuzTheme.green.withOpacity(0.30)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.place_rounded,
                  size: 14, color: HovuzTheme.green),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  r.v,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: HovuzTheme.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (r.clickable) {
      return InkWell(
        onTap: r.onClick,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            r.v,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              color: HovuzTheme.brand,
              decoration: TextDecoration.underline,
              decorationColor: Color(0x55154AAB),
            ),
          ),
        ),
      );
    }
    return SelectableText(
      r.v,
      style: const TextStyle(
        fontSize: 13,
        fontFamily: 'monospace',
        color: HovuzTheme.text,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.count});
  final String text;
  final int count;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: HovuzTheme.text)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: HovuzTheme.brand.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: HovuzTheme.brandDeep,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _muted(String s) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HovuzTheme.surface,
        border: Border.all(color: HovuzTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(s, style: const TextStyle(color: HovuzTheme.textDim)),
    );

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.target,
    required this.label,
    required this.clearLabel,
    required this.onClear,
  });
  final String target;
  final String label;
  final String clearLabel;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: HovuzTheme.brand.withOpacity(0.10),
        border: Border.all(color: HovuzTheme.brand.withOpacity(0.30)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_rounded,
              size: 16, color: HovuzTheme.brand),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              color: HovuzTheme.brand,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              target,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: HovuzTheme.text,
              ),
            ),
          ),
          const SizedBox(width: 10),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 14),
            label: Text(clearLabel),
            style: TextButton.styleFrom(
              foregroundColor: HovuzTheme.red,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({
    required this.label,
    required this.remaining,
    required this.onTap,
  });
  final String label;
  final int remaining;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: HovuzTheme.brand,
            side: BorderSide(color: HovuzTheme.brand.withOpacity(0.4)),
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          icon: const Icon(Icons.unfold_more_rounded, size: 16),
          label: Text('$label  (+$remaining)'),
        ),
      ),
    );
  }
}

// =====================================================================
// Transfer tile
// =====================================================================

class _TransferTile extends StatelessWidget {
  const _TransferTile({
    required this.t,
    required this.s,
    required this.owner,
    required this.onAddressTap,
  });
  final Transfer t;
  final S s;
  final String? owner;
  final void Function(String) onAddressTap;

  @override
  Widget build(BuildContext context) {
    final dir = t.directionFor(owner);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HovuzTheme.surface,
        border: Border.all(color: HovuzTheme.border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: HovuzTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CoinLogo(symbol: t.symbol, size: 32),
              const SizedBox(width: 10),
              Text(
                fmtAmount(t.amount),
                style: const TextStyle(
                  color: HovuzTheme.text,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                t.symbol,
                style: TextStyle(
                  color: HovuzTheme.chainColor(t.symbol),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              UsdTag(symbol: t.symbol, amount: t.amount),
              WhaleBadge(symbol: t.symbol, amount: t.amount),
              const SizedBox(width: 10),
              if (dir == TransferDirection.sent ||
                  dir == TransferDirection.received ||
                  dir == TransferDirection.selfTransfer)
                _DirectionBadge(dir: dir, s: s),
              const Spacer(),
              if (t.time != null)
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 13, color: HovuzTheme.textDim),
                    const SizedBox(width: 4),
                    Text(
                      fmtTime(t.time),
                      style: const TextStyle(
                          color: HovuzTheme.textDim, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
          if (t.contractAddress != null) ...[
            const SizedBox(height: 10),
            _ContractRow(
                contract: t.contractAddress!, label: s.contractAddress),
          ],
          const SizedBox(height: 14),
          _PartyRow(
            icon: Icons.north_east_rounded,
            color: HovuzTheme.red,
            label: s.fromShort,
            addr: t.from,
            tag: t.fromLabel,
            onAddressTap: onAddressTap,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: Container(
              width: 1,
              height: 12,
              color: HovuzTheme.border,
            ),
          ),
          const SizedBox(height: 6),
          _PartyRow(
            icon: Icons.south_west_rounded,
            color: HovuzTheme.green,
            label: s.toShort,
            addr: t.to,
            tag: t.toLabel,
            onAddressTap: onAddressTap,
          ),
        ],
      ),
    );
  }
}

class _DirectionBadge extends StatelessWidget {
  const _DirectionBadge({required this.dir, required this.s});
  final TransferDirection dir;
  final S s;
  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;
    switch (dir) {
      case TransferDirection.sent:
        color = HovuzTheme.red;
        text = s.directionSent;
        icon = Icons.north_east_rounded;
        break;
      case TransferDirection.received:
        color = HovuzTheme.green;
        text = s.directionReceived;
        icon = Icons.south_west_rounded;
        break;
      case TransferDirection.selfTransfer:
        color = HovuzTheme.brand;
        text = s.directionSelfTransfer;
        icon = Icons.refresh_rounded;
        break;
      case TransferDirection.unrelated:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractRow extends StatelessWidget {
  const _ContractRow({required this.contract, required this.label});
  final String contract;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: HovuzTheme.brand.withOpacity(0.06),
        border: Border.all(color: HovuzTheme.brand.withOpacity(0.18)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_rounded,
              size: 13, color: HovuzTheme.brand),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: HovuzTheme.brand,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: SelectableText(
              contract,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                color: HovuzTheme.text,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () =>
                  Clipboard.setData(ClipboardData(text: contract)),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.copy_rounded,
                    size: 12, color: HovuzTheme.textDim),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyRow extends StatelessWidget {
  const _PartyRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.addr,
    required this.onAddressTap,
    this.tag,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String addr;
  final String? tag;
  final void Function(String) onAddressTap;

  bool get _isTappable => addr.isNotEmpty && addr != '—';

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: const TextStyle(
                color: HovuzTheme.textDim,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ),
        Flexible(
          child: _isTappable
              ? InkWell(
                  onTap: () => onAddressTap(addr),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      addr,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: HovuzTheme.brand,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0x55154AAB),
                      ),
                    ),
                  ),
                )
              : SelectableText(
                  addr,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: HovuzTheme.text,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        if (tag != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: HovuzTheme.goldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.business_rounded,
                    size: 11, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  tag!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => Clipboard.setData(ClipboardData(text: addr)),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.copy_rounded,
                  size: 13, color: HovuzTheme.textDim),
            ),
          ),
        ),
        if (_isTappable)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => onAddressTap(addr),
              child: Tooltip(
                message: s.openInNewView,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 13, color: HovuzTheme.brand),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// =====================================================================
// Sanctions scan + banner + timezone card
// =====================================================================

class _SanctionHit {
  final String address;
  final SanctionEntry entry;
  const _SanctionHit({required this.address, required this.entry});
}

List<_SanctionHit> _scanSanctionsInTx(TransactionInfo t) {
  final out = <_SanctionHit>{};
  void check(String? a) {
    if (a == null || a.isEmpty || a == '—') return;
    SanctionEntry? hit;
    if (a.startsWith('0x')) {
      hit = SanctionsList.lookupEvm(a);
    } else if (a.startsWith('T') && a.length == 34) {
      hit = SanctionsList.lookupTron(a);
    } else {
      hit = SanctionsList.lookupBtc(a);
    }
    if (hit != null) out.add(_SanctionHit(address: a, entry: hit));
  }

  check(t.rawSender);
  check(t.rawReceiver);
  for (final tr in t.transfers) {
    check(tr.from);
    check(tr.to);
  }
  return out.toList();
}

List<_SanctionHit> _scanSanctionsInAddress(AddressSummary a) {
  final out = <_SanctionHit>{};
  void check(String? addr) {
    if (addr == null || addr.isEmpty || addr == '—') return;
    SanctionEntry? hit;
    if (addr.startsWith('0x')) {
      hit = SanctionsList.lookupEvm(addr);
    } else if (addr.startsWith('T') && addr.length == 34) {
      hit = SanctionsList.lookupTron(addr);
    } else {
      hit = SanctionsList.lookupBtc(addr);
    }
    if (hit != null) out.add(_SanctionHit(address: addr, entry: hit));
  }

  check(a.address);
  for (final t in a.recentTransfers) {
    check(t.from);
    check(t.to);
  }
  return out.toList();
}

class _SanctionsBanner extends StatelessWidget {
  const _SanctionsBanner({required this.hits, required this.s});
  final List<_SanctionHit> hits;
  final S s;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HovuzTheme.red.withOpacity(0.08),
        border: Border.all(color: HovuzTheme.red.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: HovuzTheme.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.gavel_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      s.sanctionsBadge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.sanctionsHeader,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: HovuzTheme.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            s.sanctionsBody,
            style: const TextStyle(
                color: HovuzTheme.textDim, fontSize: 12.5, height: 1.5),
          ),
          const SizedBox(height: 12),
          for (final h in hits)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: HovuzTheme.surface,
                border: Border.all(color: HovuzTheme.red.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_rounded,
                      color: HovuzTheme.red, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${h.entry.entity} · ${h.entry.date}',
                          style: const TextStyle(
                            color: HovuzTheme.red,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SelectableText(
                          h.address,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: HovuzTheme.text,
                          ),
                        ),
                        Text(
                          h.entry.reason,
                          style: const TextStyle(
                            color: HovuzTheme.textDim,
                            fontSize: 11,
                          ),
                        ),
                      ],
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

class _TimezoneCard extends StatelessWidget {
  const _TimezoneCard({required this.tz, required this.s});
  final TimezoneEstimate tz;
  final S s;

  @override
  Widget build(BuildContext context) {
    final maxBucket = tz.hourHistogramUtc
        .fold<int>(0, (a, b) => b > a ? b : a)
        .toDouble();
    String summary;
    Color summaryColor = HovuzTheme.text;
    if (tz.algorithmic) {
      summary = s.tzAlgorithmic;
      summaryColor = HovuzTheme.brand;
    } else if (tz.offsetHours != null) {
      final off = tz.offsetHours!;
      summary =
          'UTC${off >= 0 ? '+' : ''}$off · ${tz.regionHint ?? ''}';
      summaryColor = HovuzTheme.green;
    } else {
      summary = s.tzInsufficient;
      summaryColor = HovuzTheme.textDim;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HovuzTheme.surface,
        border: Border.all(color: HovuzTheme.border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: HovuzTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.public_rounded,
                  color: HovuzTheme.brand, size: 18),
              const SizedBox(width: 8),
              Text(
                s.tzAnalysisTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: HovuzTheme.text,
                ),
              ),
              const Spacer(),
              Text(
                '${s.tzSamples}: ${tz.sampleSize}',
                style: const TextStyle(
                    color: HovuzTheme.textDim, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: TextStyle(
              color: summaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (!tz.algorithmic && tz.offsetHours != null) ...[
            const SizedBox(height: 4),
            Text(
              '${s.tzConfidence}: ${(tz.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                  color: HovuzTheme.textDim, fontSize: 11),
            ),
          ],
          const SizedBox(height: 12),
          // 24-bar histogram
          SizedBox(
            height: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var h = 0; h < 24; h++)
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        height: maxBucket == 0
                            ? 2
                            : (tz.hourHistogramUtc[h] / maxBucket) * 40 + 2,
                        decoration: BoxDecoration(
                          gradient: HovuzTheme.brandGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('00 UTC',
                  style: TextStyle(
                      color: HovuzTheme.textDim, fontSize: 10)),
              Text('12',
                  style: TextStyle(
                      color: HovuzTheme.textDim, fontSize: 10)),
              Text('23',
                  style: TextStyle(
                      color: HovuzTheme.textDim, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

String _explorerTx(Chain c, String hash) {
  switch (c) {
    case Chain.bitcoin:
      return 'https://blockstream.info/tx/$hash';
    case Chain.ethereum:
      return 'https://etherscan.io/tx/$hash';
    case Chain.tron:
      return 'https://tronscan.org/#/transaction/$hash';
    case Chain.bsc:
      return 'https://bscscan.com/tx/$hash';
    case Chain.solana:
      return 'https://solscan.io/tx/$hash';
    case Chain.polygon:
      return 'https://polygonscan.com/tx/$hash';
    case Chain.arbitrum:
      return 'https://arbiscan.io/tx/$hash';
    case Chain.optimism:
      return 'https://optimistic.etherscan.io/tx/$hash';
    case Chain.base:
      return 'https://basescan.org/tx/$hash';
  }
}

String _explorerAddr(Chain c, String addr) {
  switch (c) {
    case Chain.bitcoin:
      return 'https://blockstream.info/address/$addr';
    case Chain.ethereum:
      return 'https://etherscan.io/address/$addr';
    case Chain.tron:
      return 'https://tronscan.org/#/address/$addr';
    case Chain.bsc:
      return 'https://bscscan.com/address/$addr';
    case Chain.solana:
      return 'https://solscan.io/account/$addr';
    case Chain.polygon:
      return 'https://polygonscan.com/address/$addr';
    case Chain.arbitrum:
      return 'https://arbiscan.io/address/$addr';
    case Chain.optimism:
      return 'https://optimistic.etherscan.io/address/$addr';
    case Chain.base:
      return 'https://basescan.org/address/$addr';
  }
}
