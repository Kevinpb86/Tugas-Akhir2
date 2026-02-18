import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'beranda.dart';
import 'utils/localization.dart';

void main() {
  runApp(const MyApp());
}

final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('id'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'Amanin - Earthquake Monitoring',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00BCD4)),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          locale: locale,
          supportedLocales: const [
            Locale('id'),
            Locale('en'),
          ],
          localizationsDelegates: [
            const LocalizationDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const BerandaPage(),
        );
      },
    );
  }
}
