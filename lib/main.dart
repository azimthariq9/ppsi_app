import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/profil_rt_screen.dart';
import 'screens/pengumuman_screen.dart';
import 'screens/kegiatan_screen.dart';
import 'screens/pengaduan_screen.dart';
import 'screens/permohonan_surat_screen.dart';
import 'screens/galeri_screen.dart';
import 'screens/umkm_screen.dart';
import 'screens/pembayaran_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RT 03 RW 011',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A4F),
          primary: const Color(0xFF2D6A4F),
          secondary: const Color(0xFF52B788),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D6A4F),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
          elevation: 4,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0FAF4),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/profil': (context) => const ProfilRTScreen(),
        '/pengumuman': (context) => const PengumumanScreen(),
        '/kegiatan': (context) => const KegiatanScreen(),
        '/pengaduan': (context) => const PengaduanScreen(),
        '/permohonan-surat': (context) => const PermohonanSuratScreen(),
        '/galeri': (context) => const GaleriScreen(),
        '/umkm': (context) => const UMKMScreen(),
        '/pembayaran': (context) => const PembayaranScreen(),
      },
    );
  }
}