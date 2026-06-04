import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/strings.dart';
import '../main.dart';
import '../services/api_keys_service.dart';
import '../theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      backgroundColor: HovuzTheme.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            gradient: HovuzTheme.headerGradient,
            border: Border(bottom: BorderSide(color: HovuzTheme.border)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: HovuzTheme.text,
            title: Text(
              s.settingsTitle,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: HovuzTheme.bgGradient),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: const [
                _Intro(),
                SizedBox(height: 22),
                _EtherscanKeyCard(),
                SizedBox(height: 18),
                _TronGridKeyCard(),
                SizedBox(height: 24),
                _Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();
  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: HovuzTheme.headerGradient,
        border: Border.all(color: HovuzTheme.brand.withOpacity(0.20)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: HovuzTheme.brandGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.vpn_key_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.settingsApiKeysHeading,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.settingsApiKeysIntro,
                  style: const TextStyle(
                    color: HovuzTheme.text,
                    fontSize: 13,
                    height: 1.55,
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

class _EtherscanKeyCard extends StatefulWidget {
  const _EtherscanKeyCard();
  @override
  State<_EtherscanKeyCard> createState() => _EtherscanKeyCardState();
}

class _EtherscanKeyCardState extends State<_EtherscanKeyCard> {
  late final TextEditingController _ctrl;
  bool _obscured = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: ApiKeysScope.of(context).rawEtherscan);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ApiKeysScope.of(context).setEtherscan(_ctrl.text);
    setState(() => _saved = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final svc = ApiKeysScope.of(context);
    return AnimatedBuilder(
      animation: svc,
      builder: (_, __) => _KeyCard(
        title: s.settingsEtherscanTitle,
        subtitle: s.settingsEtherscanSubtitle,
        controller: _ctrl,
        obscured: _obscured,
        toggleObscure: () => setState(() => _obscured = !_obscured),
        onSave: _save,
        saved: _saved,
        statusOk: svc.hasEtherscan,
        statusActiveText: s.settingsKeyActive,
        statusInactiveText: s.settingsKeyMissing,
        helpUrl: 'https://etherscan.io/register',
        helpText: s.settingsGetKeyAt('etherscan.io'),
        chains: const ['ETH', 'BSC', 'POL', 'ARB', 'OP', 'BASE'],
      ),
    );
  }
}

class _TronGridKeyCard extends StatefulWidget {
  const _TronGridKeyCard();
  @override
  State<_TronGridKeyCard> createState() => _TronGridKeyCardState();
}

class _TronGridKeyCardState extends State<_TronGridKeyCard> {
  late final TextEditingController _ctrl;
  bool _obscured = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: ApiKeysScope.of(context).rawTronGrid);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ApiKeysScope.of(context).setTronGrid(_ctrl.text);
    setState(() => _saved = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final svc = ApiKeysScope.of(context);
    return AnimatedBuilder(
      animation: svc,
      builder: (_, __) => _KeyCard(
        title: s.settingsTronGridTitle,
        subtitle: s.settingsTronGridSubtitle,
        controller: _ctrl,
        obscured: _obscured,
        toggleObscure: () => setState(() => _obscured = !_obscured),
        onSave: _save,
        saved: _saved,
        statusOk: svc.hasTronGrid,
        statusActiveText: s.settingsKeyActive,
        statusInactiveText: s.settingsKeyOptional,
        helpUrl: 'https://www.trongrid.io/',
        helpText: s.settingsGetKeyAt('trongrid.io'),
        chains: const ['TRX'],
      ),
    );
  }
}

class _KeyCard extends StatelessWidget {
  const _KeyCard({
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.obscured,
    required this.toggleObscure,
    required this.onSave,
    required this.saved,
    required this.statusOk,
    required this.statusActiveText,
    required this.statusInactiveText,
    required this.helpUrl,
    required this.helpText,
    required this.chains,
  });

  final String title;
  final String subtitle;
  final TextEditingController controller;
  final bool obscured;
  final VoidCallback toggleObscure;
  final Future<void> Function() onSave;
  final bool saved;
  final bool statusOk;
  final String statusActiveText;
  final String statusInactiveText;
  final String helpUrl;
  final String helpText;
  final List<String> chains;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HovuzTheme.surface,
        border: Border.all(color: HovuzTheme.border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: HovuzTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusBadge(
                ok: statusOk,
                text: statusOk ? statusActiveText : statusInactiveText,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: HovuzTheme.textDim,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: [
              for (final c in chains)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: HovuzTheme.chainColor(c).withOpacity(0.10),
                    border: Border.all(
                        color: HovuzTheme.chainColor(c).withOpacity(0.30)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      color: HovuzTheme.chainColor(c),
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            obscureText: obscured,
            obscuringCharacter: '•',
            decoration: InputDecoration(
              hintText: s.settingsKeyPlaceholder,
              prefixIcon: const Icon(Icons.key_rounded,
                  color: HovuzTheme.brand, size: 18),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: s.settingsPaste,
                    icon: const Icon(Icons.content_paste_rounded,
                        size: 18, color: HovuzTheme.textDim),
                    onPressed: () async {
                      final d = await Clipboard.getData('text/plain');
                      if (d?.text != null) controller.text = d!.text!.trim();
                    },
                  ),
                  IconButton(
                    tooltip: obscured ? s.settingsShow : s.settingsHide,
                    icon: Icon(
                      obscured
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      size: 18,
                      color: HovuzTheme.textDim,
                    ),
                    onPressed: toggleObscure,
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () =>
                    launchUrl(Uri.parse(helpUrl), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: Text(helpText),
                style: TextButton.styleFrom(
                  foregroundColor: HovuzTheme.brand,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: onSave,
                icon: Icon(
                  saved
                      ? Icons.check_circle_rounded
                      : Icons.save_rounded,
                  size: 16,
                ),
                label: Text(saved ? s.settingsSaved : s.settingsSave),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      saved ? HovuzTheme.green : HovuzTheme.brand,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.ok, required this.text});
  final bool ok;
  final String text;
  @override
  Widget build(BuildContext context) {
    final color = ok ? HovuzTheme.green : HovuzTheme.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HovuzTheme.gold.withOpacity(0.08),
        border: Border.all(color: HovuzTheme.gold.withOpacity(0.30)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_rounded,
              color: HovuzTheme.goldDark, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              s.settingsKeysStorageNote,
              style: const TextStyle(
                color: HovuzTheme.goldDark,
                fontSize: 12,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
