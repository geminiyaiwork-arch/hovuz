import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../main.dart';
import '../models/chain.dart';
import '../services/portfolio_service.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'coin_logo.dart';

class PortfolioCard extends StatefulWidget {
  const PortfolioCard({
    super.key,
    required this.address,
    required this.chain,
  });
  final String address;
  final Chain chain;

  @override
  State<PortfolioCard> createState() => _PortfolioCardState();
}

class _PortfolioCardState extends State<PortfolioCard> {
  final _service = PortfolioService();
  List<PortfolioToken>? _tokens;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    final t = await _service.fetch(widget.address, widget.chain);
    if (!mounted) return;
    setState(() {
      _tokens = t;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    if (_tokens == null || _tokens!.isEmpty) {
      return const SizedBox.shrink();
    }

    double totalUsd = 0;
    final priceSvc = PriceScope.of(context);
    for (final t in _tokens!) {
      final p = priceSvc.cachedPrice(t.symbol);
      if (p != null) totalUsd += t.balance * p;
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
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: HovuzTheme.brandGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pie_chart_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 10),
              Text(s.portfolioTitle,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: HovuzTheme.text)),
              const Spacer(),
              if (totalUsd > 0)
                Text(
                  '≈ ${fmtUsd(totalUsd)}',
                  style: const TextStyle(
                      color: HovuzTheme.green,
                      fontWeight: FontWeight.w800,
                      fontSize: 13),
                ),
              if (_busy)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final t in _tokens!.take(10))
            _TokenRow(token: t),
        ],
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  const _TokenRow({required this.token});
  final PortfolioToken token;
  @override
  Widget build(BuildContext context) {
    final price = PriceScope.of(context).cachedPrice(token.symbol);
    final usd = price != null ? token.balance * price : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CoinLogo(symbol: token.symbol, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(token.symbol,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    )),
                Text(token.name,
                    style: const TextStyle(
                        color: HovuzTheme.textDim, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtAmount(token.balance, max: 4),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              if (usd != null)
                Text(
                  fmtUsd(usd),
                  style: const TextStyle(
                    color: HovuzTheme.green,
                    fontWeight: FontWeight.w700,
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
