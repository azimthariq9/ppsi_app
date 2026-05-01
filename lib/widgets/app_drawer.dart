import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryGreen, AppColors.darkGreen],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo circle
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.home_work_rounded, color: AppColors.primaryGreen, size: 20),
                        Text(
                          'RT',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                const Text(
                  'Aren Jaya, Bekasi Timur',
                  style: TextStyle(
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
                _buildMenuItem(context, icon: Icons.home_rounded, label: 'Beranda', route: '/'),
                _buildMenuItem(context, icon: Icons.people_alt_rounded, label: 'Profil RT', route: '/profil'),
                _buildMenuItem(context, icon: Icons.campaign_rounded, label: 'Pengumuman', route: '/pengumuman'),
                _buildMenuItem(context, icon: Icons.event_rounded, label: 'Kegiatan', route: '/kegiatan'),
                _buildMenuItem(context, icon: Icons.report_rounded, label: 'Pengaduan', route: '/pengaduan'),
                _buildMenuItem(context, icon: Icons.description_rounded, label: 'Permohonan Surat', route: '/permohonan-surat'),
                _buildMenuItem(context, icon: Icons.photo_library_rounded, label: 'Galeri', route: '/galeri'),
                _buildMenuItem(context, icon: Icons.store_rounded, label: 'UMKM', route: '/umkm'),
                const Divider(height: 24, indent: 16, endIndent: 16),
                _buildMenuItem(context, icon: Icons.admin_panel_settings_rounded, label: 'Admin', route: '/admin', isAdmin: true),
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
    bool isAdmin = false,
  }) {
    final bool isActive = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.lightGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isActive
              ? AppColors.primaryGreen
              : isAdmin
                  ? AppColors.textGrey
                  : AppColors.textDark.withOpacity(0.7),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive
                ? AppColors.primaryGreen
                : isAdmin
                    ? AppColors.textGrey
                    : AppColors.textDark,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: isActive
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
        onTap: () {
          Navigator.pop(context);
          if (currentRoute != route) {
            if (route == '/admin') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Halaman Admin - Segera hadir'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
              return;
            }
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}