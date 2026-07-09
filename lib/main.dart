import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/providers.dart';
import 'screens/auth_wrapper.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/admin/admin_dashboard_screen.dart';

import 'screens/pengumuman_screen.dart';
import 'screens/kegiatan_screen.dart';
import 'screens/pengaduan_screen.dart';
import 'screens/permohonan_surat_screen.dart';
import 'screens/profil_rt_screen.dart';
import 'screens/umkm_screen.dart';
import 'screens/pembayaran_screen.dart';
import 'screens/galeri_screen.dart';
import 'screens/notifikasi_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PembayaranProvider()),
        ChangeNotifierProvider(create: (_) => PengaduanProvider()),
        ChangeNotifierProvider(create: (_) => SuratProvider()),
        ChangeNotifierProvider(create: (_) => UMKMProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RT 03 RW 011',
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const MainShell(),
          '/admin': (context) => const AdminDashboardScreen(),

          '/pengumuman': (context) => const PengumumanScreen(),
          '/kegiatan': (context) => const KegiatanScreen(),
          '/pengaduan': (context) => const PengaduanScreen(),
          '/permohonan-surat': (context) => const PermohonanSuratScreen(),
          '/profil-rt': (context) => const ProfilRTScreen(),
          '/umkm': (context) => UMKMScreen(),
          '/pembayaran': (context) => const PembayaranScreen(),
          '/galeri': (context) => GaleriScreen(),
          '/notifikasi': (context) => const NotifikasiScreen(role: 'warga'),
        },
      ),
    );
  }
}