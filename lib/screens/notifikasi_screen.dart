// ============================================================
// lib/screens/notifikasi_screen.dart
// Daftar notifikasi realtime milik user yang sedang login.
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';

class NotifikasiScreen extends StatefulWidget {
  final String role; // 'admin' atau 'warga'
  const NotifikasiScreen({super.key, required this.role});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final _notifService = NotificationService();
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Silakan login terlebih dahulu.')));
    }

    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          StreamBuilder<List<NotificationModel>>(
            stream: _notifService.streamNotifikasi(uid: uid, role: widget.role),
            builder: (context, snapshot) {
              final list = snapshot.data ?? [];
              if (list.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _notifService.tandaiSemuaDibaca(
                  list.map((n) => n.id).toList(),
                  uid,
                ),
                child: const Text('Tandai semua dibaca', style: TextStyle(color: Colors.white, fontSize: 12)),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notifService.streamNotifikasi(uid: uid, role: widget.role),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 56, color: AppColors.textGrey.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  Text('Belum ada notifikasi', style: TextStyle(color: AppColors.textGrey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _NotifTile(
              notif: list[i],
              uid: uid,
              onTap: () => _notifService.tandaiDibaca(list[i].id, uid),
            ),
          );
        },
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;
  final String uid;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.uid, required this.onTap});

  IconData get _icon {
    switch (notif.type) {
      case 'pengaduan_baru':
      case 'pengaduan_update':
        return Icons.report_problem_rounded;
      case 'surat_baru':
      case 'surat_update':
        return Icons.description_rounded;
      case 'pembayaran_baru':
      case 'pembayaran_update':
        return Icons.payment_rounded;
      case 'umkm_baru':
        return Icons.storefront_rounded;
      case 'pengumuman':
        return Icons.campaign_rounded;
      case 'kegiatan':
        return Icons.event_rounded;
      case 'galeri':
        return Icons.photo_library_rounded;
      case 'admin_baru':
        return Icons.admin_panel_settings_rounded;
      case 'profil':
        return Icons.location_city_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color get _color {
    switch (notif.type) {
      case 'pengaduan_baru':
      case 'pengaduan_update':
        return const Color(0xFFC62828);
      case 'surat_baru':
      case 'surat_update':
        return const Color(0xFF6A1B9A);
      case 'pembayaran_baru':
      case 'pembayaran_update':
        return const Color(0xFF2E7D32);
      case 'umkm_baru':
        return const Color(0xFFE65100);
      case 'pengumuman':
        return const Color(0xFFF57C00);
      case 'kegiatan':
        return const Color(0xFF1565C0);
      case 'galeri':
        return const Color(0xFF00695C);
      default:
        return AppColors.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notif.isReadBy(uid);
    return Material(
      color: isRead ? Colors.white : AppColors.lightGreen.withOpacity(0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.cardShadow(),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(_icon, color: _color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notif.title,
                        style: TextStyle(fontWeight: isRead ? FontWeight.w600 : FontWeight.w800, fontSize: 13.5)),
                    const SizedBox(height: 3),
                    Text(notif.body, style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey)),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('d MMM yyyy, HH:mm').format(notif.createdAt),
                      style: TextStyle(fontSize: 10.5, color: AppColors.textGrey.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(color: Color(0xFFFF6B6B), shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
