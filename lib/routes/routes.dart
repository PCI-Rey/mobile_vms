import 'package:flutter/material.dart';
import '../../presentation/home/visitor/visitor_page.dart';
import '../../presentation/parking/as_operator/parking_page.dart';
import '../../splashscreen.dart';
import '../../presentation/home/invitation/add_invitation_page.dart';
import '../../presentation/home/invitation/send_invitation_page.dart';
import '../../presentation/home/report/report_page.dart';
import '../presentation/auth/forgot_password/change_password_page.dart';
import '../presentation/auth/forgot_password/input_email_page.dart';
import '../presentation/auth/forgot_password/otp_confirmation_page.dart'
    show OtpConfirmationPage;
import '../presentation/auth/informasi_umum_page.dart';
import '../presentation/auth/login_page.dart';
import '../presentation/auth/signature_agreement_page.dart';
import '../presentation/auth/take_ktp.dart' show TakeKtpPage;
import '../presentation/auth/verification_code_page.dart';
import '../presentation/home/guest_home_page.dart' show GuestHomePage;

class Routes {
  // Route name constants
  static const String splash = '/';

  // auth
  static const String login = '/login';
  static const String inputEmail = '/input-email';
  static const String verificationCode = '/verification-code';
  static const String otpConfirmation = '/otp-confirmation';
  static const String changePassword = '/change-password';
  static const String informasiUmum = '/informasi-umum';
  static const String signatureAgreement = '/signature-agreement';
  static const String takeKtp = '/take-ktp';
  static const String takeSelfie = '/take-selfie';

  //guest
  static const String guestParking = '/guest-parking';
  static const String guestDashboard = '/guest-dashboard';
  static const String guestHomePage = '/guest-homepage';
  static const String visitorPage = '/visitor';

  //employee
  static const String operatorParking = '/operator-parking';
  static const String addInvitation = '/add-invitation';
  static const String sendInvitation = '/send-invitation';
  static const String reportPage = '/report';

  // Routes used by all roles (e.g., splash screen)
  static final Map<String, WidgetBuilder> commonRoutes = {
    splash: (_) => const Splashscreen(),

    // auth
    login: (_) => const LoginPage(),
    inputEmail: (_) => const InputEmailPage(),
    verificationCode: (_) => const VerificationCodePage(),
    otpConfirmation: (_) => const OtpConfirmationPage(),
    changePassword: (_) => const ChangePasswordPage(),
    informasiUmum: (_) => const InformasiUmumPage(),
    signatureAgreement: (_) => const SignAgreementPage(),
    takeKtp: (_) => const TakeKtpPage(),
  };

  // Routes for Guest role
  static final Map<String, WidgetBuilder> guestRoutes = {
    guestHomePage: (_) => GuestHomePage(),
    guestParking: (_) => ParkingPage(),
    
  };

  // Routes for Employee role
  static final Map<String, WidgetBuilder> employeeRoutes = {
    visitorPage: (_) => VisitorPage(),
    addInvitation: (_) => const AddInvitationPage(),
    sendInvitation: (_) => const SendInvitationPage(),
    reportPage: (_) => VisitorReportPage(),
  };

  // Routes for Operator role
  static final Map<String, WidgetBuilder> operatorRoutes = {
    operatorParking: (_) => ParkingPage(),
  };

  /// All routes combined – useful for MaterialApp `routes: Routes.getAll()`
  static Map<String, WidgetBuilder> getAll() {
    return {
      ...commonRoutes,
      ...guestRoutes,
      ...employeeRoutes,
      ...operatorRoutes,
    };
  }

  /// Only guest routes
  static Map<String, WidgetBuilder> forGuest() {
    return {...commonRoutes, ...guestRoutes};
  }

  /// Only employee routes
  static Map<String, WidgetBuilder> forEmployee() {
    return {...commonRoutes, ...employeeRoutes};
  }

  /// Only operator routes
  static Map<String, WidgetBuilder> forOperator() {
    return {...commonRoutes, ...operatorRoutes};
  }
}
