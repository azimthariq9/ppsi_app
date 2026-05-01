import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';

class PengumumanScreen extends StatelessWidget {
  const PengumumanScreen({super.key});

  static const _items = [
    {
      'title': 'FORM MUDIK WARGA',
      'date': '15 Maret 2026',
      'category': 'Informasi',
      'desc': 'Kepada seluruh warga RT 003 RW 011 dihimbau jika akan melakukan perjalanan jauh atau mudik tahun 2026 harap mengisi form yang tersedia agar pengurus RT dapat mendata warga yang mudik.',
    },
    {
      'title': 'Kerja Bakti Fasos Fasum',
      'date': '15 Februari 2026',
      'category': 'Kegiatan',
      'desc': 'Kerja bakti dilakukan secara gotong royong warga membersihkan lingkungan secara sukarela, sering dilaksanakan setiap bulan K3 untuk menjaga kebersihan fasilitas sosial dan fasilitas umum.',
    },
    {
      'title': 'Kawasan Wajib Belajar',
      'date': '11 Februari 2026',
      'category': 'Kebijakan',
      'desc': 'Konsep kawasan wajib belajar mulai pukul 19.00-21.00 WIB dilingkungan RT 003/011 yang sudah disepakati bersama warga demi meningkatkan prestasi anak-anak RT.',
    },
    {
      'title': 'Iuran Bulanan Warga',
      'date': '01 Februari 2026',
      'category': 'Keuangan',
      'desc': 'Mengingatkan kepada seluruh warga RT 003/011 untuk membayar iuran bulanan yang digunakan untuk operasional RT dan kegiatan lingkungan bersama.',
    },
    {
      'title': 'Jadwal Posyandu Balita',
      'date': '25 Januari 2026',
      'category': 'Kesehatan',
      'desc': 'Jadwal Posyandu Balita bulan Februari 2026 akan dilaksanakan pada minggu pertama. Harap membawa buku KIA dan KMS anak.',
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
        title: const Text('Pengumuman', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/pengumuman'),
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
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                  ),
                  child: const Center(child: Icon(Icons.campaign_rounded, size: 45, color: AppColors.accentGreen)),
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
                              item['category']!,
                              style: const TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Spacer(),
                          Text(item['date']!, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(item['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const SizedBox(height: 6),
                      Text(
                        item['desc']!,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey, height: 1.5),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Baca Selengkapnya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5)),
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