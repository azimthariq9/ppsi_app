import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';
import 'pembayaran_screen.dart';
import 'profil_screen.dart';

/// Shell utama untuk warga: membungkus 3 tab (Home, Bayar, Profil)
/// dengan bottom navigation bar custom yang modern — floating pill
/// dengan indikator aktif yang halus, bukan BottomNavigationBar
/// bawaan Flutter yang terasa kaku/flat.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeScreen(),
    PembayaranScreen(),
    ProfilScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGreen.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _navItem(icon: Icons.home_rounded, label: 'Home', index: 0),
            _navItem(icon: Icons.qr_code_scanner_rounded, label: 'Bayar', index: 1, isCenter: true),
            _navItem(icon: Icons.person_rounded, label: 'Profil', index: 2),
          ],
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required int index, bool isCenter = false}) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                scale: isActive ? 1.08 : 1.0,
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : AppColors.textGrey,
                  size: isCenter ? 24 : 22,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : AppColors.textGrey,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
