import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_visitor_app/splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'presentation/auth/controller/user_controller.dart';
import 'presentation/auth/controller/language_controller.dart';
import 'core/localization/app_translations.dart';
import 'core/core.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';
// import 'routes/routes.dart';

// FCM Background message handler — MUST be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('🔔 [FCM] Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Open boxes
  await Hive.openBox('authBox');
  await Hive.openBox('dashboardBox');
  await initializeDateFormatting('id_ID', null);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set FCM background handler (must be before runApp)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Local Notification Service (non-fatal if fails)
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('⚠️ [NotificationService] Init failed: $e');
  }

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

    // If still null or generic, try to clean up the runtimeType
    if (name == null || name.contains('Material') || name.contains('PageRoute')) {
      name = route.settings.name ??
          route.runtimeType
              .toString()
              .replaceAll('PageRoute', '')
              .replaceAll('<dynamic>', '')
              .replaceAll('<Object>', '');
    }

    // If it's still generic, skip logging or use a better fallback
    if (name == 'Material' || name == 'GetPage') {
      // Don't log generic GetX/Material internal routes if they don't have names
      return;
    }

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
