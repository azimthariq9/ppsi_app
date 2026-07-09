// ============================================================
// lib/screens/admin/admin_tambah_admin_screen.dart
// Admin yang sudah login bisa membuat akun admin BARU langsung
// dari dashboard, tanpa buka Firebase Console. Admin baru tinggal
// login pakai email + password yang dibuat di sini.
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/models.dart';
import '../../services/admin_auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';

class AdminTambahAdminScreen extends StatefulWidget {
  const AdminTambahAdminScreen({super.key});

  @override
  State<AdminTambahAdminScreen> createState() => _AdminTambahAdminScreenState();
}

class _AdminTambahAdminScreenState extends State<AdminTambahAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _hpCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      String namaSaya = 'Admin';
      if (uid != null) {
        final me = await FirestoreService().getUser(uid);
        namaSaya = me?.nama ?? 'Admin';
      }

      await AdminAuthService().buatAkunAdminBaru(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        nama: _namaCtrl.text.trim(),
        noHp: _hpCtrl.text.trim(),
        dibuatOlehNama: namaSaya,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Admin baru "${_namaCtrl.text.trim()}" berhasil dibuat. '
              'Beri tahu mereka untuk login pakai email & password ini.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      _namaCtrl.clear();
      _emailCtrl.clear();
      _passCtrl.clear();
      _hpCtrl.clear();
    } on FirebaseAuthException catch (e) {
      String pesan = 'Gagal membuat akun admin.';
      if (e.code == 'email-already-in-use') pesan = 'Email sudah dipakai akun lain.';
      if (e.code == 'weak-password') pesan = 'Password terlalu lemah (minimal 6 karakter).';
      if (e.code == 'invalid-email') pesan = 'Format email tidak valid.';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesan), backgroundColor: AppColors.statusDanger),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: AppColors.statusDanger),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgGreen,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.darkGreen, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Akun admin baru bisa langsung login pakai email & password '
                              'di bawah ini, tanpa perlu registrasi ulang.',
                              style: TextStyle(fontSize: 12.5, color: AppColors.darkGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _label('Nama Lengkap Admin'),
                    TextFormField(
                      controller: _namaCtrl,
                      decoration: _inputDecoration('Contoh: Budi Santoso'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    _label('Email'),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('admin@contoh.com'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                        if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _label('Password Awal'),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      decoration: _inputDecoration('Minimal 6 karakter').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password wajib diisi';
                        if (v.length < 6) return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _label('No. HP'),
                    TextFormField(
                      controller: _hpCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('08xxxxxxxxxx'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'No. HP wajib diisi' : null,
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                      )
                    : const Text('Buat Akun Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );
}
