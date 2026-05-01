import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';

class KegiatanScreen extends StatelessWidget {
  const KegiatanScreen({super.key});

  static const _items = [
    {
      'title': 'SISKAMLING WARGA RT 003',
      'tanggal': '15 Maret 2026',
      'jam': '00:00',
      'lokasi': 'Sekretariat RT 003/011',
      'desc': 'Kegiatan siskamling rutin warga tanggal 15 Maret 2026 dalam rangka menjaga keamanan lingkungan bersama-sama secara bergilir.',
    },
    {
      'title': 'Kerja Bakti Fasos Fasum',
      'tanggal': '15 Februari 2026',
      'jam': '07:00',
      'lokasi': 'Fasos Fasum',
      'desc': 'Kegiatan kerja bakti warga dalam rangka bulan K3 bersama warga untuk menjaga kebersihan fasilitas sosial dan umum di lingkungan RT.',
    },
    {
      'title': 'Arisan Ibu Ibu RT 003/011',
      'tanggal': '08 Februari 2026',
      'jam': '16:39',
      'lokasi': 'Sekretariat RT 003/011',
      'desc': 'Setiap awal bulan minggu pertama kegiatan rutin bagi ibu ibu untuk melaksanakan arisan guna terjaga silaturahmi antar warga.',
    },
    {
      'title': 'Senam Bersama Warga',
      'tanggal': '01 Februari 2026',
      'jam': '06:00',
      'lokasi': 'Lapangan RT 003/011',
      'desc': 'Kegiatan senam pagi bersama seluruh warga RT 003/011 setiap minggu pertama bulan berjalan untuk menjaga kebugaran bersama.',
    },
    {
      'title': 'Posyandu Balita',
      'tanggal': '05 Februari 2026',
      'jam': '09:00',
      'lokasi': 'Posyandu RT 003/011',
      'desc': 'Pemeriksaan kesehatan balita rutin setiap bulan. Harap membawa buku KIA dan KMS anak untuk pencatatan perkembangan.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Kegiatan', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/kegiatan'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final item = _items[i];
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
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                  ),
                  child: const Center(child: Icon(Icons.event_rounded, size: 48, color: AppColors.accentGreen)),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textGrey),
                          const SizedBox(width: 5),
                          Text(item['tanggal']!, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                          const SizedBox(width: 14),
                          const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textGrey),
                          const SizedBox(width: 5),
                          Text(item['jam']!, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textGrey),
                          const SizedBox(width: 5),
                          Expanded(child: Text(item['lokasi']!, style: const TextStyle(fontSize: 12, color: AppColors.textGrey), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['desc']!,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey, height: 1.5),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                        decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Detail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}