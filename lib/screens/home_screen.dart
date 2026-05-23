import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                _buildQuickStats(),
                _buildQuickActions(context),
                _buildPengumumanSection(context),
                _buildKegiatanSection(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryGreen,
      pinned: true,
      floating: false,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Center(
              child: Icon(Icons.home_work_rounded, color: AppColors.primaryGreen, size: 17),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RT 03 RW 011',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
              Text('Aren Jaya, Bekasi Timur',
                  style: TextStyle(color: Color(0xFFB7E4C7), fontSize: 10.5)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFFFF6B6B), shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── HERO CARD ─────────────────────────────────────────────────────────────

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_rounded, color: Colors.white, size: 11),
                      SizedBox(width: 5),
                      Text('LINGKUNGAN BERSIH & LESTARI',
                          style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Selamat Datang,\nWarga RT 03! 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 8),
                const Text('Bersama menjaga keharmonisan\nlingkungan kita.',
                    style: TextStyle(color: Color(0xFFB7E4C7), fontSize: 13, height: 1.4)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _heroButton(
                      context,
                      icon: Icons.calendar_month_rounded,
                      label: 'Agenda',
                      onTap: () => Navigator.pushNamed(context, '/kegiatan'),
                      filled: true,
                    ),
                    const SizedBox(width: 10),
                    _heroButton(
                      context,
                      icon: Icons.campaign_rounded,
                      label: 'Lapor',
                      onTap: () => Navigator.pushNamed(context, '/pengaduan'),
                      filled: false,
                    ),
                    const SizedBox(width: 10),
                    _heroButton(
                      context,
                      icon: Icons.description_rounded,
                      label: 'Surat',
                      onTap: () => Navigator.pushNamed(context, '/permohonan-surat'),
                      filled: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: filled ? Colors.white : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: filled ? null : Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: filled ? AppColors.primaryGreen : Colors.white, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: filled ? AppColors.primaryGreen : Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── QUICK STATS ───────────────────────────────────────────────────────────

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          _statChip(Icons.people_alt_rounded, '66', 'KK'),
          const SizedBox(width: 10),
          _statChip(Icons.person_rounded, '216', 'Jiwa'),
          const SizedBox(width: 10),
          _statChip(Icons.campaign_rounded, '4', 'Pengumuman'),
          const SizedBox(width: 10),
          _statChip(Icons.store_rounded, '4', 'UMKM'),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accentGreen, size: 16),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.darkGreen, height: 1)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 9, color: AppColors.textGrey),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ── QUICK ACTIONS GRID ────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.campaign_rounded, 'label': 'Pengumuman', 'route': '/pengumuman', 'color': const Color(0xFFFFF8E1), 'iconColor': const Color(0xFFF57C00)},
      {'icon': Icons.event_rounded, 'label': 'Kegiatan', 'route': '/kegiatan', 'color': const Color(0xFFE3F2FD), 'iconColor': const Color(0xFF1565C0)},
      {'icon': Icons.forum_rounded, 'label': 'Pengaduan', 'route': '/pengaduan', 'color': const Color(0xFFFCE4EC), 'iconColor': const Color(0xFFC62828)},
      {'icon': Icons.description_rounded, 'label': 'Surat', 'route': '/permohonan-surat', 'color': const Color(0xFFF3E5F5), 'iconColor': const Color(0xFF6A1B9A)},
      {'icon': Icons.photo_library_rounded, 'label': 'Galeri', 'route': '/galeri', 'color': const Color(0xFFE0F7FA), 'iconColor': const Color(0xFF00695C)},
      {'icon': Icons.store_rounded, 'label': 'UMKM', 'route': '/umkm', 'color': const Color(0xFFFFF3E0), 'iconColor': const Color(0xFFE65100)},
      {'icon': Icons.people_alt_rounded, 'label': 'Profil RT', 'route': '/profil', 'color': const Color(0xFFE8F5E9), 'iconColor': AppColors.primaryGreen},
      {'icon': Icons.qr_code_scanner_rounded, 'label': 'Bayar Iuran', 'route': '/bayar', 'color': const Color(0xFFE8F5E9), 'iconColor': AppColors.darkGreen},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Layanan Cepat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 14,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: actions.length,
          itemBuilder: (context, i) {
            final a = actions[i];
            final isBayar = a['route'] == '/bayar';
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (isBayar) {
                  // Navigate to payment tab via parent - just push named route simulation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Buka tab Bayar di bawah'),
                      backgroundColor: AppColors.primaryGreen,
                      duration: Duration(seconds: 1),
                    ),
                  );
                  return;
                }
                Navigator.pushNamed(context, a['route'] as String);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isBayar ? AppColors.primaryGreen : a['color'] as Color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isBayar ? AppColors.primaryGreen : a['iconColor'] as Color).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      a['icon'] as IconData,
                      color: isBayar ? Colors.white : a['iconColor'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    a['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isBayar ? AppColors.primaryGreen : AppColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── PENGUMUMAN TERBARU ────────────────────────────────────────────────────

  Widget _buildPengumumanSection(BuildContext context) {
    final items = [
      {'title': 'FORM MUDIK WARGA', 'date': '15 Mar 2026', 'cat': 'Informasi', 'catColor': const Color(0xFF1565C0), 'bgColor': const Color(0xFFE3F2FD)},
      {'title': 'Kerja Bakti Fasos Fasum', 'date': '15 Feb 2026', 'cat': 'Kegiatan', 'catColor': const Color(0xFF2E7D32), 'bgColor': const Color(0xFFE8F5E9)},
      {'title': 'Kawasan Wajib Belajar', 'date': '11 Feb 2026', 'cat': 'Kebijakan', 'catColor': const Color(0xFFE65100), 'bgColor': const Color(0xFFFFF3E0)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pengumuman Terbaru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/pengumuman'),
                child: const Text('Lihat semua',
                    style: TextStyle(fontSize: 12.5, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/pengumuman'),
                child: Container(
                  width: 230,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (item['catColor'] as Color).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['cat'] as String,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: item['catColor'] as Color,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(item['date'] as String,
                                style: const TextStyle(fontSize: 10.5, color: AppColors.textGrey)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Text('Baca selengkapnya',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primaryGreen),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── KEGIATAN MENDATANG ────────────────────────────────────────────────────

  Widget _buildKegiatanSection(BuildContext context) {
    final kegiatans = [
      {'title': 'SISKAMLING WARGA', 'date': '15 Mar', 'jam': '00:00', 'icon': Icons.security_rounded, 'color': const Color(0xFF1565C0)},
      {'title': 'Kerja Bakti Fasos Fasum', 'date': '15 Feb', 'jam': '07:00', 'icon': Icons.cleaning_services_rounded, 'color': const Color(0xFF2E7D32)},
      {'title': 'Arisan Ibu-Ibu RT', 'date': '08 Feb', 'jam': '16:39', 'icon': Icons.groups_rounded, 'color': const Color(0xFF880E4F)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Agenda Mendatang',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/kegiatan'),
                child: const Text('Lihat semua',
                    style: TextStyle(fontSize: 12.5, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemCount: kegiatans.length,
          itemBuilder: (context, i) {
            final k = kegiatans[i];
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/kegiatan'),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (k['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(k['icon'] as IconData, color: k['color'] as Color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(k['title'] as String,
                                style: const TextStyle(
                                    fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textGrey),
                                const SizedBox(width: 4),
                                Text(k['date'] as String,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                const SizedBox(width: 12),
                                const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textGrey),
                                const SizedBox(width: 4),
                                Text(k['jam'] as String,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Detail',
                            style: TextStyle(
                                fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
