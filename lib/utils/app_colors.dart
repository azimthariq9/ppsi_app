import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color accentGreen = Color(0xFF52B788);
  static const Color lightGreen = Color(0xFFD8F3DC);
  static const Color softGreen = Color(0xFFEBF5EB);
  static const Color bgGreen = Color(0xFFF0FAF4);
  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF212121);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFB7E4C7);

  // ── Tambahan untuk tampilan modern (gradient, shadow, status) ──────────

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF12432F), primaryGreen, Color(0xFF3AAE73)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF40916C), Color(0xFF1B4332)],
  );

  // ── Futuristic gradient set (header, hero card, login/register) ────────
  // Multi-stop, diagonal, dengan aksen lime di ujung supaya terasa "glow"
  // dan tidak flat seperti gradient 2 warna biasa.

  static const Color glowLime = Color(0xFFB9FBC0);
  static const Color neonMint = Color(0xFF74E29B);

  static const LinearGradient futuristicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF08261C),
      Color(0xFF12432F),
      Color(0xFF1B5E3F),
      Color(0xFF2F9E62),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  static const LinearGradient authBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF081C15),
      Color(0xFF11402C),
      Color(0xFF1B4332),
      Color(0xFF2D6A4F),
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
  );

  // Overlay kaca (glassmorphism) di atas gradient gelap
  static Color glassFill = Colors.white.withOpacity(0.10);
  static Color glassBorder = Colors.white.withOpacity(0.22);
  static Color glassFillStrong = Colors.white.withOpacity(0.16);

  static List<BoxShadow> glowShadow({Color color = neonMint, double opacity = 0.35}) => [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: 22,
          spreadRadius: -2,
          offset: const Offset(0, 8),
        ),
      ];

  // Warna status, dipakai konsisten di seluruh app (pembayaran, pengaduan, surat)
  static const Color statusSuccess = Color(0xFF2D6A4F);
  static const Color statusSuccessBg = Color(0xFFE8F5E9);
  static const Color statusPending = Color(0xFF1565C0);
  static const Color statusPendingBg = Color(0xFFE3F2FD);
  static const Color statusWarning = Color(0xFFE65100);
  static const Color statusWarningBg = Color(0xFFFFF3E0);
  static const Color statusDanger = Color(0xFFC62828);
  static const Color statusDangerBg = Color(0xFFFCE4EC);

  // Shadow lembut standar untuk card — dipakai lewat helper di bawah
  static List<BoxShadow> cardShadow({double opacity = 0.05, double blur = 14}) => [
        BoxShadow(
          color: darkGreen.withOpacity(opacity),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> floatingShadow() => [
        BoxShadow(
          color: primaryGreen.withOpacity(0.28),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}
