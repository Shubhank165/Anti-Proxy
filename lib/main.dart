import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // <-- ADD THIS IMPORT
import 'services/local_data_service.dart'; // <-- ADD THIS IMPORT
import 'student/screens/student_home_screen.dart';
import 'teacher/screens/teacher_home_screen.dart';
import 'admin/screens/admin_dashboard_screen.dart';
import 'common/app_colors.dart';

void main() {
  // Wrap the entire app in a provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocalDataService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: ThemeData(
        primarySwatch: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: AppColors.textColor),
          titleTextStyle: TextStyle(
            color: AppColors.textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const RoleSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome!',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please select your role to continue',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 50),
            _RoleButton(
              role: 'Student',
              icon: Icons.school,
              color: Colors.blueAccent,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentHomeScreen())),
            ),
            _RoleButton(
              role: 'Teacher',
              icon: Icons.person,
              color: Colors.deepPurpleAccent,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherHomeScreen())),
            ),
            _RoleButton(
              role: 'Admin',
              icon: Icons.admin_panel_settings,
              color: Colors.orangeAccent,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String role;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _RoleButton({required this.role, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(role, style: const TextStyle(fontSize: 18, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}