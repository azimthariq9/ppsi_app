// ============================================================
// lib/providers/providers.dart
// Provider untuk state management semua fitur
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AUTH PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get user => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isAdmin => _userModel?.role == 'admin';
  String get namaUser => _userModel?.nama ?? _firebaseUser?.displayName ?? 'Warga';
  String? get error => _error;

  AuthProvider() {
    _authService.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        _userModel = await _firestoreService.getUser(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final credential = await _authService.login(
        email: email,
        password: password,
      );

      _firebaseUser = credential.user;
      if (_firebaseUser != null) {
        _userModel = await _firestoreService.getUser(_firebaseUser!.uid);
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nama,
    required String nik,
    required String noHp,
    required String alamat,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final credential = await _authService.register(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(nama);

      final newUser = UserModel(
        id: credential.user!.uid,
        nama: nama,
        nik: nik,
        email: email,
        noHp: noHp,
        role: 'warga',
        alamat: alamat,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createUser(newUser);

      _firebaseUser = credential.user;
      _userModel = newUser;

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _firebaseUser = null;
    _userModel = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// PEMBAYARAN PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
class PembayaranProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  bool _isSubmitting = false;
  double _uploadProgress = 0;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;

  String get bulanIni => DateFormat('yyyy-MM').format(DateTime.now());

  Stream<List<PembayaranModel>> streamRiwayat(String userId) {
    return _db.streamPembayaranByUser(userId);
  }

  Future<PembayaranModel?> getStatusBulanIni(String userId) {
    return _db.getPembayaranBulanIni(userId, bulanIni);
  }

  /// Warga upload bukti bayar
  Future<bool> submitBuktiBayar({
    required String userId,
    required String namaWarga,
    required PickedFile buktiFoto,
    required String metodeBayar,
  }) async {
    _isSubmitting = true;
    _error = null;
    _uploadProgress = 0;
    notifyListeners();

    try {
      // 1. Upload foto bukti ke Storage
      final url = await _storage.uploadBuktiBayarWithProgress(
        userId,
        bulanIni,
        buktiFoto,
        onProgress: (p) {
          _uploadProgress = p;
          notifyListeners();
        },
      );

      // 2. Simpan record ke Firestore
      final pembayaran = PembayaranModel(
        id: '',
        userId: userId,
        namaWarga: namaWarga,
        jenisIuran: 'Iuran Bulanan',
        nominal: 50000,
        bulan: bulanIni,
        status: 'menunggu_verifikasi',
        metodeBayar: metodeBayar,
        buktiBayarUrl: url,
        createdAt: DateTime.now(),
      );

      await _db.createPembayaran(pembayaran);

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PENGADUAN PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
class PengaduanProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  bool _isSubmitting = false;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Stream<List<PengaduanModel>> streamMilikSaya(String userId) {
    return _db.streamPengaduanByUser(userId);
  }

  Future<bool> kirimPengaduan({
    required String userId,
    required String namaWarga,
    required String judul,
    required String isi,
    PickedFile? foto,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      String? fotoUrl;
      if (foto != null) {
        fotoUrl = await _storage.uploadFotoPengaduan(userId, foto);
      }

      final pengaduan = PengaduanModel(
        id: '',
        userId: userId,
        namaWarga: namaWarga,
        judul: judul,
        isiPengaduan: isi,
        fotoUrl: fotoUrl,
        status: 'menunggu',
        createdAt: DateTime.now(),
      );

      await _db.createPengaduan(pengaduan);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PERMOHONAN SURAT PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
class SuratProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  bool _isSubmitting = false;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Stream<List<PermohonanSuratModel>> streamMilikSaya(String userId) {
    return _db.streamSuratByUser(userId);
  }

  Future<bool> ajukanSurat({
    required String userId,
    required String namaWarga,
    required String nik,
    required String jenisSurat,
    required String keperluan,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final surat = PermohonanSuratModel(
        id: '',
        userId: userId,
        namaWarga: namaWarga,
        nik: nik,
        jenisSurat: jenisSurat,
        keperluan: keperluan,
        status: 'menunggu',
        createdAt: DateTime.now(),
      );

      await _db.createPermohonanSurat(surat);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UMKM PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
class UMKMProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  bool _isSubmitting = false;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Stream<List<UMKMModel>> streamAll() => _db.streamUMKM();

  Future<bool> daftarUMKM({
    required String pemilikId,
    required String namaUmkm,
    required String deskripsi,
    required String kategori,
    required String alamat,
    required String noHp,
    PickedFile? foto,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      String? fotoUrl;

      // Buat document dulu untuk dapat ID
      final docRef = FirebaseFirestore.instance.collection('umkm').doc();

      if (foto != null) {
        fotoUrl = await _storage.uploadFotoUMKM(docRef.id, foto);
      }

      final umkm = UMKMModel(
        id: docRef.id,
        pemilikId: pemilikId,
        namaUmkm: namaUmkm,
        deskripsi: deskripsi,
        kategori: kategori,
        alamat: alamat,
        noHp: noHp,
        fotoUrl: fotoUrl,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await docRef.set(umkm.toMap());
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
