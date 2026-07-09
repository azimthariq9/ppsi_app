import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/modern_app_bar.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class PermohonanSuratScreen extends StatefulWidget {
  const PermohonanSuratScreen({super.key});

  @override
  State<PermohonanSuratScreen> createState() => _PermohonanSuratScreenState();
}

class _PermohonanSuratScreenState extends State<PermohonanSuratScreen> {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  final _namaCtrl = TextEditingController();
  final _noKtpCtrl = TextEditingController();
  final _kepCtrl = TextEditingController();
  String _jenisSurat = 'Surat Keterangan Domisili';
  PickedFile? _lampiranPdf;
  bool _submitted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _noKtpCtrl.dispose();
    _kepCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihLampiran() async {
    final file = await _storage.pickPdf();
    if (file != null) setState(() => _lampiranPdf = file);
  }

  Future<void> _submit() async {
    if (_namaCtrl.text.isEmpty || _noKtpCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua field'), backgroundColor: Colors.red),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSubmitting = true);

    try {
      String? lampiranUrl;
      if (_lampiranPdf != null) {
        lampiranUrl = await _storage.uploadLampiranSurat(uid, _lampiranPdf!);
      }

      await _db.createPermohonanSurat(PermohonanSuratModel(
        id: '',
        userId: uid,
        namaWarga: _namaCtrl.text.trim(),
        nik: _noKtpCtrl.text.trim(),
        jenisSurat: _jenisSurat,
        keperluan: _kepCtrl.text.trim(),
        status: 'menunggu',
        lampiranUrl: lampiranUrl,
        createdAt: DateTime.now(),
      ));

      if (!mounted) return;
      setState(() {
        _submitted = true;
        _namaCtrl.clear();
        _noKtpCtrl.clear();
        _kepCtrl.clear();
        _lampiranPdf = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permohonan surat berhasil dikirim!'), backgroundColor: AppColors.primaryGreen),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengajukan surat: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'selesai':
        return AppColors.primaryGreen;
      case 'diterima':
        return const Color(0xFF1565C0);
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
      case 'diterima':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final jenisSuratList = [
      'Surat Keterangan Domisili',
      'Surat Keterangan Tidak Mampu',
      'Surat Keterangan Usaha',
      'Surat Pengantar KTP',
      'Surat Pengantar KK',
      'Surat Keterangan Kelahiran',
      'Surat Keterangan Kematian',
      'Surat Keterangan Lainnya',
    ];

    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: ModernAppBar(title: 'Permohonan Surat'),
      drawer: const AppDrawer(currentRoute: '/permohonan-surat'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                    Expanded(child: Text('Permohonan surat berhasil dikirim! Surat akan diproses dalam 2-3 hari kerja.', style: TextStyle(color: AppColors.darkGreen, fontSize: 13))),
                  ],
                ),
              ),

            // Jenis Surat Options
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jenis Surat Tersedia', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkGreen)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: jenisSuratList.map((s) {
                      final isSelected = _jenisSurat == s;
                      return GestureDetector(
                        onTap: () => setState(() => _jenisSurat = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryGreen : AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Form
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
                  Row(
                    children: [
                      const Icon(Icons.description_rounded, color: AppColors.primaryGreen, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _jenisSurat,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Isi formulir berikut untuk mengajukan surat', style: TextStyle(fontSize: 12.5, color: AppColors.textGrey)),
                  const SizedBox(height: 20),

                  _buildLabel('Nama Lengkap *'),
                  _buildTextField(_namaCtrl, 'Sesuai KTP'),
                  const SizedBox(height: 14),

                  _buildLabel('Nomor KTP *'),
                  _buildTextField(_noKtpCtrl, '16 digit nomor KTP', keyboardType: TextInputType.number),
                  const SizedBox(height: 14),

                  _buildLabel('Keperluan'),
                  _buildTextField(_kepCtrl, 'Contoh: Keperluan melamar kerja'),
                  const SizedBox(height: 14),

                  _buildLabel('Lampiran PDF (opsional)'),
                  GestureDetector(
                    onTap: _pilihLampiran,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.bgGreen,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _lampiranPdf != null ? Icons.picture_as_pdf_rounded : Icons.upload_file_rounded,
                            color: AppColors.primaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _lampiranPdf != null
                                  ? _lampiranPdf!.name
                                  : 'Pilih file PDF (KTP, KK, dll)',
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
                                Text('Ajukan Permohonan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
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
                      'Surat akan diproses dalam 2-3 hari kerja. Ambil surat di Sekretariat RT 003/011 setelah mendapat konfirmasi.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.darkGreen, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Riwayat permohonan saya
            if (uid != null) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Riwayat Permohonan Saya',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<PermohonanSuratModel>>(
                stream: _db.streamSuratByUser(uid),
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
                      child: Text('Belum ada riwayat permohonan', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
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
                                  Text(item.jenisSurat, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                                  const SizedBox(height: 4),
                                  if (item.keperluan.isNotEmpty)
                                    Text(item.keperluan,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                  if (item.catatanAdmin != null) ...[
                                    const SizedBox(height: 6),
                                    Text('Catatan admin: ${item.catatanAdmin}',
                                        style: const TextStyle(fontSize: 11.5, color: AppColors.primaryGreen, fontStyle: FontStyle.italic)),
                                  ],
                                  if (item.fileSuratUrl != null) ...[
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => launchUrl(Uri.parse(item.fileSuratUrl!), mode: LaunchMode.platformDefault),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.picture_as_pdf_rounded, size: 15, color: AppColors.primaryGreen),
                                          SizedBox(width: 6),
                                          Text('Unduh Surat Jadi (PDF)',
                                              style: TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
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
            const SizedBox(height: 24),
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
