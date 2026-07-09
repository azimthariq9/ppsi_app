// ============================================================
// lib/config/cloudinary_config.dart
// Konfigurasi Cloudinary untuk upload gambar & PDF.
//
// CATATAN KEAMANAN:
// Cloud name & upload preset BUKAN rahasia — keduanya memang
// didesain untuk ditaruh di kode client (app Flutter), karena
// preset ini bertipe "Unsigned" dan sudah dibatasi di sisi
// Cloudinary (lihat console: hanya bisa upload, tidak bisa
// overwrite/delete asset orang lain).
//
// API Secret TIDAK pernah ditaruh di sini atau di mana pun
// dalam kode app — itu hanya dipakai kalau ada server backend
// terpisah untuk operasi admin (hapus asset, dll), yang di luar
// scope app warga/RT ini.
// ============================================================

class CloudinaryConfig {
  static const String cloudName = 'dvb0vvnmu';
  static const String uploadPreset = 'ppsi_app_unsigned';

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';
}
