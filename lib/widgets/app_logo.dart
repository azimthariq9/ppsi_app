import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Logo mark RT 03 RW 011, digambar langsung lewat kode (bukan file
/// gambar/asset) — supaya bisa dipakai di manapun tanpa perlu menambah
/// entri `assets:` di pubspec.yaml (yang berada di luar folder lib).
///
/// CATATAN: kalau nanti kamu punya file logo PNG final (seperti hasil
/// desain "RT 003 RW 011" yang bulat itu) dan ingin memakainya persis,
/// tinggal:
///   1. Taruh file di lib/img/logo.png
///   2. Tambahkan di pubspec.yaml:
///        flutter:
///          assets:
///            - lib/img/logo.png
///   3. Ganti isi build() di bawah ini dengan:
///        Image.asset('lib/img/logo.png', width: size, height: size)
///
/// Selama itu belum dilakukan, widget ini menampilkan logo mark vektor
/// yang senada (hijau, rumah, kerukunan warga) supaya tampilan tetap
/// konsisten di seluruh app.
class AppLogo extends StatelessWidget {
  final double size;
  final bool withRing;

  const AppLogo({super.key, this.size = 56, this.withRing = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.07),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        gradient: withRing
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFEFFBF3)],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withOpacity(0.25),
            blurRadius: size * 0.22,
            offset: Offset(0, size * 0.06),
          ),
        ],
        border: withRing
            ? Border.all(color: AppColors.glowLime.withOpacity(0.9), width: size * 0.045)
            : null,
      ),
      child: ClipOval(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryGreen, AppColors.darkGreen],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rumah di tengah
              Icon(
                Icons.home_work_rounded,
                color: Colors.white,
                size: size * 0.46,
              ),
              // Aksen daun (kelestarian/lingkungan) di pojok kanan bawah
              Positioned(
                right: size * 0.06,
                bottom: size * 0.08,
                child: Container(
                  padding: EdgeInsets.all(size * 0.045),
                  decoration: BoxDecoration(
                    color: AppColors.glowLime,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.darkGreen, width: size * 0.012),
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: AppColors.darkGreen,
                    size: size * 0.16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
