import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../screens/login_screen.dart';
import 'app_logo.dart';
import 'hover_scale.dart';

class AppDrawer extends StatefulWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _nama = '';
  String _role = 'warga';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted && doc.exists) {
      final d = doc.data() as Map<String, dynamic>;
      setState(() {
        _nama = d['nama'] ?? '';
        _role = d['role'] ?? 'warga';
      });
    }
  }

  Future<void> _logout() async {
    Navigator.pop(context);
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
    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 24, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: AppColors.futuristicGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(size: 64),
                const SizedBox(height: 14),
                const Text(
                  'RT 03 RW 011',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _nama.isNotEmpty ? _nama : 'Aren Jaya, Bekasi Timur',
                  style: const TextStyle(
                    color: Color(0xFFB7E4C7),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildMenuItem(context, icon: Icons.home_rounded, label: 'Beranda', route: '/home'),
                _buildMenuItem(context, icon: Icons.people_alt_rounded, label: 'Profil RT', route: '/profil-rt'),
                _buildMenuItem(context, icon: Icons.campaign_rounded, label: 'Pengumuman', route: '/pengumuman'),
                _buildMenuItem(context, icon: Icons.event_rounded, label: 'Kegiatan', route: '/kegiatan'),
                _buildMenuItem(context, icon: Icons.report_rounded, label: 'Pengaduan', route: '/pengaduan'),
                _buildMenuItem(context, icon: Icons.description_rounded, label: 'Permohonan Surat', route: '/permohonan-surat'),
                _buildMenuItem(context, icon: Icons.photo_library_rounded, label: 'Galeri', route: '/galeri'),
                _buildMenuItem(context, icon: Icons.store_rounded, label: 'UMKM', route: '/umkm'),
                if (_role == 'admin') ...[
                  const Divider(height: 24, indent: 16, endIndent: 16),
                  _buildMenuItem(context, icon: Icons.admin_panel_settings_rounded, label: 'Admin Panel', route: '/admin'),
                ],
                const Divider(height: 24, indent: 16, endIndent: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.logout_rounded, color: Color(0xFFC62828), size: 22),
                    title: const Text(
                      'Keluar',
                      style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onTap: _logout,
                  ),
                ),
              ],
            ),
          ),

          // Bottom info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '© 2026 RT 03 RW 011 Bekasi Timur',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final bool isActive = widget.currentRoute == route;

    return HoverScale(
      hoverScale: 1.0,
      pressScale: 0.98,
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        Navigator.pop(context);
        if (widget.currentRoute != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: _HoverTintItem(
        isActive: isActive,
        icon: icon,
        label: label,
      ),
    );
  }
}

/// Item menu drawer dengan tint hijau lembut yang muncul saat kursor
/// hover di atasnya (web/desktop) atau saat menu itu sedang aktif.
class _HoverTintItem extends StatefulWidget {
  final bool isActive;
  final IconData icon;
  final String label;

  const _HoverTintItem({
    required this.isActive,
    required this.icon,
    required this.label,
  });

  @override
  State<_HoverTintItem> createState() => _HoverTintItemState();
}

class _HoverTintItemState extends State<_HoverTintItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = widget.isActive || _hovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: highlighted ? AppColors.lightGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(
            widget.icon,
            color: highlighted ? AppColors.primaryGreen : AppColors.textDark.withOpacity(0.7),
            size: 22,
          ),
          title: Text(
            widget.label,
            style: TextStyle(
              color: highlighted ? AppColors.primaryGreen : AppColors.textDark,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing: widget.isActive
              ? Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}