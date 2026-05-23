import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../screens/home_screen.dart';
import '../screens/pembayaran_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          _LayananTab(),
          PembayaranScreen(),
          _KabarTab(),
          _ProfilTabView(),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ─── CUSTOM BOTTOM NAV BAR ───────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _NavItem(index: 0, icon: Icons.home_rounded, label: 'Beranda', current: currentIndex, onTap: onTap),
              _NavItem(index: 1, icon: Icons.grid_view_rounded, label: 'Layanan', current: currentIndex, onTap: onTap),
              // Center Payment Button
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF52B788), Color(0xFF1B4332)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          currentIndex == 2
                              ? Icons.payment_rounded
                              : Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Bayar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: currentIndex == 2 ? FontWeight.w700 : FontWeight.w600,
                          color: currentIndex == 2 ? AppColors.primaryGreen : AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _NavItem(index: 3, icon: Icons.campaign_rounded, label: 'Kabar', current: currentIndex, onTap: onTap),
              _NavItem(index: 4, icon: Icons.person_rounded, label: 'Profil', current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = current == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isActive ? AppColors.primaryGreen : const Color(0xFFB0BEC5),
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primaryGreen : const Color(0xFFB0BEC5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── LAYANAN TAB ─────────────────────────────────────────────────────────────

class _LayananTab extends StatelessWidget {
  const _LayananTab();

  static const _services = [
    {'icon': Icons.people_alt_rounded, 'label': 'Profil RT', 'route': '/profil', 'color': Color(0xFFE8F5E9)},
    {'icon': Icons.campaign_rounded, 'label': 'Pengumuman', 'route': '/pengumuman', 'color': Color(0xFFFFF8E1)},
    {'icon': Icons.event_rounded, 'label': 'Kegiatan', 'route': '/kegiatan', 'color': Color(0xFFE3F2FD)},
    {'icon': Icons.forum_rounded, 'label': 'Pengaduan', 'route': '/pengaduan', 'color': Color(0xFFFCE4EC)},
    {'icon': Icons.description_rounded, 'label': 'Permohonan\nSurat', 'route': '/permohonan-surat', 'color': Color(0xFFF3E5F5)},
    {'icon': Icons.photo_library_rounded, 'label': 'Galeri', 'route': '/galeri', 'color': Color(0xFFE0F7FA)},
    {'icon': Icons.store_rounded, 'label': 'UMKM Warga', 'route': '/umkm', 'color': Color(0xFFFFF3E0)},
    {'icon': Icons.admin_panel_settings_rounded, 'label': 'Admin\nPanel', 'route': '/admin', 'color': Color(0xFFECEFF1)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primaryGreen,
            expandedHeight: 110,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Layanan Warga',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Akses semua fitur dalam satu tempat',
                      style: TextStyle(color: Color(0xFFB7E4C7), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ServiceCard(service: _services[i]),
                childCount: _services.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final route = service['route'] as String;
        if (route == '/admin') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Halaman Admin - Segera hadir'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          return;
        }
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: service['color'] as Color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  service['icon'] as IconData,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  service['label'] as String,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── KABAR TAB ───────────────────────────────────────────────────────────────

class _KabarTab extends StatefulWidget {
  const _KabarTab();

  @override
  State<_KabarTab> createState() => _KabarTabState();
}

class _KabarTabState extends State<_KabarTab>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _pengumumans = [
    {'title': 'FORM MUDIK WARGA', 'date': '15 Mar 2026', 'cat': 'Informasi', 'catColor': Color(0xFF1565C0)},
    {'title': 'Kerja Bakti Fasos Fasum', 'date': '15 Feb 2026', 'cat': 'Kegiatan', 'catColor': Color(0xFF2E7D32)},
    {'title': 'Kawasan Wajib Belajar', 'date': '11 Feb 2026', 'cat': 'Kebijakan', 'catColor': Color(0xFFE65100)},
    {'title': 'Iuran Bulanan Warga', 'date': '01 Feb 2026', 'cat': 'Keuangan', 'catColor': Color(0xFF6A1B9A)},
    {'title': 'Jadwal Posyandu Balita', 'date': '25 Jan 2026', 'cat': 'Kesehatan', 'catColor': Color(0xFFC62828)},
  ];

  static const _kegiatans = [
    {'title': 'SISKAMLING WARGA RT 003', 'date': '15 Mar 2026', 'jam': '00:00', 'lokasi': 'Sekretariat RT'},
    {'title': 'Kerja Bakti Fasos Fasum', 'date': '15 Feb 2026', 'jam': '07:00', 'lokasi': 'Fasos Fasum'},
    {'title': 'Arisan Ibu Ibu RT 003/011', 'date': '08 Feb 2026', 'jam': '16:39', 'lokasi': 'Sekretariat RT'},
    {'title': 'Gotong Royong RT', 'date': '01 Feb 2026', 'jam': '08:00', 'lokasi': 'Lingkungan RT'},
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryGreen,
        title: const Text('Kabar & Kegiatan',
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          tabs: const [
            Tab(text: 'Pengumuman'),
            Tab(text: 'Kegiatan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildPengumumanList(),
          _buildKegiatanList(),
        ],
      ),
    );
  }

  Widget _buildPengumumanList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pengumumans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final p = _pengumumans[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.campaign_rounded, color: AppColors.primaryGreen, size: 22),
            ),
            title: Text(
              p['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(p['date'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (p['catColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p['cat'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: p['catColor'] as Color,
                    ),
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
            onTap: () => Navigator.pushNamed(context, '/pengumuman'),
          ),
        );
      },
    );
  }

  Widget _buildKegiatanList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _kegiatans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final k = _kegiatans[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.event_rounded, color: AppColors.primaryGreen, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(k['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textGrey),
                          const SizedBox(width: 4),
                          Text(k['date'] as String, style: const TextStyle(fontSize: 11.5, color: AppColors.textGrey)),
                          const SizedBox(width: 10),
                          const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textGrey),
                          const SizedBox(width: 4),
                          Text(k['jam'] as String, style: const TextStyle(fontSize: 11.5, color: AppColors.textGrey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 11, color: AppColors.accentGreen),
                          const SizedBox(width: 4),
                          Text(k['lokasi'] as String,
                              style: const TextStyle(fontSize: 11.5, color: AppColors.accentGreen, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── PROFIL TAB ──────────────────────────────────────────────────────────────

class _ProfilTabView extends StatelessWidget {
  const _ProfilTabView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primaryGreen,
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.home_work_rounded, color: AppColors.primaryGreen, size: 26),
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('RT 03 RW 011',
                                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                                  Text('Aren Jaya, Bekasi Timur',
                                      style: TextStyle(color: Color(0xFFB7E4C7), fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfilCard(),
                  const SizedBox(height: 14),
                  _buildPengurusCard(context),
                  const SizedBox(height: 14),
                  _buildKontakCard(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data Demografis',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
            const SizedBox(height: 14),
            _statRow('Kepala Keluarga', '66 KK'),
            _divider(),
            _statRow('Total Pria', '101 jiwa'),
            _divider(),
            _statRow('Total Wanita', '115 jiwa'),
            _divider(),
            _statRow('Balita', '15 anak'),
            _divider(),
            _statRow('Anak Sekolah', '46 anak'),
          ],
        ),
      ),
    );
  }

  Widget _buildPengurusCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/profil'),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D6A4F), Color(0xFF40916C)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(Icons.badge_rounded, color: Colors.white, size: 32),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profil Lengkap RT',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('Lihat data pengurus, sejarah & visi misi',
                        style: TextStyle(color: Color(0xFFB7E4C7), fontSize: 12.5)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white60, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKontakCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kontak & Lokasi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
            const SizedBox(height: 14),
            _contactRow(Icons.location_on_rounded, 'Kel. Aren Jaya, Kec. Bekasi Timur\nKota Bekasi 17111'),
            const SizedBox(height: 10),
            _contactRow(Icons.chat_rounded, 'Hubungi via WhatsApp'),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka Google Maps...'), backgroundColor: AppColors.primaryGreen),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryGreen),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_rounded, color: AppColors.primaryGreen, size: 18),
                    SizedBox(width: 8),
                    Text('Lihat di Google Maps',
                        style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 13.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13.5)),
          Text(value,
              style: const TextStyle(color: AppColors.darkGreen, fontSize: 13.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade100, height: 1);

  Widget _contactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.accentGreen),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.5))),
      ],
    );
  }
}
