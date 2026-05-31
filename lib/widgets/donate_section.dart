import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../theme.dart';
import 'coin_logo.dart';

/// "Support the developer" panel — shows USDT TRC20 + BTC donation
/// addresses with brand logos, copy buttons, and minimum amounts.
class DonateSection extends StatelessWidget {
  const DonateSection({super.key});

  static const _addrUsdtTrc20 = 'TH3NqBukfpJ2CQuEfpsTjd2uUCq6gssBq8';
  static const _minUsdt = '10';

  static const _addrBtc = 'bc1qthlc34ne0qwgm2p9p0q99c7pq9takvl89ykelj';
  static const _minBtc = '0.0002';

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HovuzTheme.surface,
        border: Border.all(color: HovuzTheme.border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: HovuzTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(label: s.donateTitle),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: HovuzTheme.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: HovuzTheme.red, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  s.donateDescription,
                  style: const TextStyle(
                    color: HovuzTheme.text,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DonateAddress(
            symbol: 'USDT',
            chainCode: 'TRX',
            networkLabel: s.donateNetworkUsdtTrc20,
            address: _addrUsdtTrc20,
            minAmount: _minUsdt,
            minLabel: s.donateMin('$_minUsdt USDT (TRC20)'),
            warningLabel: s.donateWarningUsdt,
          ),
          const SizedBox(height: 14),
          _DonateAddress(
            symbol: 'BTC',
            chainCode: 'BTC',
            networkLabel: s.donateNetworkBtc,
            address: _addrBtc,
            minAmount: _minBtc,
            minLabel: s.donateMin('$_minBtc BTC'),
            warningLabel: s.donateWarningBtc,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HovuzTheme.gold.withOpacity(0.08),
              border: Border.all(color: HovuzTheme.gold.withOpacity(0.30)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: HovuzTheme.goldDark, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.donateThanks,
                    style: const TextStyle(
                      color: HovuzTheme.goldDark,
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
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

class _Header extends StatelessWidget {
  const _Header({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            gradient: HovuzTheme.goldGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: HovuzTheme.text,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

class _DonateAddress extends StatelessWidget {
  const _DonateAddress({
    required this.symbol,
    required this.chainCode,
    required this.networkLabel,
    required this.address,
    required this.minAmount,
    required this.minLabel,
    required this.warningLabel,
  });

  final String symbol;
  final String chainCode;
  final String networkLabel;
  final String address;
  final String minAmount;
  final String minLabel;
  final String warningLabel;

  @override
  Widget build(BuildContext context) {
    final color = HovuzTheme.chainColor(symbol);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HovuzTheme.surface2,
        border: Border.all(color: color.withOpacity(0.30), width: 1.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CoinLogo(symbol: symbol, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          symbol,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            networkLabel,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      minLabel,
                      style: const TextStyle(
                        color: HovuzTheme.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _CopyButton(text: address, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: HovuzTheme.surface,
              border: Border.all(color: HovuzTheme.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    address,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      color: HovuzTheme.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: HovuzTheme.red, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  warningLabel,
                  style: const TextStyle(
                    color: HovuzTheme.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _doCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.color.withOpacity(_copied ? 0.20 : 0.10),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _doCopy,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            _copied ? Icons.check_rounded : Icons.copy_rounded,
            color: widget.color,
            size: 18,
          ),
        ),
      ),
    );
  }
}
