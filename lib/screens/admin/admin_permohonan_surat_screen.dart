import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_colors.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class AdminPermohonanSuratScreen extends StatefulWidget {
  const AdminPermohonanSuratScreen({super.key});

  @override
  State<AdminPermohonanSuratScreen> createState() => _AdminPermohonanSuratScreenState();
}

class _AdminPermohonanSuratScreenState extends State<AdminPermohonanSuratScreen> {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  String _formatTanggal(DateTime date) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'diterima':
        return const Color(0xFF1565C0);
      case 'selesai':
        return AppColors.primaryGreen;
      case 'ditolak':
        return const Color(0xFFC62828);
      default:
        return AppColors.textGrey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'diterima':
        return 'Diterima';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  Future<void> _ubahStatus(String docId, String status) async {
    await _db.updateStatusSurat(docId, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah menjadi ${_statusLabel(status)}'), backgroundColor: AppColors.primaryGreen),
      );
    }
  }

  Future<void> _uploadSuratJadi(String docId) async {
    final file = await _storage.pickPdf();
    if (file == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengunggah surat...'), backgroundColor: AppColors.primaryGreen),
    );

    try {
      final url = await _storage.uploadFileSuratJadi(docId, file);
      await _db.updateStatusSurat(docId, 'selesai', fileUrl: url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Surat berhasil diunggah & status diubah ke Selesai'), backgroundColor: AppColors.primaryGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah surat: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _bukaLampiran(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      body: StreamBuilder<List<PermohonanSuratModel>>(
        stream: _db.streamSemuaSurat(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Text('Belum ada permohonan surat', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.jenisSurat,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(item.status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_statusLabel(item.status),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(item.status))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_rounded, size: 13, color: AppColors.textGrey),
                        const SizedBox(width: 4),
                        Text(item.namaWarga, style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.badge_rounded, size: 13, color: AppColors.textGrey),
                        const SizedBox(width: 4),
                        Text('NIK: ${item.nik}', style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey)),
                      ],
                    ),
                    if (item.keperluan.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(item.keperluan, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4)),
                    ],
                    const SizedBox(height: 6),
                    Text(_formatTanggal(item.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                    if (item.lampiranUrl != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _bukaLampiran(item.lampiranUrl!),
                        child: const Row(
                          children: [
                            Icon(Icons.attach_file_rounded, size: 15, color: Color(0xFF1565C0)),
                            SizedBox(width: 6),
                            Text('Lihat Lampiran PDF Warga',
                                style: TextStyle(color: Color(0xFF1565C0), fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                    if (item.fileSuratUrl != null) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _bukaLampiran(item.fileSuratUrl!),
                        child: const Row(
                          children: [
                            Icon(Icons.picture_as_pdf_rounded, size: 15, color: AppColors.primaryGreen),
                            SizedBox(width: 6),
                            Text('Surat Jadi Sudah Diunggah',
                                style: TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _actionButton('Diterima', const Color(0xFF1565C0), () => _ubahStatus(item.id, 'diterima')),
                        _actionButton('Upload Surat Jadi', AppColors.primaryGreen, () => _uploadSuratJadi(item.id)),
                        _actionButton('Tolak', const Color(0xFFC62828), () => _ubahStatus(item.id, 'ditolak')),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
