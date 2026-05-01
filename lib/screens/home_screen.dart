import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _statusTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      drawer: const AppDrawer(currentRoute: '/'),
      body: Builder(
        builder: (context) => CustomScrollView(
          slivers: [
            // ── SliverAppBar (collapsing header) ──
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              snap: true,
              pinned: true,
              backgroundColor: AppColors.primaryGreen,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: AppColors.white, size: 26),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              title: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.home_work_rounded, color: AppColors.primaryGreen, size: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RT 03 RW 011',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Aren Jaya Bekasi Timur',
                        style: TextStyle(
                          color: Color(0xFFB7E4C7),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.white, size: 24),
                  onPressed: () {},
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeroSection(context),
                  _buildStatsSection(),
                  _buildProgramSection(),
                  _buildStatusSection(),
                  _buildPengumumanSection(context),
                  _buildKegiatanSection(context),
                  _buildGaleriSection(context),
                  _buildFooter(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HERO SECTION ──────────────────────────────────────────────────────────
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_rounded, color: Colors.white, size: 13),
                      SizedBox(width: 5),
                      Text(
                        'LINGKUNGAN BERSIH & LESTARI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'RT 03 RW 011\nAren Jaya\nBekasi Timur',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bersama menjaga keharmonisan lingkungan,\nmemperkuat kebersamaan warga.',
                  style: TextStyle(
                    color: Color(0xFFB7E4C7),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/kegiatan'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month_rounded, color: AppColors.primaryGreen, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Agenda Warga',
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/pengaduan'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.campaign_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Lapor Lingkungan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka Google Maps...'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: Color(0xFFB7E4C7), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Lihat Lokasi RT di Google Maps',
                        style: TextStyle(
                          color: Color(0xFFB7E4C7),
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFB7E4C7),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.open_in_new_rounded, color: Color(0xFFB7E4C7), size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STATS SECTION ─────────────────────────────────────────────────────────
  Widget _buildStatsSection() {
    return Container(
      color: AppColors.bgGreen,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // KK Card (full width)
          _buildKKCard(),
          const SizedBox(height: 12),
          // 3 smaller stat cards
          Row(
            children: [
              Expanded(child: _buildSmallStatCard(Icons.campaign_rounded, '4', 'Pengumuman Aktif', 'Informasi terbaru')),
              const SizedBox(width: 10),
              Expanded(child: _buildSmallStatCard(Icons.calendar_today_rounded, '5', 'Kegiatan Warga', 'Gotong royong')),
              const SizedBox(width: 10),
              Expanded(child: _buildSmallStatCard(Icons.store_rounded, '4', 'UMKM Aktif', 'Usaha lokal')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKKCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.people_alt_rounded, color: AppColors.primaryGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '66',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkGreen,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'Kepala Keluarga',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3.0,
            children: [
              _buildDemographicChip(Icons.person_rounded, 'PRIA', '101'),
              _buildDemographicChip(Icons.person_outline_rounded, 'WANITA', '115'),
              _buildDemographicChip(Icons.child_care_rounded, 'BALITA', '15'),
              _buildDemographicChip(Icons.school_rounded, 'ANAK SEKOLAH', '46'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.accentGreen),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 9.5, color: AppColors.textGrey, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(IconData icon, String value, String label, String sub) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.darkGreen,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textGrey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── PROGRAM LINGKUNGAN ────────────────────────────────────────────────────
  Widget _buildProgramSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgGreen, AppColors.softGreen],
        ),
      ),
      child: Column(
        children: [
          const SectionHeader(
            badge: 'Program Lingkungan',
            title: 'Hijaukan RT Kita Bersama',
            subtitle:
                'Berbagai program unggulan untuk menjaga kebersihan, mengelola sampah, dan memperkuat solidaritas warga.',
          ),
          const SizedBox(height: 20),
          _buildProgramCard(
            icon: Icons.recycling_rounded,
            title: 'Bank Sampah Warga',
            desc: 'Pengumpulan sampah anorganik terjadwal setiap akhir pekan untuk diolah menjadi barang bernilai dan menjaga kebersihan lingkungan.',
          ),
          const SizedBox(height: 12),
          _buildProgramCard(
            icon: Icons.local_florist_rounded,
            title: 'Taman Hijau Bersama',
            desc: 'Penanaman tanaman hias dan sayuran di lahan komunal, sekaligus ruang edukasi urban farming untuk anak-anak dan keluarga.',
          ),
          const SizedBox(height: 12),
          _buildProgramCard(
            icon: Icons.water_drop_rounded,
            title: 'Gerakan Hemat Air',
            desc: 'Sosialisasi penggunaan air secara bijak dan pembangunan biopori agar resapan air semakin baik dan terhindar dari genangan.',
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard({required IconData icon, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accentGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── CEK STATUS LAYANAN ────────────────────────────────────────────────────
  Widget _buildStatusSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LAYANAN WARGA',
            style: TextStyle(
              color: AppColors.accentGreen,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cek Status Layanan',
            style: TextStyle(
              color: Color(0xFF1A56DB),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cek status permohonan surat atau pengaduan Anda',
            style: TextStyle(color: AppColors.textGrey, fontSize: 12.5),
          ),
          const SizedBox(height: 14),

          // Tabs
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _statusTabIndex = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _statusTabIndex == 0 ? Colors.transparent : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: _statusTabIndex == 0 ? const Color(0xFF1A56DB) : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 14, color: _statusTabIndex == 0 ? const Color(0xFF1A56DB) : AppColors.textGrey),
                        const SizedBox(width: 5),
                        Text(
                          'Permohonan Surat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _statusTabIndex == 0 ? FontWeight.w700 : FontWeight.w400,
                            color: _statusTabIndex == 0 ? const Color(0xFF1A56DB) : AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _statusTabIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _statusTabIndex == 1 ? const Color(0xFF1A56DB) : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined, size: 14, color: _statusTabIndex == 1 ? const Color(0xFF1A56DB) : AppColors.textGrey),
                        const SizedBox(width: 5),
                        Text(
                          'Pengaduan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _statusTabIndex == 1 ? FontWeight.w700 : FontWeight.w400,
                            color: _statusTabIndex == 1 ? const Color(0xFF1A56DB) : AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Search bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama atau nomor KTP',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_searchController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Masukkan nama atau nomor KTP'), backgroundColor: AppColors.primaryGreen),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mencari: ${_searchController.text}'), backgroundColor: AppColors.primaryGreen),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text('Cari', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PENGUMUMAN TERBARU ────────────────────────────────────────────────────
  Widget _buildPengumumanSection(BuildContext context) {
    final pengumumans = [
      {
        'title': 'FORM MUDIK WARGA',
        'date': '15 Maret 2026',
        'desc': 'Kepada seluruh warga RT 003 RW 011 dihimbau jika akan melakukan perjalanan jauh atau mudik tahun 2026 harap mengisi form yang tersedia.',
        'color': const Color(0xFFF1F5F9),
      },
      {
        'title': 'Kerja Bakti Fasos Fasum',
        'date': '15 Februari 2026',
        'desc': 'Kerja bakti dilakukan secara gotong royong warga membersihkan lingkungan secara sukarela, sering dilaksanakan setiap bulan K3.',
        'color': const Color(0xFFF0FDF4),
      },
      {
        'title': 'Kawasan Wajib Belajar',
        'date': '11 Februari 2026',
        'desc': 'Konsep kawasan wajib belajar mulai pukul 19.00-21.00 WIB dilingkungan RT 003/011 yang sudah disepakati bersama warga.',
        'color': const Color(0xFFFFF7ED),
      },
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        children: [
          const SectionHeader(badge: 'Informasi Warga', title: 'Pengumuman Terbaru'),
          const SizedBox(height: 20),
          ...pengumumans.map((p) => _buildPengumumanCard(p, context)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/pengumuman'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryGreen),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Lihat Semua Pengumuman',
                  style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengumumanCard(Map<String, dynamic> p, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: p['color'] as Color,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            child: const Center(
              child: Icon(Icons.campaign_rounded, size: 50, color: AppColors.accentGreen),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['title'] as String,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(p['date'] as String, style: const TextStyle(fontSize: 11.5, color: AppColors.textGrey)),
                const SizedBox(height: 8),
                Text(
                  '${(p['desc'] as String).substring(0, 80)}...',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey, height: 1.5),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/pengumuman'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Baca Selengkapnya',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── KEGIATAN TERBARU ──────────────────────────────────────────────────────
  Widget _buildKegiatanSection(BuildContext context) {
    final kegiatans = [
      {
        'title': 'SISKAMLING WARGA RT 003',
        'tanggal': '15 Maret 2026',
        'jam': '00:00',
        'lokasi': 'Sekretariat RT 003/011',
        'desc': 'Kegiatan siskamling rutin warga tanggal 15 Maret 2026 dalam rangka menjaga keamanan lingkungan bersama.',
      },
      {
        'title': 'Kerja Bakti Fasos Fasum',
        'tanggal': '15 Februari 2026',
        'jam': '07:00',
        'lokasi': 'Fasos Fasum',
        'desc': 'Kegiatan kerja bakti warga dalam rangka bulan K3 bersama warga untuk menjaga kebersihan fasilitas umum.',
      },
      {
        'title': 'Arisan Ibu Ibu RT 003/011',
        'tanggal': '08 Februari 2026',
        'jam': '16:39',
        'lokasi': 'Sekretariat RT 003/011',
        'desc': 'Setiap awal bulan minggu pertama kegiatan rutin bagi ibu ibu untuk melaksanakan arisan guna terjaga silaturahmi.',
      },
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      color: AppColors.softGreen.withOpacity(0.5),
      child: Column(
        children: [
          const SectionHeader(badge: 'Agenda Kebersamaan', title: 'Kegiatan Terbaru'),
          const SizedBox(height: 20),
          ...kegiatans.map((k) => _buildKegiatanCard(k, context)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/kegiatan'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryGreen),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Lihat Semua Kegiatan',
                  style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKegiatanCard(Map<String, dynamic> k, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            child: const Center(
              child: Icon(Icons.event_rounded, size: 55, color: AppColors.accentGreen),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                _buildKegiatanMeta(Icons.calendar_today_rounded, k['tanggal'] as String),
                const SizedBox(height: 2),
                _buildKegiatanMeta(Icons.access_time_rounded, k['jam'] as String),
                const SizedBox(height: 2),
                _buildKegiatanMeta(Icons.location_on_rounded, k['lokasi'] as String),
                const SizedBox(height: 8),
                Text(
                  '${(k['desc'] as String).substring(0, 70)}...',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey, height: 1.5),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/kegiatan'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Detail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKegiatanMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textGrey),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      ],
    );
  }

  // ── GALERI ────────────────────────────────────────────────────────────────
  Widget _buildGaleriSection(BuildContext context) {
    final galeriItems = [
      {'title': 'Arisan Ibu Ibu RT 003/011', 'desc': 'Kegiatan Arisan...', 'color': const Color(0xFFFFF0F5)},
      {'title': 'Kerja Bakti', 'desc': 'Warga membersihkan lingkungan sekitar...', 'color': const Color(0xFFF0FFF4)},
      {'title': 'Senam Bersama', 'desc': 'Pelaksanaan kegiatan senam bersama ibu-ibu RT 03 RW 011...', 'color': const Color(0xFFF0F8FF)},
      {'title': 'HUT RI ke-80', 'desc': 'Peringatan HUT Kemerdekaan RI bersama warga...', 'color': const Color(0xFFFFFBF0)},
      {'title': 'Posyandu Balita', 'desc': 'Pemeriksaan kesehatan balita rutin...', 'color': const Color(0xFFF5F0FF)},
      {'title': 'Gotong Royong', 'desc': 'Kegiatan gotong royong membersihkan selokan...', 'color': const Color(0xFFF0FFF4)},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Column(
        children: [
          const SectionHeader(badge: 'Potret Lingkungan', title: 'Galeri Kegiatan'),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: galeriItems.length,
            itemBuilder: (context, i) {
              final item = galeriItems[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/galeri'),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
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
                          child: Center(
                            child: Icon(Icons.photo_camera_rounded, size: 40, color: AppColors.accentGreen.withOpacity(0.7)),
                          ),
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
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textGrey),
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
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/galeri'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryGreen),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('Lihat Semua Galeri', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FOOTER ────────────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.home_work_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'RT 03 RW 011',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_rounded, color: Colors.white54, size: 14),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Kelurahan Aren Jaya, Kecamatan Bekasi Timur.\nKota Bekasi. kode pos 17111.',
                  style: TextStyle(color: Colors.white54, fontSize: 12.5, height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Tautan Cepat', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Beranda', 'Profil RT', 'Pengumuman', 'Kegiatan', 'Pengaduan', 'Galeri'].map((label) {
              return GestureDetector(
                onTap: () {
                  final routes = {
                    'Beranda': '/',
                    'Profil RT': '/profil',
                    'Pengumuman': '/pengumuman',
                    'Kegiatan': '/kegiatan',
                    'Pengaduan': '/pengaduan',
                    'Galeri': '/galeri',
                  };
                  Navigator.pushNamed(context, routes[label]!);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 14),
                    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12.5)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Kontak', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.chat_rounded, color: Colors.white54, size: 14),
              SizedBox(width: 6),
              Text('Hubungi via WhatsApp', style: TextStyle(color: Colors.white54, fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '© 2026 Website RT 03 RW 011 Bekasi Timur.\nAll rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11.5, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}