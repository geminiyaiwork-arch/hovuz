import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'l10n/strings.dart';
import 'pages/home_page.dart';
import 'services/notes_service.dart';
import 'services/price_service.dart';
import 'services/recent_service.dart';
import 'services/theme_controller.dart';
import 'services/watchlist_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final locale = await LocaleController.load();
  final theme = await ThemeController.load();
  final watchlist = await WatchlistService.load();
  final notes = await NotesService.load();
  final recent = await RecentService.load();
  final priceService = PriceService();
  unawaited(priceService.warmup());

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const opts = WindowOptions(
      size: Size(1320, 820),
      minimumSize: Size(900, 600),
      center: true,
      title: 'Hovuz — Crypto Inspector',
      backgroundColor: HovuzTheme.bg,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(opts, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
    });
  }
  runApp(HovuzApp(
    localeController: locale,
    themeController: theme,
    watchlist: watchlist,
    notes: notes,
    recent: recent,
    priceService: priceService,
  ));
}

class HovuzApp extends StatelessWidget {
  const HovuzApp({
    super.key,
    required this.localeController,
    required this.themeController,
    required this.watchlist,
    required this.notes,
    required this.recent,
    required this.priceService,
  });

  final LocaleController localeController;
  final ThemeController themeController;
  final WatchlistService watchlist;
  final NotesService notes;
  final RecentService recent;
  final PriceService priceService;

  @override
  Widget build(BuildContext context) {
    return PriceScope(
      service: priceService,
      child: NotesScope(
        service: notes,
        child: ThemeScope(
          controller: themeController,
          child: LocaleScope(
            controller: localeController,
            child: AnimatedBuilder(
              animation: Listenable.merge(
                  [localeController, themeController]),
              builder: (context, _) {
                ThemeMode mode;
                switch (themeController.mode) {
                  case AppThemeMode.light:
                    mode = ThemeMode.light;
                    break;
                  case AppThemeMode.dark:
                    mode = ThemeMode.dark;
                    break;
                  case AppThemeMode.system:
                    mode = ThemeMode.system;
                    break;
                }
                return MaterialApp(
                  title: 'Hovuz',
                  debugShowCheckedModeBanner: false,
                  theme: HovuzTheme.build(),
                  darkTheme: HovuzTheme.buildDark(),
                  themeMode: mode,
                  home: HomePage(
                      watchlist: watchlist,
                      notes: notes,
                      recent: recent),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope missing');
    return scope!.notifier!;
  }
}

class NotesScope extends InheritedNotifier<NotesService> {
  const NotesScope({
    super.key,
    required NotesService service,
    required super.child,
  }) : super(notifier: service);

  static NotesService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<NotesScope>();
    assert(scope != null, 'NotesScope missing in widget tree');
    return scope!.notifier!;
  }
}

/// Inherited price service — any widget can read prices via PriceScope.of(context).
class PriceScope extends InheritedNotifier<PriceService> {
  const PriceScope({
    super.key,
    required PriceService service,
    required super.child,
  }) : super(notifier: service);

  static PriceService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PriceScope>();
    assert(scope != null, 'PriceScope missing in widget tree');
    return scope!.notifier!;
  }
}
