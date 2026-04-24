import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_visitor_app/splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/auth/controller/user_controller.dart';
import 'presentation/auth/controller/language_controller.dart';
import 'core/localization/app_translations.dart';
import 'core/core.dart';
// import 'routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Open boxes
  await Hive.openBox('authBox');
  await initializeDateFormatting('id_ID', null);
  
  // Inject Controllers
  Get.put(UserController());
  Get.put(LanguageController());

  runApp(const MyApp());
}

// Custom Observer to log page navigation to terminal
class PageLogObserver extends GetObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _logNavigation(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logNavigation(newRoute);
    }
  }

  void _logNavigation(Route<dynamic> route) {
    String? name = route.settings.name;
    
    // If it's a GetPageRoute, we can get the actual widget name
    if (route is GetPageRoute) {
      name = route.page!().runtimeType.toString();
    }
    
    // If still null or generic, use the runtime type but clean it up
    name ??= route.runtimeType.toString().replaceAll('PageRoute', '').replaceAll('<Object>', '');
    
    debugPrint('🚀 [NAVIGATION] Current Page: $name');
  }
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
    final savedLang = LanguageController.to.selectedLang.value;
    final initialLocale = savedLang == 'id' 
        ? const Locale('id', 'ID') 
        : const Locale('en', 'US');

    return GetMaterialApp(
      title: 'Visitor App',
      navigatorObservers: [PageLogObserver()],
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),
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
      supportedLocales: const [Locale('en', 'US'), Locale('id', 'ID')],
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
