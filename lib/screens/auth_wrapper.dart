import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import 'admin/admin_dashboard_screen.dart';

/// Mengecek status login saat app pertama dibuka.
/// Jika user masih punya sesi aktif, langsung arahkan ke
/// halaman sesuai role (admin/warga) tanpa perlu login ulang.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoading();
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder(
          future: FirestoreService().getUser(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _SplashLoading();
            }

            final userModel = userSnapshot.data;
            if (userModel != null && userModel.role == 'admin') {
              return const AdminDashboardScreen();
            }
            return const MainShell();
          },
        );
      },
    );
  }
}

class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgGreen,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );
  }
}
