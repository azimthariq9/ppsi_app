import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/section_header.dart';

class ProfilRTScreen extends StatelessWidget {
  const ProfilRTScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profil RT', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/profil'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.darkGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.home_work_rounded, color: Colors.white, size: 48),
                  SizedBox(height: 10),
                  Text(
                    'RT 03 RW 011',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'Aren Jaya, Kecamatan Bekasi Timur, Kota Bekasi',
                    style: TextStyle(color: Color(0xFFB7E4C7), fontSize: 13),
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
                  const SectionHeader(badge: 'Tentang Kami', title: 'Profil RT 03 RW 011'),
                  const SizedBox(height: 20),

                  // Visi Misi
                  _buildInfoCard(
                    title: 'Visi',
                    content: 'Mewujudkan lingkungan RT 03 RW 011 yang bersih, aman, harmonis, dan sejahtera bagi seluruh warga.',
                    icon: Icons.visibility_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    title: 'Misi',
                    content: '• Meningkatkan kebersamaan dan gotong royong warga\n• Menjaga kebersihan dan keindahan lingkungan\n• Menyelenggarakan kegiatan sosial kemasyarakatan\n• Memfasilitasi kebutuhan administrasi warga',
                    icon: Icons.flag_rounded,
                  ),
                  const SizedBox(height: 20),

                  const SectionHeader(badge: 'Pengurus', title: 'Struktur Kepengurusan'),
                  const SizedBox(height: 16),

                  _buildPengurusCard('Ketua RT', 'Ahmad Fauzi', Icons.person_rounded),
                  _buildPengurusCard('Sekretaris', 'Budi Santoso', Icons.person_rounded),
                  _buildPengurusCard('Bendahara', 'Siti Rahayu', Icons.person_rounded),
                  _buildPengurusCard('Sie. Keamanan', 'Andi Prasetyo', Icons.person_rounded),
                  _buildPengurusCard('Sie. Kebersihan', 'Dewi Lestari', Icons.person_rounded),

                  const SizedBox(height: 20),
                  const SectionHeader(badge: 'Lokasi', title: 'Alamat & Kontak'),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        _buildContactRow(Icons.location_on_rounded, 'Jl. Madura IV, Aren Jaya, Kec. Bekasi Timur, Kota Bekasi 17111'),
                        const Divider(height: 20),
                        _buildContactRow(Icons.phone_rounded, '+62 812-XXXX-XXXX'),
                        const Divider(height: 20),
                        _buildContactRow(Icons.chat_rounded, 'Hubungi via WhatsApp'),
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

  Widget _buildInfoCard({required String title, required String content, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primaryGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkGreen)),
                const SizedBox(height: 6),
                Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengurusCard(String jabatan, String nama, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.lightGreen, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(jabatan, style: const TextStyle(fontSize: 11, color: AppColors.accentGreen, fontWeight: FontWeight.w600)),
              Text(nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accentGreen, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.5))),
      ],
    );
  }
}