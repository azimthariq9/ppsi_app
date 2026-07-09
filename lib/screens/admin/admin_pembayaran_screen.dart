import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';

class AdminPembayaranScreen extends StatefulWidget {
  const AdminPembayaranScreen({super.key});

  @override
  State<AdminPembayaranScreen> createState() => _AdminPembayaranScreenState();
}

class _AdminPembayaranScreenState extends State<AdminPembayaranScreen> {
  final FirestoreService _db = FirestoreService();
  String? _statusFilter;

  String _formatBulanLabel(String bulanKode) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final parts = bulanKode.split('-');
    if (parts.length != 2) return bulanKode;
    final idx = int.tryParse(parts[1]);
    if (idx == null || idx < 1 || idx > 12) return bulanKode;
    return '${bulan[idx - 1]} ${parts[0]}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'lunas':
        return AppColors.primaryGreen;
      case 'menunggu_verifikasi':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFFC62828);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'lunas':
        return 'Lunas';
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      default:
        return 'Belum Bayar';
    }
  }

  Future<void> _verifikasi(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _db.verifikasiPembayaran(id, uid);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran diverifikasi'), backgroundColor: AppColors.primaryGreen),
      );
    }
  }

  Future<void> _tolak(String id) async {
    await _db.tolakPembayaran(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran ditolak'), backgroundColor: Color(0xFFC62828)),
      );
    }
  }

  void _showBuktiBayar(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip('Semua', null),
                  _filterChip('Menunggu Verifikasi', 'menunggu_verifikasi'),
                  _filterChip('Lunas', 'lunas'),
                  _filterChip('Belum Bayar', 'belum'),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PembayaranModel>>(
              stream: _db.streamSemuaPembayaran(statusFilter: _statusFilter),
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
                    child: Text('Tidak ada data pembayaran', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.namaWarga, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                                    Text('Iuran ${_formatBulanLabel(item.bulan)} · ${item.metodeBayar}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                  ],
                                ),
                              ),
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
                          const SizedBox(height: 8),
                          Text('Rp ${item.nominal.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
                          if (item.buktiBayarUrl != null) ...[
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => _showBuktiBayar(item.buktiBayarUrl!),
                              child: Row(
                                children: [
                                  const Icon(Icons.image_rounded, size: 16, color: AppColors.primaryGreen),
                                  const SizedBox(width: 6),
                                  const Text('Lihat Bukti Bayar', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12.5, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                          if (item.status == 'menunggu_verifikasi') ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _verifikasi(item.id),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(8)),
                                      child: const Center(child: Text('Verifikasi', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700))),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _tolak(item.id),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      decoration: BoxDecoration(color: const Color(0xFFC62828), borderRadius: BorderRadius.circular(8)),
                                      child: const Center(child: Text('Tolak', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700))),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    final isActive = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _statusFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppColors.textDark)),
          ),
        ),
      ),
    );
  }
}
