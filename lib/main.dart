import 'package:flutter/material.dart';
import 'dashboards_page/teacher_dashboard_page.dart';
import 'dashboards_page/student_dashboard_page.dart';
import 'pages/upload_material_page.dart';
import 'public_view/login_page.dart';
import 'public_view/home_page.dart';
import 'public_view/news_page.dart';
import 'public_view/calendar_page.dart';
import 'security_service/register_page.dart';
import 'security_service/change_password_page.dart';
import 'security_service/forgot_password_page.dart';
import 'security_service/verify_email_page.dart';
import 'security_service/reset_password_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning Platform',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == '/verify-email') {
          final args = settings.arguments as Map<String, dynamic>?;
          final email = args?['email'] ?? '';
          return MaterialPageRoute(
            builder: (context) => VerifyEmailPage(email: email),
          );
        }
        
        // Handle all other routes
        switch (settings.name) {
          case '/login':
          case '/':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomePage());
          case '/news':
            return MaterialPageRoute(builder: (context) => const NewsPage());
          case '/calendar':
            return MaterialPageRoute(builder: (context) => const CalendarPage());
          case '/dashboard':
          case '/teacher-dashboard':
          case '/faculty-dashboard':
            return MaterialPageRoute(builder: (context) => const TeacherDashboardPage());
          case '/student-dashboard':
            return MaterialPageRoute(builder: (context) => const StudentDashboardPage());
          case '/upload':
            return MaterialPageRoute(builder: (context) => const UploadMaterialPage());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterPage());
          case '/change-password':
            return MaterialPageRoute(builder: (context) => const ChangePasswordPage());
          case '/forgot-password':
            return MaterialPageRoute(builder: (context) => const ForgotPasswordPage());
          case '/reset-password':
            return MaterialPageRoute(builder: (context) => const ResetPasswordPage());
          default:
            return MaterialPageRoute(builder: (context) => const LoginPage());
        }
      },
    );
  }
}