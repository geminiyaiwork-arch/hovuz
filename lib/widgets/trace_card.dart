import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../models/chain.dart';
import '../services/trace_service.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'coin_logo.dart';

/// Renders a "Trace fund flow" button on an address; when clicked it shows
/// the multi-hop chain inline.
class TraceCard extends StatefulWidget {
  const TraceCard({
    super.key,
    required this.address,
    required this.chain,
    required this.onAddressTap,
  });

  final String address;
  final Chain chain;
  final void Function(String) onAddressTap;

  @override
  State<TraceCard> createState() => _TraceCardState();
}

class _TraceCardState extends State<TraceCard> {
  final _service = TraceService();
  TraceResult? _result;
  bool _busy = false;

  Future<void> _run() async {
    setState(() => _busy = true);
    final r = await _service.trace(widget.address, widget.chain);
    if (!mounted) return;
    setState(() {
      _result = r;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
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
                child: const Icon(Icons.timeline_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 10),
              Text(
                s.traceTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _busy ? null : _run,
                icon: _busy
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.travel_explore, size: 14),
                label:
                    Text(_busy ? s.traceInProgress : s.traceButton),
                style: FilledButton.styleFrom(
                  backgroundColor: HovuzTheme.brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            _TraceList(
              r: _result!,
              s: s,
              onAddressTap: widget.onAddressTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _TraceList extends StatelessWidget {
  const _TraceList({
    required this.r,
    required this.s,
    required this.onAddressTap,
  });
  final TraceResult r;
  final S s;
  final void Function(String) onAddressTap;

  @override
  Widget build(BuildContext context) {
    if (!r.hasResults) {
      return Text(
        s.traceTerminalDeadEnd,
        style: const TextStyle(
            color: HovuzTheme.textDim, fontStyle: FontStyle.italic),
      );
    }

    final terminalText = switch (r.terminalReason) {
      'exchange' => s.traceTerminalExchange,
      'sanctioned' => s.traceTerminalSanctioned,
      'cycle' => s.traceTerminalCycle,
      _ => r.hitTerminal ? s.traceTerminalDeadEnd : s.traceTerminalMaxHops,
    };
    final terminalColor = switch (r.terminalReason) {
      'sanctioned' => HovuzTheme.red,
      'exchange' => HovuzTheme.gold,
      _ => HovuzTheme.textDim,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < r.steps.length; i++) ...[
          _HopRow(
            index: i + 1,
            step: r.steps[i],
            s: s,
            onAddressTap: onAddressTap,
          ),
          if (i < r.steps.length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Container(
                width: 2,
                height: 18,
                color: HovuzTheme.brand.withOpacity(0.3),
              ),
            ),
        ],
        const SizedBox(height: 12),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: terminalColor.withOpacity(0.10),
            border: Border.all(color: terminalColor.withOpacity(0.30)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                r.terminalReason == 'sanctioned'
                    ? Icons.gavel_rounded
                    : r.terminalReason == 'exchange'
                        ? Icons.business_rounded
                        : Icons.flag_circle_rounded,
                size: 14,
                color: terminalColor,
              ),
              const SizedBox(width: 6),
              Text(
                terminalText,
                style: TextStyle(
                  color: terminalColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HopRow extends StatelessWidget {
  const _HopRow({
    required this.index,
    required this.step,
    required this.s,
    required this.onAddressTap,
  });
  final int index;
  final TraceStep step;
  final S s;
  final void Function(String) onAddressTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: HovuzTheme.brandGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CoinLogo(symbol: step.symbol, size: 18, glow: false),
                  const SizedBox(width: 6),
                  Text(
                    '${fmtAmount(step.amount)} ${step.symbol}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  if (step.isMixer) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: HovuzTheme.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s.traceMixerWarning,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                  if (step.isSanctioned) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: HovuzTheme.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '⚠ SANCTIONED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              if (step.toAddress != null)
                InkWell(
                  onTap: () => onAddressTap(step.toAddress!),
                  child: Text(
                    step.toAddress!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: HovuzTheme.brand,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0x55154AAB),
                    ),
                  ),
                ),
              if (step.label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: HovuzTheme.goldGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      step.label!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (step.toAddress != null)
          IconButton(
            iconSize: 14,
            onPressed: () => Clipboard.setData(
                ClipboardData(text: step.toAddress!)),
            icon: const Icon(Icons.copy_rounded,
                color: HovuzTheme.textDim),
          ),
      ],
    );
  }
}
