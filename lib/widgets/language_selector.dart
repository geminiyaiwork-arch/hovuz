import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = LocaleScope.of(context);
    final s = ctrl.strings;
    return PopupMenuButton<AppLocale>(
      tooltip: s.languageTooltip,
      onSelected: ctrl.setLocale,
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        for (final loc in AppLocale.values)
          PopupMenuItem(
            value: loc,
            child: Row(
              children: [
                Text(loc.flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Text(
                  loc.label,
                  style: TextStyle(
                    fontWeight: ctrl.locale == loc
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: ctrl.locale == loc
                        ? HovuzTheme.brand
                        : HovuzTheme.text,
                  ),
                ),
                if (ctrl.locale == loc) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.check_rounded,
                      color: HovuzTheme.brand, size: 16),
                ],
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: HovuzTheme.surface,
          border: Border.all(color: HovuzTheme.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ctrl.locale.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              ctrl.locale.code,
              style: const TextStyle(
                color: HovuzTheme.text,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const Icon(Icons.expand_more_rounded,
                size: 16, color: HovuzTheme.textDim),
          ],
        ),
      ),
    );
  }
}
