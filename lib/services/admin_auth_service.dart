// ============================================================
// lib/services/admin_auth_service.dart
// Membuat akun warga ATAU akun admin baru SECARA MANUAL oleh
// admin yang sedang login, tanpa membuat sesi admin ter-logout,
// dan TANPA perlu buka Firebase Console sama sekali.
//
// MASALAH: Firebase Auth client SDK akan otomatis pindah sesi
// login ke akun baru setiap kali createUserWithEmailAndPassword()
// dipanggil pada instance App yang sama — termasuk saat admin
// yang memanggilnya untuk membuat akun warga/admin lain.
//
// SOLUSI: Gunakan instance FirebaseApp KEDUA ("secondary app")
// yang terpisah dari instance utama. Proses create-user terjadi
// di sesi auth instance kedua ini, sehingga sesi admin yang login
// di instance utama tidak tersentuh sama sekali. Setelah user
// baru berhasil dibuat, instance kedua langsung di-sign-out dan
// dihapus (tidak dipakai lagi).
//
// Admin baru nantinya tinggal LOGIN memakai email + password yang
// sudah dibuatkan di sini lewat halaman login biasa — TIDAK perlu
// registrasi ulang, karena dokumen /users/{uid} dengan role:'admin'
// sudah langsung tersimpan.
// ============================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';
import '../models/models.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class AdminAuthService {
  static const String _secondaryAppName = 'SecondaryAppForAdminCreateUser';

  Future<FirebaseApp> _getSecondaryApp() async {
    try {
      return Firebase.app(_secondaryAppName);
    } catch (_) {
      return Firebase.initializeApp(
        name: _secondaryAppName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  /// Membuat akun warga baru (email + password) dari sisi admin,
  /// lalu menyimpan profil warga ke Firestore.
  /// Sesi login admin TIDAK terganggu sama sekali.
  Future<void> buatAkunWargaBaru({
    required String email,
    required String password,
    required String nama,
    required String nik,
    required String noHp,
    required String alamat,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await _getSecondaryApp();
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUid = credential.user!.uid;

      await FirestoreService().createUser(UserModel(
        id: newUid,
        nama: nama,
        nik: nik,
        noHp: noHp,
        alamat: alamat,
        email: email,
        role: 'warga',
        createdAt: DateTime.now(),
      ));

      await secondaryAuth.signOut();
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }

  /// FITUR BARU: Admin yang sudah login membuat akun ADMIN BARU.
  /// Admin baru login pakai email + password ini tanpa registrasi
  /// ulang. Sesi admin yang membuat TIDAK ikut ter-logout.
  ///
  /// [dibuatOlehNama] dipakai untuk isi notifikasi ke admin lain.
  Future<void> buatAkunAdminBaru({
    required String email,
    required String password,
    required String nama,
    required String noHp,
    required String dibuatOlehNama,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await _getSecondaryApp();
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUid = credential.user!.uid;

      await FirestoreService().createUser(UserModel(
        id: newUid,
        nama: nama,
        nik: '-',
        noHp: noHp,
        alamat: '-',
        email: email,
        role: 'admin',
        createdAt: DateTime.now(),
      ));

      await secondaryAuth.signOut();

      // Beritahu admin-admin lain bahwa ada admin baru
      await NotificationService().kirim(
        title: 'Admin Baru Ditambahkan',
        body: '$dibuatOlehNama menambahkan admin baru: $nama ($email)',
        type: 'admin_baru',
        audience: const ['admin'],
      );
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }
}
