import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/modern_app_bar.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class PengumumanScreen extends StatefulWidget {
  const PengumumanScreen({super.key});

  @override
  State<PengumumanScreen> createState() => _PengumumanScreenState();
}

class _PengumumanScreenState extends State<PengumumanScreen> {
  final FirestoreService _db = FirestoreService();

  String _formatTanggal(DateTime date) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }

  void _showDetail(PengumumanModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.kategori,
                    style: const TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                Text(item.judul,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 6),
                Text(_formatTanggal(item.createdAt),
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                const SizedBox(height: 16),
                Text(item.isi,
                    style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.6)),
                const SizedBox(height: 12),
                Text('Diposting oleh ${item.createdByNama}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: ModernAppBar(title: 'Pengumuman'),
      drawer: const AppDrawer(currentRoute: '/pengumuman'),
      body: StreamBuilder<List<PengumumanModel>>(
        stream: _db.streamPengumuman(),
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
              child: Text('Belum ada pengumuman',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                        image: item.gambarUrl != null
                            ? DecorationImage(image: NetworkImage(item.gambarUrl!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: item.gambarUrl == null
                          ? const Center(child: Icon(Icons.campaign_rounded, size: 45, color: AppColors.accentGreen))
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.kategori,
                                  style: const TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Spacer(),
                              Text(_formatTanggal(item.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(item.judul, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          const SizedBox(height: 6),
                          Text(
                            item.isi,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey, height: 1.5),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _showDetail(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                              decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Baca Selengkapnya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5)),
                            ),
                          ),
                        ],
                      ),
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
}
