import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../main.dart';
import '../models/chain.dart';
import '../services/theme_controller.dart';
import '../services/watchlist_service.dart';
import '../theme.dart';
import 'language_selector.dart';

class SearchHeader extends StatefulWidget {
  const SearchHeader({
    super.key,
    required this.onSearch,
    required this.onAboutPressed,
    required this.onSettingsPressed,
    required this.onWatchlistPressed,
    required this.busy,
    required this.canBack,
    required this.canForward,
    required this.onBack,
    required this.onForward,
    required this.watchlist,
    this.searchFocusNode,
  });

  final Future<void> Function(String query, Chain? hint) onSearch;
  final VoidCallback onAboutPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onWatchlistPressed;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final bool busy;
  final bool canBack;
  final bool canForward;
  final WatchlistService watchlist;
  final FocusNode? searchFocusNode;

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  final _controller = TextEditingController();
  Chain? _hint;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final q = _controller.text.trim();
    if (q.isEmpty || widget.busy) return;
    widget.onSearch(q, _hint);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        gradient: HovuzTheme.headerGradient,
        border: Border(bottom: BorderSide(color: HovuzTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HovuzTheme.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A154AAB),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'images/logo.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.appName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: HovuzTheme.brand,
                ),
              ),
              Text(
                s.appTagline,
                style: const TextStyle(
                  fontSize: 11,
                  color: HovuzTheme.textDim,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          _NavArrow(
            icon: Icons.arrow_back_rounded,
            tooltip: s.backTooltip,
            enabled: widget.canBack,
            onTap: widget.onBack,
          ),
          const SizedBox(width: 6),
          _NavArrow(
            icon: Icons.arrow_forward_rounded,
            tooltip: s.forwardTooltip,
            enabled: widget.canForward,
            onTap: widget.onForward,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: TextField(
                controller: _controller,
                focusNode: widget.searchFocusNode,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: s.searchHint,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 6, right: 4),
                    child: Icon(Icons.search,
                        color: HovuzTheme.brand, size: 22),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ChainHintButton(
                        selected: _hint,
                        onChanged: (c) => setState(() => _hint = c),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: HovuzTheme.border,
                      ),
                      IconButton(
                        tooltip: s.pasteTooltip,
                        icon: const Icon(Icons.content_paste_rounded,
                            size: 18, color: HovuzTheme.textDim),
                        onPressed: () async {
                          final d = await Clipboard.getData('text/plain');
                          if (d?.text != null) {
                            _controller.text = d!.text!.trim();
                            _submit();
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: HovuzTheme.brandGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44154AAB),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.busy ? null : _submit,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 14),
                  child: Row(
                    children: [
                      widget.busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.travel_explore,
                              color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        s.checkButton,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _WatchlistHeaderButton(
            watchlist: widget.watchlist,
            onPressed: widget.onWatchlistPressed,
            tooltip: s.watchlistTooltip,
          ),
          const SizedBox(width: 6),
          _ThemeToggleButton(tooltip: s.themeTooltip),
          const SizedBox(width: 6),
          const LanguageSelector(),
          const SizedBox(width: 6),
          IconButton(
            tooltip: s.settingsTooltip,
            onPressed: widget.onSettingsPressed,
            icon: const Icon(Icons.settings_rounded,
                color: HovuzTheme.textDim),
          ),
          IconButton(
            tooltip: s.aboutTooltip,
            onPressed: widget.onAboutPressed,
            icon: const Icon(Icons.info_outline_rounded,
                color: HovuzTheme.textDim),
          ),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? HovuzTheme.brand : HovuzTheme.textDim;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled
            ? HovuzTheme.brand.withOpacity(0.10)
            : HovuzTheme.surface2,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.tooltip});
  final String tooltip;
  @override
  Widget build(BuildContext context) {
    final ctrl = ThemeScope.of(context);
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        IconData icon;
        switch (ctrl.mode) {
          case AppThemeMode.light:
            icon = Icons.light_mode_rounded;
            break;
          case AppThemeMode.dark:
            icon = Icons.dark_mode_rounded;
            break;
          case AppThemeMode.system:
            icon = Icons.brightness_auto_rounded;
            break;
        }
        return Tooltip(
          message: tooltip,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => ctrl.cycle(),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Icon(icon, color: HovuzTheme.brand, size: 22),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WatchlistHeaderButton extends StatelessWidget {
  const _WatchlistHeaderButton({
    required this.watchlist,
    required this.onPressed,
    required this.tooltip,
  });

  final WatchlistService watchlist;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: watchlist,
      builder: (context, _) {
        final count = watchlist.length;
        final hasAlert =
            watchlist.all.any((w) => w.unseenChange != null);
        return Tooltip(
          message: tooltip,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      hasAlert
                          ? Icons.notifications_active_rounded
                          : Icons.favorite_rounded,
                      color: hasAlert
                          ? HovuzTheme.amber
                          : (count > 0
                              ? HovuzTheme.red
                              : HovuzTheme.textDim),
                      size: 22,
                    ),
                    if (count > 0)
                      Positioned(
                        right: -8,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: HovuzTheme.brand,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(minWidth: 18),
                          child: Text(
                            '$count',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChainHintButton extends StatelessWidget {
  const _ChainHintButton({required this.selected, required this.onChanged});

  final Chain? selected;
  final ValueChanged<Chain?> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final color = selected == null
        ? HovuzTheme.textDim
        : HovuzTheme.chainColor(selected!.nativeSymbol);
    return PopupMenuButton<Chain?>(
      tooltip: s.forceNetwork,
      onSelected: onChanged,
      itemBuilder: (_) => [
        PopupMenuItem(value: null, child: Text(s.autoDetect)),
        ...Chain.values.map(
          (c) => PopupMenuItem(
            value: c,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: HovuzTheme.chainColor(c.nativeSymbol),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(c.label),
              ],
            ),
          ),
        ),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              selected?.nativeSymbol ?? s.autoBadge,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            Icon(Icons.expand_more, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
