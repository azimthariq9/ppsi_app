import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';

class UMKMScreen extends StatelessWidget {
  const UMKMScreen({super.key});

  static final _items = [
    {
      'nama': 'Warung Makan Bu Sari',
      'kategori': 'Kuliner',
      'desc': 'Menyajikan masakan rumahan khas Jawa dengan harga terjangkau. Buka setiap hari pukul 07.00-21.00 WIB.',
      'kontak': '+62 812-0001-0001',
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFFFF8F0),
    },
    {
      'nama': 'Toko Sembako Pak Budi',
      'kategori': 'Sembako',
      'desc': 'Menyediakan kebutuhan sembako lengkap dengan harga grosir untuk warga sekitar lingkungan RT 003.',
      'kontak': '+62 813-0002-0002',
      'icon': Icons.shopping_basket_rounded,
      'color': const Color(0xFFF0FFF4),
    },
    {
      'nama': 'Laundry Kilat Bu Dewi',
      'kategori': 'Jasa',
      'desc': 'Layanan laundry kilat 1 hari selesai. Terima cuci setrika pakaian, sprei, dan seragam.',
      'kontak': '+62 814-0003-0003',
      'icon': Icons.local_laundry_service_rounded,
      'color': const Color(0xFFF0F8FF),
    },
    {
      'nama': 'Bengkel Motor Pak Joko',
      'kategori': 'Otomotif',
      'desc': 'Servis motor semua merek, ganti oli, tambal ban, dan spare part original. Pengalaman 15 tahun.',
      'kontak': '+62 815-0004-0004',
      'icon': Icons.build_rounded,
      'color': const Color(0xFFFFF0F0),
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
        title: const Text('UMKM', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/umkm'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              color: AppColors.primaryGreen,
              child: const Column(
                children: [
                  Icon(Icons.storefront_rounded, color: Colors.white, size: 36),
                  SizedBox(height: 8),
                  Text(
                    'UMKM RT 03 RW 011',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Dukung pelaku usaha lokal di lingkungan kita',
                    style: TextStyle(color: Color(0xFFB7E4C7), fontSize: 12.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  ..._items.map((item) => _buildUMKMCard(item, context)),
                  const SizedBox(height: 16),

                  // CTA - Daftarkan UMKM
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primaryGreen, AppColors.darkGreen], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.add_business_rounded, color: Colors.white, size: 32),
                        const SizedBox(height: 8),
                        const Text('Daftarkan Usaha Anda', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        const Text(
                          'Punya usaha di RT 003/011? Daftarkan dan promosikan usaha Anda kepada warga.',
                          style: TextStyle(color: Color(0xFFB7E4C7), fontSize: 12, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fitur pendaftaran UMKM segera hadir!'), backgroundColor: AppColors.primaryGreen),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: const Text('Daftar Sekarang', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUMKMCard(Map<String, dynamic> item, BuildContext context) {
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
            height: 90,
            decoration: BoxDecoration(
              color: item['color'] as Color,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            child: Center(child: Icon(item['icon'] as IconData, size: 44, color: AppColors.accentGreen)),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item['nama'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(6)),
                      child: Text(item['kategori'] as String, style: const TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item['desc'] as String, style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey, height: 1.5)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.phone_rounded, size: 13, color: AppColors.accentGreen),
                    const SizedBox(width: 6),
                    Text(item['kontak'] as String, style: const TextStyle(fontSize: 12.5, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}