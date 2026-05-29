import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../main.dart';
import '../models/transfer.dart';
import '../theme.dart';
import '../utils/format.dart';

class SummarySidebar extends StatelessWidget {
  const SummarySidebar({super.key, required this.result});

  final LookupResult? result;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final children = result == null
        ? _empty(s)
        : result!.hasError
            ? _error(
                s.translateError(result!.errorCode!, result!.errorExtra), s)
            : (result!.address != null
                ? _addressSummary(result!.address!, s)
                : _txSummary(result!.transaction!, s));
    return Container(
      width: 340,
      decoration: const BoxDecoration(
        color: HovuzTheme.bgSoft,
        border: Border(right: BorderSide(color: HovuzTheme.border)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        physics: const ClampingScrollPhysics(),
        children: children,
      ),
    );
  }

  List<Widget> _empty(S s) => [
        _Section(title: s.sectionGeneralBalance),
        const SizedBox(height: 14),
        _StatCard(
          label: s.currentBalance,
          value: '—',
          symbol: '',
          gradient: HovuzTheme.goldGradient,
          icon: Icons.account_balance_wallet_rounded,
          color: HovuzTheme.gold,
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: s.totalReceived,
          value: '—',
          symbol: '',
          color: HovuzTheme.green,
          icon: Icons.south_west_rounded,
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: s.totalSent,
          value: '—',
          symbol: '',
          color: HovuzTheme.red,
          icon: Icons.north_east_rounded,
        ),
        const SizedBox(height: 28),
        _ChainsLegend(supportedHeading: s.supportedHeading, s: s),
      ];

  List<Widget> _error(String err, S s) => [
        _Section(title: s.sectionError),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HovuzTheme.red.withOpacity(0.08),
            border: Border.all(color: HovuzTheme.red.withOpacity(0.35)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: HovuzTheme.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  err,
                  style: const TextStyle(
                    color: HovuzTheme.text,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ];

  List<Widget> _addressSummary(AddressSummary a, S s) {
    final sym = a.chain.nativeSymbol;
    return [
      _ChainBadge(
          symbol: sym, label: a.chain.label, network: s.networkWord),
      const SizedBox(height: 16),
      _Section(title: s.sectionGeneralBalance),
      const SizedBox(height: 14),
      _StatCard(
        label: s.currentBalance,
        value: fmtAmount(a.balanceNative),
        symbol: sym,
        gradient: HovuzTheme.chainGradient(sym),
        color: HovuzTheme.chainColor(sym),
        icon: Icons.account_balance_wallet_rounded,
        numericValue: a.balanceNative,
      ),
      const SizedBox(height: 12),
      _StatCard(
        label: s.totalReceivedMoney,
        value: fmtAmount(a.totalReceivedNative),
        symbol: sym,
        color: HovuzTheme.green,
        icon: Icons.south_west_rounded,
        numericValue: a.totalReceivedNative,
      ),
      const SizedBox(height: 12),
      _StatCard(
        label: s.totalSentMoney,
        value: fmtAmount(a.totalSentNative),
        symbol: sym,
        color: HovuzTheme.red,
        icon: Icons.north_east_rounded,
        numericValue: a.totalSentNative,
      ),
      const SizedBox(height: 16),
      _miniBlock([
        _Mini(s.txCount, '${a.txCount}'),
      ]),
      if (a.label != null) ...[
        const SizedBox(height: 14),
        _exchangeChip(a.label!),
      ],
    ];
  }

  List<Widget> _txSummary(TransactionInfo t, S s) {
    double totalOut = 0;
    final symbols = <String>{};
    for (final tr in t.transfers) {
      symbols.add(tr.symbol);
      totalOut += tr.amount;
    }
    final sym = symbols.length == 1 ? symbols.first : '';
    final isOk = (t.status == 'success' ||
        t.status == 'confirmed' ||
        t.status == 'SUCCESS');

    return [
      _ChainBadge(
        symbol: t.chain.nativeSymbol,
        label: t.chain.label,
        network: s.networkWord,
      ),
      const SizedBox(height: 16),
      _Section(title: s.sectionGeneralBalance),
      const SizedBox(height: 14),
      _StatCard(
        label: s.transferVolume,
        value: fmtAmount(totalOut),
        symbol: sym,
        gradient: HovuzTheme.chainGradient(t.chain.nativeSymbol),
        color: HovuzTheme.chainColor(t.chain.nativeSymbol),
        icon: Icons.swap_horiz_rounded,
        numericValue: totalOut,
      ),
      const SizedBox(height: 12),
      _StatCard(
        label: s.totalSent,
        value: fmtAmount(totalOut),
        symbol: sym,
        color: HovuzTheme.red,
        icon: Icons.north_east_rounded,
        numericValue: totalOut,
      ),
      const SizedBox(height: 12),
      _StatCard(
        label: s.totalReceived,
        value: fmtAmount(totalOut),
        symbol: sym,
        color: HovuzTheme.green,
        icon: Icons.south_west_rounded,
        numericValue: totalOut,
      ),
      const SizedBox(height: 16),
      _miniBlock([
        _Mini(s.status, t.status ?? '—',
            color: isOk ? HovuzTheme.green : HovuzTheme.amber),
        _Mini(s.block, '${t.blockHeight ?? '—'}'),
        _Mini(
          s.fee,
          t.feeNative != null
              ? '${fmtAmount(t.feeNative!)} ${t.chain.nativeSymbol}'
              : '—',
        ),
        _Mini(s.time, fmtTime(t.time)),
        _Mini(s.transfersCount, '${t.transfers.length}'),
      ]),
    ];
  }

  Widget _miniBlock(List<_Mini> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HovuzTheme.surface,
        border: Border.all(color: HovuzTheme.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: HovuzTheme.softShadow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Text(
                    items[i].label,
                    style: const TextStyle(
                      color: HovuzTheme.textDim,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      items[i].value,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: items[i].color ?? HovuzTheme.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1)
              const Divider(height: 1, color: HovuzTheme.borderSoft),
          ],
        ],
      ),
    );
  }

