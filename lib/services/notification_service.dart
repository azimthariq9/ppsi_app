// ============================================================
// lib/services/notification_service.dart
// Notifikasi REALTIME in-app berbasis Firestore snapshot.
// Tidak pakai FCM/Cloud Functions -> gratis, tidak perlu plan
// Blaze, dan langsung update UI selama app terbuka (foreground),
// persis seperti stream lain di firestore_service.dart.
//
// Daftar `type` yang dipakai di seluruh app (untuk keperluan
// pemetaan ikon di UI, lihat notifikasi_screen.dart):
//   pengaduan_baru, pengaduan_update,
//   surat_baru, surat_update,
//   pembayaran_baru, pembayaran_update,
//   umkm_baru, pengumuman, kegiatan, galeri, profil, admin_baru
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Kirim satu notifikasi ke satu/banyak audience sekaligus.
  /// Contoh audience: [uidWarga], ['admin'], ['all'], [uidWarga, 'admin']
  Future<void> kirim({
    required String title,
    required String body,
    required String type,
    String? refId,
    required List<String> audience,
  }) async {
    if (audience.isEmpty) return;
    await _db.collection('notifications').add({
      'title': title,
      'body': body,
      'type': type,
      'ref_id': refId,
      'audience': audience,
      'read_by': <String>[],
      'created_at': Timestamp.now(),
    });
  }

  /// Stream semua notifikasi milik user ini: personal (uid),
  /// berdasar role ('admin'/'warga'), atau broadcast ('all').
  ///
  /// Hanya where(array-contains-any) di server TANPA orderBy
  /// -> tidak perlu composite index (konsisten dengan pola index
  /// -avoidance yang sudah dipakai di firestore_service.dart).
  /// Sorting terbaru-dulu dilakukan di client.
  Stream<List<NotificationModel>> streamNotifikasi({
    required String uid,
    required String role,
  }) {
    return _db
        .collection('notifications')
        .where('audience', arrayContainsAny: [uid, role, 'all'])
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(NotificationModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // batasi 100 notifikasi terbaru saja biar ringan
      return list.length > 100 ? list.sublist(0, 100) : list;
    });
  }

  /// Jumlah notifikasi belum dibaca (untuk badge lonceng).
  Stream<int> streamUnreadCount({required String uid, required String role}) {
    return streamNotifikasi(uid: uid, role: role)
        .map((list) => list.where((n) => !n.isReadBy(uid)).length);
  }

  Future<void> tandaiDibaca(String notifId, String uid) async {
    await _db.collection('notifications').doc(notifId).update({
      'read_by': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> tandaiSemuaDibaca(List<String> notifIds, String uid) async {
    if (notifIds.isEmpty) return;
    final batch = _db.batch();
    for (final id in notifIds) {
      batch.update(_db.collection('notifications').doc(id), {
        'read_by': FieldValue.arrayUnion([uid]),
      });
    }
    await batch.commit();
  }

  /// Label status yang enak dibaca warga (dipakai firestore_service.dart)
  static String labelStatus(String status) {
    switch (status) {
      case 'diproses':
        return 'Sedang Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      case 'diterima':
        return 'Diterima';
      case 'menunggu':
        return 'Menunggu';
      default:
        return status;
    }
  }
}
