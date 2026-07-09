import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/modern_app_bar.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class PengaduanScreen extends StatefulWidget {
  const PengaduanScreen({super.key});

  @override
  State<PengaduanScreen> createState() => _PengaduanScreenState();
}

class _PengaduanScreenState extends State<PengaduanScreen> {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  final _namaCtrl = TextEditingController();
  final _noKtpCtrl = TextEditingController();
  final _subjekCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  String _kategori = 'Lingkungan';
  PickedFile? _fotoTerpilih;
  bool _submitted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _noKtpCtrl.dispose();
    _subjekCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    final file = await _storage.pickImage();
    if (file != null) setState(() => _fotoTerpilih = file);
  }

  Future<void> _submit() async {
    if (_namaCtrl.text.isEmpty || _isiCtrl.text.isEmpty || _subjekCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua field'), backgroundColor: Colors.red),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSubmitting = true);

    try {
      String? fotoUrl;
      if (_fotoTerpilih != null) {
        fotoUrl = await _storage.uploadFotoPengaduan(uid, _fotoTerpilih!);
      }

      final isiLengkap = 'Kategori: $_kategori'
          '${_noKtpCtrl.text.trim().isNotEmpty ? '\nNo. KTP: ${_noKtpCtrl.text.trim()}' : ''}'
          '\n\n${_isiCtrl.text.trim()}';

      await _db.createPengaduan(PengaduanModel(
        id: '',
        userId: uid,
        namaWarga: _namaCtrl.text.trim(),
        judul: _subjekCtrl.text.trim(),
        isiPengaduan: isiLengkap,
        fotoUrl: fotoUrl,
        status: 'menunggu',
        createdAt: DateTime.now(),
      ));

      if (!mounted) return;
      setState(() {
        _submitted = true;
        _namaCtrl.clear();
        _noKtpCtrl.clear();
        _subjekCtrl.clear();
        _isiCtrl.clear();
        _fotoTerpilih = null;
        _kategori = 'Lingkungan';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaduan berhasil dikirim!'), backgroundColor: AppColors.primaryGreen),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pengaduan: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'selesai':
        return AppColors.primaryGreen;
      case 'diproses':
        return const Color(0xFFF57C00);
      case 'ditolak':
        return const Color(0xFFC62828);
      default:
        return AppColors.textGrey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'selesai':
        return 'Selesai';
      case 'diproses':
        return 'Diproses';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: ModernAppBar(title: 'Pengaduan'),
      drawer: const AppDrawer(currentRoute: '/pengaduan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_submitted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentGreen),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 22),
                    SizedBox(width: 10),
                    Expanded(child: Text('Pengaduan berhasil dikirim! Kami akan meninjau dalam 1x24 jam.', style: TextStyle(color: AppColors.darkGreen, fontSize: 13))),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.report_problem_rounded, color: AppColors.primaryGreen, size: 22),
                      SizedBox(width: 10),
                      Text('Form Pengaduan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Sampaikan keluhan atau laporan Anda kepada pengurus RT', style: TextStyle(fontSize: 12.5, color: AppColors.textGrey)),
                  const SizedBox(height: 20),

                  _buildLabel('Nama Lengkap *'),
                  _buildTextField(_namaCtrl, 'Masukkan nama lengkap Anda'),
                  const SizedBox(height: 14),

                  _buildLabel('Nomor KTP (opsional)'),
                  _buildTextField(_noKtpCtrl, 'Masukkan nomor KTP Anda', keyboardType: TextInputType.number),
                  const SizedBox(height: 14),

                  _buildLabel('Kategori Pengaduan *'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      value: _kategori,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['Lingkungan', 'Keamanan', 'Infrastruktur', 'Sosial', 'Lainnya']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) => setState(() => _kategori = val!),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildLabel('Subjek Pengaduan *'),
                  _buildTextField(_subjekCtrl, 'Masukkan subjek pengaduan'),
                  const SizedBox(height: 14),

                  _buildLabel('Isi Pengaduan *'),
                  TextField(
                    controller: _isiCtrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Ceritakan masalah atau keluhan Anda secara detail...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildLabel('Foto Bukti (opsional)'),
                  GestureDetector(
                    onTap: _pilihFoto,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.bgGreen,
                        borderRadius: BorderRadius.circular(10),
                        image: _fotoTerpilih != null
                            ? DecorationImage(image: MemoryImage(_fotoTerpilih!.bytes), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _fotoTerpilih == null
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, color: AppColors.primaryGreen, size: 24),
                                  SizedBox(height: 4),
                                  Text('Tambahkan Foto', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
                                ],
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: _isSubmitting ? null : _submit,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(12)),
                      child: _isSubmitting
                          ? const Center(
                              child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('Kirim Pengaduan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primaryGreen, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pengaduan akan diproses dalam 1×24 jam kerja. Untuk darurat, hubungi Ketua RT langsung via WhatsApp.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.darkGreen, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Riwayat pengaduan saya
            if (uid != null) ...[
              const Text('Riwayat Pengaduan Saya',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
              const SizedBox(height: 12),
              StreamBuilder<List<PengaduanModel>>(
                stream: _db.streamPengaduanByUser(uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                    );
                  }
                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Belum ada riwayat pengaduan', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                    );
                  }
                  return Column(
                    children: items.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.judul, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                                  const SizedBox(height: 4),
                                  Text(item.isiPengaduan,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                      maxLines: 2, overflow: TextOverflow.ellipsis),
                                  if (item.catatanAdmin != null) ...[
                                    const SizedBox(height: 6),
                                    Text('Catatan admin: ${item.catatanAdmin}',
                                        style: const TextStyle(fontSize: 11.5, color: AppColors.primaryGreen, fontStyle: FontStyle.italic)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(item.status).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(_statusLabel(item.status),
                                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _statusColor(item.status))),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
      ),
    );
  }
}
