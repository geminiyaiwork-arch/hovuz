import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/donate_section.dart';

/// AUTHOR / DASTUR HAQIDA sahifasi.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // ============================================================
  // AFTOR ma'lumotlari — Qodirov Elyorbek
  // ============================================================
  static const String kAuthorName = 'Qodirov Elyorbek';

  static const Map<AppLocale, String> kAuthorTitle = {
    AppLocale.uz: 'Developer · VISIO EYE',
    AppLocale.en: 'Developer · VISIO EYE',
    AppLocale.ru: 'Разработчик · VISIO EYE',
  };

  static const Map<AppLocale, String> kAuthorBio = {
    AppLocale.uz:
        'VISIO EYE jamoasida dasturchi. Kripto-tahlil, blokcheyn '
        'kuzatuvi va birja oqimlarini vizualizatsiya qilish bo\'yicha '
        'desktop yechimlar ustida ishlaydi.',
    AppLocale.en:
        'Developer at VISIO EYE. Builds desktop tooling for crypto '
        'analytics, on-chain tracing, and exchange-flow visualization '
        'across Bitcoin, Ethereum, TRON, BNB and Solana.',
    AppLocale.ru:
        'Разработчик в команде VISIO EYE. Создаёт настольные '
        'инструменты для крипто-аналитики, ончейн-расследований и '
        'визуализации потоков средств между биржами.',
  };

  static const List<_Contact> kAuthorContacts = [
    _Contact(
      icon: Icons.phone_rounded,
      kind: _ContactKind.phone1,
      value: '+998 (91) 169-37-66',
      url: 'tel:+998911693766',
    ),
    _Contact(
      icon: Icons.phone_rounded,
      kind: _ContactKind.phone2,
      value: '+998 (99) 433-37-66',
      url: 'tel:+998994333766',
    ),
    _Contact(
      icon: Icons.send_rounded,
      kind: _ContactKind.telegram,
      value: '@voo_uz',
      url: 'https://t.me/voo_uz',
    ),
    _Contact(
      icon: Icons.mail_outline_rounded,
      kind: _ContactKind.email,
      value: 'elyorbek-13@mail.ru',
      url: 'mailto:elyorbek-13@mail.ru',
    ),
  ];

  static const String kAuthorAvatarAsset = 'images/avatar.jpg';
  static const String kAppVersion = '3.2.3';
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final loc = LocaleScope.of(context).locale;
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
              s.aboutPageTitle,
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
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(36),
              children: [
                _appCard(s),
                const SizedBox(height: 22),
                _authorCard(s, loc),
                const SizedBox(height: 22),
                _contactsCard(s),
                const SizedBox(height: 22),
                const DonateSection(),
                const SizedBox(height: 22),
                _legalCard(s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appCard(S s) {
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
          Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: HovuzTheme.border),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'images/logo.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.appName,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: HovuzTheme.brand)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: HovuzTheme.brand.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${s.versionPrefix}$kAppVersion',
                      style: const TextStyle(
                        color: HovuzTheme.brandDeep,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            s.appLongDescription,
            style: const TextStyle(color: HovuzTheme.text, height: 1.65),
          ),
        ],
      ),
    );
  }

  Widget _authorCard(S s, AppLocale loc) {
    final title = kAuthorTitle[loc] ?? kAuthorTitle[AppLocale.en]!;
    final bio = kAuthorBio[loc] ?? kAuthorBio[AppLocale.en]!;
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
          _SectionLabel(text: s.sectionAuthor),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: HovuzTheme.brandGradient,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44154AAB),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                width: 124,
                height: 124,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: Image.asset(
                    kAuthorAvatarAsset,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              kAuthorName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: HovuzTheme.text,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: HovuzTheme.brand,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            bio,
            style: const TextStyle(
                color: HovuzTheme.text, height: 1.7, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _contactsCard(S s) {
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
          _SectionLabel(text: s.sectionContact),
          const SizedBox(height: 12),
          ...kAuthorContacts.map((c) => _contactRow(c, s)),
        ],
      ),
    );
  }

  Widget _contactRow(_Contact c, S s) {
    final label = switch (c.kind) {
      _ContactKind.email => s.emailLabel,
      _ContactKind.telegram => s.telegramLabel,
      _ContactKind.phone1 => s.phone1Label,
      _ContactKind.phone2 => s.phone2Label,
    };
    return InkWell(
      onTap: () => launchUrl(Uri.parse(c.url)),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: HovuzTheme.brand.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(c.icon, color: HovuzTheme.brand, size: 18),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 110,
              child: Text(
                label.toUpperCase(),
                style: const TextStyle(
                    color: HovuzTheme.textDim,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2),
              ),
            ),
            Expanded(
              child: Text(
                c.value,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: HovuzTheme.text,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.open_in_new_rounded,
                size: 14, color: HovuzTheme.textDim),
          ],
        ),
      ),
    );
  }

  Widget _legalCard(S s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HovuzTheme.surface2,
        border: Border.all(color: HovuzTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: HovuzTheme.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              s.disclaimer,
              style: const TextStyle(
                color: HovuzTheme.textDim,
                height: 1.6,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              gradient: HovuzTheme.brandGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
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

enum _ContactKind { phone1, phone2, telegram, email }

class _Contact {
  final IconData icon;
  final _ContactKind kind;
  final String value;
  final String url;
  const _Contact({
    required this.icon,
    required this.kind,
    required this.value,
    required this.url,
  });
}
