import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/modern_app_bar.dart';
import '../widgets/section_header.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class ProfilRTScreen extends StatefulWidget {
  const ProfilRTScreen({super.key});

  @override
  State<ProfilRTScreen> createState() => _ProfilRTScreenState();
}

class _ProfilRTScreenState extends State<ProfilRTScreen> {
  final FirestoreService _db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: ModernAppBar(title: 'Profil RT'),
      drawer: const AppDrawer(currentRoute: '/profil-rt'),
      body: FutureBuilder<ProfilRTModel?>(
        future: _db.getProfilRT(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          final profil = snapshot.data;
          final namaRT = profil?.namaRT ?? 'RT 03';
          final namaRW = profil?.namaRW ?? 'RW 011';
          final kelurahan = profil?.kelurahan ?? 'Aren Jaya';
          final kecamatan = profil?.kecamatan ?? 'Bekasi Timur';
          final kota = profil?.kota ?? 'Kota Bekasi';
          final kodePos = profil?.kodePos ?? '17111';
          final visi = profil != null && profil.visi.isNotEmpty
              ? profil.visi
              : 'Mewujudkan lingkungan $namaRT $namaRW yang bersih, aman, harmonis, dan sejahtera bagi seluruh warga.';
          final misi = profil != null && profil.misi.isNotEmpty
              ? profil.misi
              : '• Meningkatkan kebersamaan dan gotong royong warga\n• Menjaga kebersihan dan keindahan lingkungan\n• Menyelenggarakan kegiatan sosial kemasyarakatan\n• Memfasilitasi kebutuhan administrasi warga';

          return SingleChildScrollView(
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
                  child: Column(
                    children: [
                      const Icon(Icons.home_work_rounded, color: Colors.white, size: 48),
                      const SizedBox(height: 10),
                      Text(
                        '$namaRT $namaRW',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '$kelurahan, Kecamatan $kecamatan, $kota',
                        style: const TextStyle(color: Color(0xFFB7E4C7), fontSize: 13),
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
                      SectionHeader(badge: 'Tentang Kami', title: 'Profil $namaRT $namaRW'),
                      const SizedBox(height: 20),

                      // Visi Misi
                      _buildInfoCard(title: 'Visi', content: visi, icon: Icons.visibility_rounded),
                      const SizedBox(height: 12),
                      _buildInfoCard(title: 'Misi', content: misi, icon: Icons.flag_rounded),
                      const SizedBox(height: 20),

                      const SectionHeader(badge: 'Pengurus', title: 'Struktur Kepengurusan'),
                      const SizedBox(height: 16),

                      if (profil?.namaKetua.isNotEmpty ?? false)
                        _buildPengurusCard('Ketua RT', profil!.namaKetua, Icons.person_rounded),
                      if (profil?.namaWakilKetua.isNotEmpty ?? false)
                        _buildPengurusCard('Wakil Ketua RT', profil!.namaWakilKetua, Icons.person_rounded),
                      if (profil?.namaSekretaris.isNotEmpty ?? false)
                        _buildPengurusCard('Sekretaris', profil!.namaSekretaris, Icons.person_rounded),
                      if (profil?.namaBendahara.isNotEmpty ?? false)
                        _buildPengurusCard('Bendahara', profil!.namaBendahara, Icons.person_rounded),
                      if (profil == null ||
                          (profil.namaKetua.isEmpty &&
                              profil.namaWakilKetua.isEmpty &&
                              profil.namaSekretaris.isEmpty &&
                              profil.namaBendahara.isEmpty))
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Data pengurus belum diisi oleh admin',
                              style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                        ),

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
                            _buildContactRow(Icons.location_on_rounded,
                                '$kelurahan, Kec. $kecamatan, $kota $kodePos'),
                            const Divider(height: 20),
                            _buildContactRow(Icons.phone_rounded,
                                (profil?.noHpKetua.isNotEmpty ?? false) ? profil!.noHpKetua : 'Belum diisi'),
                            const Divider(height: 20),
                            const _ContactRowStatic(icon: Icons.chat_rounded, text: 'Hubungi via WhatsApp'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
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

class _ContactRowStatic extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRowStatic({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
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
