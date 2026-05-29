import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/transfer.dart';
import '../theme.dart';
import '../utils/format.dart';

/// Simple radial fund-flow diagram for an address:
///  - Center node = the inspected address
///  - Inflow nodes (left) — biggest senders
///  - Outflow nodes (right) — biggest recipients
///  - Curved Sankey-like ribbons whose thickness encodes the amount
class FlowDiagram extends StatelessWidget {
  const FlowDiagram({
    super.key,
    required this.address,
    required this.transfers,
    required this.onAddressTap,
  });

  final String address;
  final List<Transfer> transfers;
  final void Function(String) onAddressTap;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    // Aggregate amount per counterparty.
    final inflow = <String, _Node>{};
    final outflow = <String, _Node>{};
    for (final t in transfers) {
      final dir = t.directionFor(address);
      if (dir == TransferDirection.received) {
        inflow.update(
          t.from,
          (n) => _Node(n.address, n.amount + t.amount, n.label, n.symbol),
          ifAbsent: () => _Node(t.from, t.amount, t.fromLabel, t.symbol),
        );
      } else if (dir == TransferDirection.sent) {
        outflow.update(
          t.to,
          (n) => _Node(n.address, n.amount + t.amount, n.label, n.symbol),
          ifAbsent: () => _Node(t.to, t.amount, t.toLabel, t.symbol),
        );
      }
    }

    final inflowSorted = inflow.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final outflowSorted = outflow.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final leftNodes = inflowSorted.take(5).toList();
    final rightNodes = outflowSorted.take(5).toList();

    if (leftNodes.isEmpty && rightNodes.isEmpty) {
      return const SizedBox.shrink();
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
                child: const Icon(Icons.account_tree_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 10),
              Text(s.flowDiagramTitle,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: HovuzTheme.text)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 320,
            child: LayoutBuilder(
              builder: (ctx, c) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _FlowPainter(
                          left: leftNodes,
                          right: rightNodes,
                        ),
                      ),
                    ),
                    // Left nodes (inflow)
                    for (var i = 0; i < leftNodes.length; i++)
                      Positioned(
                        left: 8,
                        top: _yFor(i, leftNodes.length, c.maxHeight) - 18,
                        width: c.maxWidth * 0.35,
                        child: _NodeChip(
                          node: leftNodes[i],
                          align: TextAlign.left,
                          onTap: () => onAddressTap(leftNodes[i].address),
                        ),
                      ),
                    // Center (owner address)
                    Positioned(
                      left: c.maxWidth / 2 - 60,
                      top: c.maxHeight / 2 - 24,
                      width: 120,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
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
                        child: Column(
                          children: [
                            const Icon(Icons.person_pin_circle_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(height: 2),
                            Text(
                              _short(address),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Right nodes (outflow)
                    for (var i = 0; i < rightNodes.length; i++)
                      Positioned(
                        right: 8,
                        top: _yFor(i, rightNodes.length, c.maxHeight) - 18,
                        width: c.maxWidth * 0.35,
                        child: _NodeChip(
                          node: rightNodes[i],
                          align: TextAlign.right,
                          onTap: () =>
                              onAddressTap(rightNodes[i].address),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static double _yFor(int i, int count, double h) {
    if (count == 1) return h / 2;
    final step = (h - 60) / (count - 1);
    return 30 + step * i;
  }

  static String _short(String a) {
    if (a.length < 10) return a;
    return '${a.substring(0, 5)}…${a.substring(a.length - 4)}';
  }
}

class _Node {
  final String address;
  final double amount;
  final String? label;
  final String symbol;
  _Node(this.address, this.amount, this.label, this.symbol);
}

class _NodeChip extends StatelessWidget {
  const _NodeChip(
      {required this.node, required this.align, required this.onTap});
  final _Node node;
  final TextAlign align;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIn = align == TextAlign.left;
    final color =
        isIn ? HovuzTheme.green : HovuzTheme.red;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.30)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: isIn
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Text(
              '${fmtAmount(node.amount, max: 4)} ${node.symbol}',
              style: TextStyle(
                color: color,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              node.label ?? _short(node.address),
              textAlign: align,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: HovuzTheme.text,
                fontWeight: node.label != null
                    ? FontWeight.w700
                    : FontWeight.normal,
                fontFamily:
                    node.label != null ? null : 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _short(String a) {
    if (a.length < 16) return a;
    return '${a.substring(0, 6)}…${a.substring(a.length - 4)}';
  }
}

class _FlowPainter extends CustomPainter {
  final List<_Node> left;
  final List<_Node> right;
  _FlowPainter({required this.left, required this.right});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final centerLeft = Offset(centerX - 50, centerY);
    final centerRight = Offset(centerX + 50, centerY);

    final maxLeftAmount = left.isEmpty
        ? 1.0
        : left.map((n) => n.amount).reduce((a, b) => a > b ? a : b);
    final maxRightAmount = right.isEmpty
        ? 1.0
        : right.map((n) => n.amount).reduce((a, b) => a > b ? a : b);

    // Inflow ribbons (green)
    for (var i = 0; i < left.length; i++) {
      final y = _yFor(i, left.length, size.height);
      final start = Offset(size.width * 0.36, y);
      final width = 4 + (left[i].amount / maxLeftAmount) * 18;
      final paint = Paint()
        ..color = HovuzTheme.green.withOpacity(0.35)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          (start.dx + centerLeft.dx) / 2,
          start.dy,
          (start.dx + centerLeft.dx) / 2,
          centerLeft.dy,
          centerLeft.dx,
          centerLeft.dy,
        );
      canvas.drawPath(path, paint);
    }
    // Outflow ribbons (red)
    for (var i = 0; i < right.length; i++) {
      final y = _yFor(i, right.length, size.height);
      final end = Offset(size.width * 0.64, y);
      final width = 4 + (right[i].amount / maxRightAmount) * 18;
      final paint = Paint()
        ..color = HovuzTheme.red.withOpacity(0.35)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(centerRight.dx, centerRight.dy)
        ..cubicTo(
          (centerRight.dx + end.dx) / 2,
          centerRight.dy,
          (centerRight.dx + end.dx) / 2,
          end.dy,
          end.dx,
          end.dy,
        );
      canvas.drawPath(path, paint);
    }
  }

  static double _yFor(int i, int count, double h) {
    if (count == 1) return h / 2;
    final step = (h - 60) / (count - 1);
    return 30 + step * i;
  }

  @override
  bool shouldRepaint(covariant _FlowPainter old) =>
      old.left != left || old.right != right;
}
