import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../main.dart';
import '../models/chain.dart';
import '../theme.dart';

/// Inline note editor — appears below the address details. Expands on click.
class NoteCard extends StatefulWidget {
  const NoteCard({
    super.key,
    required this.address,
    required this.chain,
  });

  final String address;
  final Chain chain;

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  late TextEditingController _controller;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final svc = NotesScope.of(context);
    final n = svc.get(widget.address, widget.chain);
    _controller = TextEditingController(text: n?.text ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final svc = NotesScope.of(context);
    return AnimatedBuilder(
      animation: svc,
      builder: (context, _) {
        final note = svc.get(widget.address, widget.chain);
        final hasNote = note != null && note.text.isNotEmpty;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HovuzTheme.surface,
            border: Border.all(
              color: hasNote
                  ? HovuzTheme.gold.withOpacity(0.5)
                  : HovuzTheme.border,
            ),
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
                      gradient: HovuzTheme.goldGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sticky_note_2_rounded,
                        color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    s.noteTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: HovuzTheme.text,
                    ),
                  ),
                  const Spacer(),
                  if (!_editing)
                    Tooltip(
                      message:
                          hasNote ? s.noteEditTooltip : s.noteAddTooltip,
                      child: Material(
                        color: HovuzTheme.brand.withOpacity(0.10),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            setState(() {
                              _editing = true;
                              _controller.text = note?.text ?? '';
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(7),
                            child: Icon(Icons.edit_rounded,
                                color: HovuzTheme.brand, size: 14),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (_editing) ...[
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 2,
                  autofocus: true,
                  decoration: InputDecoration(hintText: s.noteHint),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (hasNote)
                      TextButton.icon(
                        onPressed: () async {
                          await svc.remove(widget.address, widget.chain);
                          setState(() {
                            _editing = false;
                            _controller.clear();
                          });
                        },
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 16),
                        label: Text(s.noteRemove),
                        style: TextButton.styleFrom(
                          foregroundColor: HovuzTheme.red,
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          setState(() => _editing = false),
                      child: Text(_controller.text == (note?.text ?? '')
                          ? 'Cancel'
                          : 'Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () async {
                        await svc.set(widget.address, widget.chain,
                            _controller.text);
                        setState(() => _editing = false);
                      },
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: Text(s.noteSave),
                      style: FilledButton.styleFrom(
                        backgroundColor: HovuzTheme.brand,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ] else
                Text(
                  hasNote ? note.text : s.noteEmpty,
                  style: TextStyle(
                    color: hasNote
                        ? HovuzTheme.text
                        : HovuzTheme.textDim,
                    fontSize: 13,
                    height: 1.5,
                    fontStyle:
                        hasNote ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Compact preview chip — used inline next to an address (e.g. in lists).
class NotePreviewChip extends StatelessWidget {
  const NotePreviewChip({
    super.key,
    required this.address,
    required this.chain,
  });

  final String address;
  final Chain chain;

  @override
  Widget build(BuildContext context) {
    final svc = NotesScope.of(context);
    final n = svc.get(address, chain);
    if (n == null || n.text.isEmpty) return const SizedBox.shrink();
    final short = n.text.length > 24
        ? '${n.text.substring(0, 24)}…'
        : n.text;
    return Tooltip(
      message: n.text,
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: HovuzTheme.gold.withOpacity(0.15),
          border: Border.all(color: HovuzTheme.gold.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sticky_note_2_rounded,
                size: 11, color: HovuzTheme.goldDark),
            const SizedBox(width: 4),
            Text(
              short,
              style: const TextStyle(
                color: HovuzTheme.goldDark,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
