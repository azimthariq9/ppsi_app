import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'hover_scale.dart';

/// AppBar modern dengan sudut bawah membulat dan shadow lembut,
/// pengganti AppBar standar Material yang terasa flat/kaku.
/// Dipakai di semua halaman sekunder (Pengumuman, Kegiatan, dll)
/// agar tampilan konsisten dan lebih modern.
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final List<Widget>? actions;

  const ModernAppBar({
    super.key,
    required this.title,
    this.onMenuTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const SizedBox(width: 6),
              Builder(
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: HoverScale(
                    onTap: onMenuTap ?? () => Scaffold.of(ctx).openDrawer(),
                    child: const Icon(Icons.menu_rounded, color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (actions != null) ...actions!,
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