  Widget _exchangeChip(String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: HovuzTheme.goldGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33B57E00),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          color: HovuzTheme.textDim,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.8,
        ),
      );
}

class _Mini {
  final String label;
  final String value;
  final Color? color;
  const _Mini(this.label, this.value, {this.color});
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.symbol,
    required this.color,
    required this.icon,
    this.gradient,
    this.numericValue,
  });

  final String label;
  final String value;
  final String symbol;
  final Color color;
  final IconData icon;
  final LinearGradient? gradient;

  /// Raw numeric value — used for USD conversion when known.
  final double? numericValue;

  @override
  Widget build(BuildContext context) {
    final isHero = gradient != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isHero ? gradient : null,
        color: isHero ? null : HovuzTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: isHero ? null : Border.all(color: HovuzTheme.border),
        boxShadow: isHero
            ? [
                BoxShadow(
                  color: color.withOpacity(0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : HovuzTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isHero ? Colors.white : color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isHero
                      ? Colors.white.withOpacity(0.92)
                      : HovuzTheme.textDim,
                  fontSize: 12,
                  fontWeight: isHero ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isHero ? Colors.white : color,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (symbol.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  symbol,
                  style: TextStyle(
                    color: isHero
                        ? Colors.white.withOpacity(0.85)
                        : HovuzTheme.textDim,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          if (numericValue != null && symbol.isNotEmpty) _UsdHint(
            symbol: symbol,
            amount: numericValue!,
            inverse: isHero,
          ),
        ],
      ),
    );
  }
}

class _UsdHint extends StatelessWidget {
  const _UsdHint({
    required this.symbol,
    required this.amount,
    required this.inverse,
  });
  final String symbol;
  final double amount;
  final bool inverse;
  @override
  Widget build(BuildContext context) {
    final price = PriceScope.of(context).cachedPrice(symbol);
    if (price == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '≈ ${fmtUsd(amount * price)}',
        style: TextStyle(
          color: inverse
              ? Colors.white.withOpacity(0.85)
              : HovuzTheme.green,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ChainBadge extends StatelessWidget {
  const _ChainBadge({
    required this.symbol,
    required this.label,
    required this.network,
  });
  final String symbol;
  final String label;
  final String network;

  @override
  Widget build(BuildContext context) {
    final c = HovuzTheme.chainColor(symbol);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: HovuzTheme.chainGradient(symbol),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: c.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                symbol.substring(0, symbol.length.clamp(0, 3)),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: c,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                network,
                style: const TextStyle(
                  color: HovuzTheme.textDim,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChainsLegend extends StatelessWidget {
  const _ChainsLegend({required this.supportedHeading, required this.s});
  final String supportedHeading;
  final S s;

  @override
  Widget build(BuildContext context) {
    final codes = ['BTC', 'ETH', 'TRX', 'BNB'];
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
          Text(
            supportedHeading,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: HovuzTheme.text,
            ),
          ),
          const SizedBox(height: 10),
          for (final code in codes) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: HovuzTheme.chainGradient(code),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        code.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    s.chainLong(code),
                    style: const TextStyle(
                      color: HovuzTheme.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
