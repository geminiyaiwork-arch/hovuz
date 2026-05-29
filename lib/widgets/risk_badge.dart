import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/transfer.dart';
import '../services/risk_score.dart';
import '../theme.dart';

class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.address});
  final AddressSummary address;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final r = RiskAssessor.assess(address);
    final color = _color(r.level);
    final label = _label(r.level, s);

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
              const Icon(Icons.shield_rounded,
                  color: HovuzTheme.brand, size: 18),
              const SizedBox(width: 8),
              Text(
                s.riskScoreTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Score bar
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${r.score}',
                style: TextStyle(
                  color: color,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 4),
              const Text('/100',
                  style: TextStyle(
                      color: HovuzTheme.textDim, fontSize: 13)),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: HovuzTheme.surface2,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (r.score / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.6), color],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (r.factors.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: HovuzTheme.borderSoft),
            const SizedBox(height: 10),
            for (final f in r.factors)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      f.isPositive
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      size: 14,
                      color:
                          f.isPositive ? HovuzTheme.green : HovuzTheme.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.translateRiskFactor(f.displayKey),
                        style: const TextStyle(
                            color: HovuzTheme.text, fontSize: 12),
                      ),
                    ),
                    Text(
                      '${f.isPositive ? '-' : '+'}${f.weight}',
                      style: TextStyle(
                        color: f.isPositive
                            ? HovuzTheme.green
                            : HovuzTheme.red,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        fontFamily: 'monospace',
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

  Color _color(RiskLevel l) {
    switch (l) {
      case RiskLevel.veryLow:
        return HovuzTheme.green;
      case RiskLevel.low:
        return const Color(0xFF7BB341);
      case RiskLevel.medium:
        return HovuzTheme.amber;
      case RiskLevel.high:
        return const Color(0xFFE6750E);
      case RiskLevel.critical:
        return HovuzTheme.red;
    }
  }

  String _label(RiskLevel l, S s) {
    switch (l) {
      case RiskLevel.veryLow:
        return s.riskLevelVeryLow;
      case RiskLevel.low:
        return s.riskLevelLow;
      case RiskLevel.medium:
        return s.riskLevelMedium;
      case RiskLevel.high:
        return s.riskLevelHigh;
      case RiskLevel.critical:
        return s.riskLevelCritical;
    }
  }
}
