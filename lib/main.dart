import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_visitor_app/splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/core.dart';
import 'routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Visitor App',
      theme: ThemeData(
        primaryColor: AppColors.primary500,
        scaffoldBackgroundColor: const Color(0xffFAFCFF),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: AppColors.grey900,
            displayColor: AppColors.grey900,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromRGBO(249, 250, 251, 1),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary500, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en', ''), Locale('id', '')],
      // initialRoute: _initialRoute,
      // routes: Routes.getAll(),
      home: const Splashscreen(),
    );
  }
}

class NavigationService {
  static const String _lastRouteKey = 'last_route';

  static Future<void> saveLastRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRouteKey, route);
  }

  static Future<String?> getLastRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastRouteKey);
  }
}
