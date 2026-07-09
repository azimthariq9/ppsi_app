// ============================================================
// lib/widgets/notification_bell.dart
// Icon lonceng notifikasi + badge angka unread, realtime.
// Pakai widget ini di actions AppBar mana pun (warga / admin).
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
import '../screens/notifikasi_screen.dart';

class NotificationBell extends StatelessWidget {
  final String role; // 'admin' atau 'warga'
  final Color iconColor;

  const NotificationBell({
    super.key,
    required this.role,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: NotificationService().streamUnreadCount(uid: uid, role: role),
      builder: (context, snapshot) {
        final unread = snapshot.data ?? 0;
        return IconButton(
          tooltip: 'Notifikasi',
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined, color: iconColor, size: 24),
              if (unread > 0)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B6B),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotifikasiScreen(role: role)),
            );
          },
        );
      },
    );
  }
}
