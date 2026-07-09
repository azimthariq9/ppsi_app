import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../widgets/notification_bell.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_drawer.dart';
import '../widgets/hover_scale.dart';
import '../widgets/running_text_pembayaran.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _db = FirestoreService();
  String _namaUser = 'Warga';

  @override
  void initState() {
    super.initState();
    _loadNamaUser();
  }

  Future<void> _loadNamaUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final user = await _db.getUser(uid);
    if (mounted && user != null) {
      setState(() => _namaUser = user.nama);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      drawer: const AppDrawer(currentRoute: '/home'),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                const PembayaranRunningText(),
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
      backgroundColor: AppColors.darkGreen,
      pinned: true,
      floating: false,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.futuristicGradient),
      ),
      leadingWidth: 40,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Builder(
          builder: (ctx) => HoverScale(
            onTap: () => Scaffold.of(ctx).openDrawer(),
            child: const Icon(Icons.menu_rounded, color: Colors.white),
          ),
        ),
      ),
      title: Row(
        children: [
          const AppLogo(size: 34, withRing: false),
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
      actions: const [
        NotificationBell(role: 'warga'),
        SizedBox(width: 4),
      ],
    );
  }

  // ── HERO CARD ─────────────────────────────────────────────────────────────

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: AppColors.futuristicGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          ...AppColors.glowShadow(opacity: 0.18),
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
                Text('Selamat Datang,\n$_namaUser! 👋',
                    style: const TextStyle(
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
      child: HoverScale(
        onTap: onTap,
        enableHoverGlow: filled,
        glowColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('rt_info').doc('main').snapshots(),
        builder: (context, rtSnap) {
          final jumlahKK = rtSnap.hasData && rtSnap.data!.exists
              ? ((rtSnap.data!.data() as Map<String, dynamic>)['jumlah_kk'] ?? 0).toString()
              : '-';
          final jumlahPria = rtSnap.hasData && rtSnap.data!.exists
              ? ((rtSnap.data!.data() as Map<String, dynamic>)['jumlah_pria'] ?? 0) as int
              : 0;
          final jumlahWanita = rtSnap.hasData && rtSnap.data!.exists
              ? ((rtSnap.data!.data() as Map<String, dynamic>)['jumlah_wanita'] ?? 0) as int
              : 0;
          final jumlahJiwa = (jumlahPria + jumlahWanita).toString();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('pengumuman').snapshots(),
            builder: (context, pengumumanSnap) {
              final jumlahPengumuman = pengumumanSnap.hasData
                  ? pengumumanSnap.data!.docs.length.toString()
                  : '-';

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('umkm')
                    .where('is_active', isEqualTo: true)
                    .snapshots(),
                builder: (context, umkmSnap) {
                  final jumlahUmkm = umkmSnap.hasData
                      ? umkmSnap.data!.docs.length.toString()
                      : '-';

                  return Row(
                    children: [
                      _statChip(Icons.people_alt_rounded, jumlahKK, 'KK'),
                      const SizedBox(width: 10),
                      _statChip(Icons.person_rounded, jumlahJiwa, 'Jiwa'),
                      const SizedBox(width: 10),
                      _statChip(Icons.campaign_rounded, jumlahPengumuman, 'Pengumuman'),
                      const SizedBox(width: 10),
                      _statChip(Icons.store_rounded, jumlahUmkm, 'UMKM'),
                    ],
                  );
                },
              );
            },
          );
        },
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
      {'icon': Icons.people_alt_rounded, 'label': 'Profil RT', 'route': '/profil-rt', 'color': const Color(0xFFE8F5E9), 'iconColor': AppColors.primaryGreen},
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
            return HoverScale(
              enableHoverGlow: true,
              glowColor: a['iconColor'] as Color,
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pushNamed(context, a['route'] as String),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: a['color'] as Color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (a['iconColor'] as Color).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      a['icon'] as IconData,
                      color: a['iconColor'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    a['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
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

  static const Map<String, Color> _kategoriColor = {
    'Informasi': Color(0xFF1565C0),
    'Kegiatan': Color(0xFF2E7D32),
    'Kebijakan': Color(0xFFE65100),
    'Keuangan': Color(0xFF6A1B9A),
    'Kesehatan': Color(0xFFC62828),
  };

  String _formatTanggal(DateTime date) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }

  Widget _buildPengumumanSection(BuildContext context) {
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
        StreamBuilder<List<PengumumanModel>>(
          stream: _db.streamPengumuman(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 148,
                child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
              );
            }
            final items = snapshot.data!.take(5).toList();
            if (items.isEmpty) {
              return const SizedBox(
                height: 80,
                child: Center(
                  child: Text('Belum ada pengumuman',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                ),
              );
            }
            return SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final catColor = _kategoriColor[item.kategori] ?? AppColors.primaryGreen;
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
                                    color: catColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.kategori,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: catColor,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(_formatTanggal(item.createdAt),
                                    style: const TextStyle(fontSize: 10.5, color: AppColors.textGrey)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.judul,
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
                            const Row(
                              children: [
                                Text('Baca selengkapnya',
                                    style: TextStyle(
                                        fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primaryGreen),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // ── KEGIATAN MENDATANG ────────────────────────────────────────────────────

  static const List<Color> _kegiatanColors = [
    Color(0xFF1565C0), Color(0xFF2E7D32), Color(0xFF880E4F),
    Color(0xFFE65100), Color(0xFF6A1B9A),
  ];

  Widget _buildKegiatanSection(BuildContext context) {
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
        StreamBuilder<List<KegiatanModel>>(
          stream: _db.streamKegiatanMendatang(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
              );
            }
            final kegiatans = snapshot.data!;
            if (kegiatans.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Belum ada agenda mendatang',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: kegiatans.length,
              itemBuilder: (context, i) {
                final k = kegiatans[i];
                final color = _kegiatanColors[i % _kegiatanColors.length];
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
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.event_rounded, color: color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(k.namaKegiatan,
                                    style: const TextStyle(
                                        fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textGrey),
                                    const SizedBox(width: 4),
                                    Text(_formatTanggal(k.tanggal),
                                        style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textGrey),
                                    const SizedBox(width: 4),
                                    Text(k.jam,
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
            );
          },
        ),
      ],
    );
  }
}
