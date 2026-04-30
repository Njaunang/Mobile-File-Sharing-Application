import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:local_sharer/core/theme/app_theme.dart';
import 'package:local_sharer/features/home/logic/home_provider.dart';
import 'package:local_sharer/features/explorer/logic/explorer_provider.dart';
import 'package:local_sharer/features/home/logic/transfer_provider.dart';
import 'package:local_sharer/features/home/logic/web_provider.dart';
import 'package:local_sharer/features/history/logic/history_provider.dart';
import 'package:local_sharer/features/security/logic/security_provider.dart';
import 'package:local_sharer/features/security/pages/lock_screen.dart';
import 'package:local_sharer/features/home/pages/dashboard_page.dart';
import 'package:local_sharer/l10n/app_localizations.dart';
import 'package:local_sharer/providers/locale_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ExplorerProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => WebProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
        ChangeNotifierProxyProvider<HistoryProvider, TransferProvider>(
          create: (_) => TransferProvider(),
          update: (_, history, transfer) =>
              transfer!..updateHistoryProvider(history),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LocaleProvider())],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Local Sharer',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: localeProvider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en'), // English
              Locale('fr'), // French
            ],
            home: Consumer<SecurityProvider>(
              builder: (context, securityProvider, child) {
                if (securityProvider.isLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (securityProvider.isLocked) {
                  return const LockScreen();
                }
                return const DashboardPage();
              },
            ),
          );
        },
      ),
    );
  }
}
