import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../services/watchlist_service.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'coin_logo.dart';

class WatchlistPanel extends StatelessWidget {
  const WatchlistPanel({
    super.key,
    required this.watchlist,
    required this.onOpenAddress,
  });

  final WatchlistService watchlist;
  final void Function(String address) onOpenAddress;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AnimatedBuilder(
      animation: watchlist,
      builder: (context, _) {
        final items = watchlist.all.toList()
          ..sort((a, b) {
            // alerts first, then most recent check
            final aw = a.unseenChange != null ? 1 : 0;
            final bw = b.unseenChange != null ? 1 : 0;
            if (aw != bw) return bw - aw;
            return (b.lastChecked?.millisecondsSinceEpoch ?? 0)
                .compareTo(a.lastChecked?.millisecondsSinceEpoch ?? 0);
          });
        return Container(
          decoration: const BoxDecoration(
            color: HovuzTheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HovuzTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: HovuzTheme.brandGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    s.watchlistTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${watchlist.length}',
                    style: const TextStyle(
                        color: HovuzTheme.brand,
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: HovuzTheme.border, height: 1),
              const SizedBox(height: 8),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      s.watchlistEmpty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: HovuzTheme.textDim, fontSize: 13),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(
                        color: HovuzTheme.borderSoft, height: 1),
                    itemBuilder: (_, i) => _Row(
                      item: items[i],
                      onOpen: () => onOpenAddress(items[i].address),
                      onRemove: () => watchlist.remove(
                          items[i].address, items[i].chain),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.item,
    required this.onOpen,
    required this.onRemove,
  });

  final WatchedAddress item;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final sym = item.chain.nativeSymbol;
    final delta = item.unseenChange?.delta;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            CoinLogo(symbol: sym, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.chain.label,
                        style: TextStyle(
                          color: HovuzTheme.chainColor(sym),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      if (item.unseenChange != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: HovuzTheme.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.address,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: HovuzTheme.text),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        item.lastBalance != null
                            ? '${fmtAmount(item.lastBalance!)} $sym'
                            : '—',
                        style: const TextStyle(
                          color: HovuzTheme.textDim,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (delta != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(8)}',
                          style: TextStyle(
                            color: delta >= 0
                                ? HovuzTheme.green
                                : HovuzTheme.red,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'copy',
              iconSize: 16,
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: item.address)),
              icon: const Icon(Icons.copy_rounded,
                  color: HovuzTheme.textDim),
            ),
            IconButton(
              tooltip: 'remove',
              iconSize: 16,
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: HovuzTheme.red),
            ),
          ],
        ),
      ),
    );
  }
}
