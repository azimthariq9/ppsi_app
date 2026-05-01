import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';

class GaleriScreen extends StatelessWidget {
  const GaleriScreen({super.key});

  static final _items = [
    {'title': 'Arisan Ibu Ibu RT 003/011', 'desc': 'Kegiatan Arisan rutin setiap bulan', 'color': const Color(0xFFFFF0F5), 'icon': Icons.people_rounded},
    {'title': 'Kerja Bakti', 'desc': 'Warga membersihkan lingkungan sekitar secara gotong royong', 'color': const Color(0xFFF0FFF4), 'icon': Icons.cleaning_services_rounded},
    {'title': 'Senam Bersama', 'desc': 'Pelaksanaan kegiatan senam bersama ibu-ibu RT 03 RW 011 Kelurahan Aren Jaya', 'color': const Color(0xFFF0F8FF), 'icon': Icons.fitness_center_rounded},
    {'title': 'HUT RI ke-80', 'desc': 'Peringatan Hari Ulang Tahun Kemerdekaan Republik Indonesia bersama warga', 'color': const Color(0xFFFFFBF0), 'icon': Icons.celebration_rounded},
    {'title': 'Posyandu Balita', 'desc': 'Pemeriksaan kesehatan balita dan penimbangan berat badan rutin', 'color': const Color(0xFFF5F0FF), 'icon': Icons.child_care_rounded},
    {'title': 'Gotong Royong', 'desc': 'Kegiatan gotong royong membersihkan selokan dan jalan lingkungan', 'color': const Color(0xFFF0FFF4), 'icon': Icons.handshake_rounded},
    {'title': 'Siskamling', 'desc': 'Kegiatan siskamling rutin menjaga keamanan lingkungan RT', 'color': const Color(0xFFF0F0FF), 'icon': Icons.security_rounded},
    {'title': 'Pengajian Warga', 'desc': 'Kegiatan pengajian rutin bersama warga RT 003/011 setiap malam Jumat', 'color': const Color(0xFFFFF8F0), 'icon': Icons.menu_book_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Galeri Kegiatan', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/galeri'),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: _items.length,
          itemBuilder: (context, i) {
            final item = _items[i];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: item['color'] as Color,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                          ),
                          child: Center(child: Icon(item['icon'] as IconData, size: 60, color: AppColors.accentGreen)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(item['desc'] as String, style: const TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.5)),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(10)),
                                  child: const Center(child: Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: item['color'] as Color,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                        ),
                        child: Center(child: Icon(item['icon'] as IconData, size: 44, color: AppColors.accentGreen.withOpacity(0.8))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item['desc'] as String,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textGrey, height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}