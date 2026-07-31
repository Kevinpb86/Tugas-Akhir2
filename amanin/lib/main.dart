import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_screen.dart';
import 'utils/localization.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('id'));
final ValueNotifier<bool> isLoggedInNotifier = ValueNotifier(false);
final ValueNotifier<String> userNameNotifier = ValueNotifier('');
final ValueNotifier<String> userEmailNotifier = ValueNotifier('');
final ValueNotifier<String> userPhotoUrlNotifier = ValueNotifier('');
final ValueNotifier<String> userCityNameNotifier = ValueNotifier('Tambun Selatan');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
          title: 'Riksa - Earthquake Monitoring',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00BCD4),
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
                .apply(
                  bodyColor: const Color(0xFF1A1A1A),
                  displayColor: const Color(0xFF1A1A1A),
                ),
          ),
          locale: locale,
          supportedLocales: const [Locale('id'), Locale('en')],
          localizationsDelegates: [
            const LocalizationDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MainScreen(),
        );
      },
    );
  }
}
