import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login_screen.dart';
import '../../utils/app_colors.dart';
import '../../services/firestore_service.dart';

import 'admin_pengumuman_screen.dart';
import 'admin_kegiatan_screen.dart';
import 'admin_galeri_screen.dart';
import 'admin_umkm_screen.dart';
import 'admin_profil_rt_screen.dart';
import 'admin_pengaduan_screen.dart';
import 'admin_permohonan_surat_screen.dart';
import 'admin_pembayaran_screen.dart';
import 'admin_data_warga_screen.dart';
import 'admin_tambah_admin_screen.dart';
import '../../widgets/notification_bell.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  String _namaAdmin = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadNamaAdmin();
  }

  Future<void> _loadNamaAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted && doc.exists) {
      setState(() {
        _namaAdmin = doc.data()?['nama'] ?? 'Admin';
      });
    }
  }

  final List<_AdminMenu> _menus = [
    _AdminMenu(icon: Icons.dashboard_rounded, label: 'Dashboard', color: AppColors.primaryGreen),
    _AdminMenu(icon: Icons.campaign_rounded, label: 'Pengumuman', color: const Color(0xFFF57C00)),
    _AdminMenu(icon: Icons.photo_library_rounded, label: 'Galeri', color: const Color(0xFF00695C)),
    _AdminMenu(icon: Icons.event_rounded, label: 'Kegiatan', color: const Color(0xFF1565C0)),
    _AdminMenu(icon: Icons.report_problem_rounded, label: 'Pengaduan', color: const Color(0xFFC62828)),
    _AdminMenu(icon: Icons.description_rounded, label: 'Surat', color: const Color(0xFF6A1B9A)),
    _AdminMenu(icon: Icons.storefront_rounded, label: 'UMKM', color: const Color(0xFFE65100)),
    _AdminMenu(icon: Icons.location_city_rounded, label: 'Profil RT', color: AppColors.darkGreen),
    _AdminMenu(icon: Icons.people_rounded, label: 'Data Warga', color: const Color(0xFF00838F)),
    _AdminMenu(icon: Icons.payment_rounded, label: 'Pembayaran', color: const Color(0xFF2E7D32)),
    _AdminMenu(icon: Icons.admin_panel_settings_rounded, label: 'Tambah Admin', color: const Color(0xFF4527A0)),
  ];

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGreen.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Admin Panel',
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('Selamat datang, $_namaAdmin',
                            style: const TextStyle(color: Color(0xFFB7E4C7), fontSize: 12)),
                      ],
                    ),
                  ),
                  const NotificationBell(role: 'admin'),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    tooltip: 'Logout',
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _currentIndex > 0
          ? null
          : null,
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) return _buildDashboardHome();
    return _buildMenuDetail(_menus[_currentIndex].label);
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.floatingShadow(),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -16,
                  right: -16,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selamat Datang, $_namaAdmin',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          const Text('Kelola RT 03 RW 011 dengan mudah',
                              style: TextStyle(color: Color(0xFFB7E4C7), fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<Map<String, int>>(
            future: FirestoreService().getDashboardStats(),
            builder: (context, snapshot) {
              final stats = snapshot.data;
              return Row(
                children: [
                  _statCard(Icons.campaign_rounded, '${stats?['pengumuman'] ?? '-'}', 'Pengumuman'),
                  const SizedBox(width: 10),
                  _statCard(Icons.event_rounded, '${stats?['kegiatan'] ?? '-'}', 'Agenda'),
                  const SizedBox(width: 10),
                  _statCard(Icons.store_rounded, '${stats?['umkm'] ?? '-'}', 'UMKM Aktif'),
                  const SizedBox(width: 10),
                  _statCard(Icons.report_problem_rounded, '${stats?['pengaduan_baru'] ?? '-'}', 'Pengaduan Baru'),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Text('Menu Admin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          // Grid Menu
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: _menus.length,
            itemBuilder: (context, index) {
              return _AdminMenuCard(
                menu: _menus[index],
                onTap: () => setState(() => _currentIndex = index),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accentGreen, size: 18),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.darkGreen)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textGrey), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

Widget _buildMenuDetail(String label) {

  Widget page;

  if (label == 'Kegiatan') {
    page = const AdminKegiatanScreen();
  } else if (label == 'Pengumuman') {
    page = const AdminPengumumanScreen();
  } else if (label == 'Galeri') {
    page = const AdminGaleriScreen();
  } else if (label == 'UMKM') {
    page = const AdminUmkmScreen();
  } else if (label == 'Profil RT') {
    page = const AdminProfilRtScreen();
  } else if (label == 'Pengaduan') {
    page = const AdminPengaduanScreen();
  } else if (label == 'Surat') {
    page = const AdminPermohonanSuratScreen();
  } else if (label == 'Pembayaran') {
    page = const AdminPembayaranScreen();
  } else if (label == 'Data Warga') {
    page = const AdminDataWargaScreen();
  } else if (label == 'Tambah Admin') {
    page = const AdminTambahAdminScreen();
  } else {
    page = Center(
      child: Text(
        '$label belum dibuat',
      ),
    );
  }

  return Column(
    children: [
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGreen.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),

      Expanded(
        child: page,
      ),
    ],
  );
}

}

class _AdminMenu {
  final IconData icon;
  final String label;
  final Color color;
  const _AdminMenu({required this.icon, required this.label, required this.color});
}

class _AdminMenuCard extends StatelessWidget {
  final _AdminMenu menu;
  final VoidCallback onTap;

  const _AdminMenuCard({required this.menu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: menu.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(menu.icon, color: menu.color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(menu.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}