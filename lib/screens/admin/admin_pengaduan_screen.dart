import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';

class AdminPengaduanScreen extends StatefulWidget {
  const AdminPengaduanScreen({super.key});

  @override
  State<AdminPengaduanScreen> createState() => _AdminPengaduanScreenState();
}

class _AdminPengaduanScreenState extends State<AdminPengaduanScreen> {
  final FirestoreService _db = FirestoreService();

  Color _statusColor(String status) {
    switch (status) {
      case 'diproses':
        return const Color(0xFFF57C00);
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
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  Future<void> _ubahStatus(String docId, String status) async {
    await _db.updateStatusPengaduan(docId, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah menjadi ${_statusLabel(status)}'), backgroundColor: AppColors.primaryGreen),
      );
    }
  }

  String _formatTanggal(DateTime date) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      body: StreamBuilder<List<PengaduanModel>>(
        stream: _db.streamSemuaPengaduan(),
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
              child: Text('Belum ada pengaduan', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
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
                          child: Text(item.judul,
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_rounded, size: 13, color: AppColors.textGrey),
                        const SizedBox(width: 4),
                        Text(item.namaWarga, style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textGrey),
                        const SizedBox(width: 4),
                        Text(_formatTanggal(item.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(item.isiPengaduan, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4)),
                    if (item.fotoUrl != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(item.fotoUrl!, height: 140, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _actionButton('Proses', const Color(0xFFF57C00), () => _ubahStatus(item.id, 'diproses')),
                        _actionButton('Selesai', AppColors.primaryGreen, () => _ubahStatus(item.id, 'selesai')),
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
