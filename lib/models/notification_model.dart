// ============================================================
// lib/models/notification_model.dart
// Model notifikasi in-app (realtime lewat Firestore snapshot,
// TANPA Cloud Functions / FCM — 100% gratis di plan Spark).
//
// Koleksi Firestore: /notifications/{id}
//
// Konsep "audience" (siapa yang berhak melihat notifikasi ini):
//   - uid warga tertentu   -> hanya warga itu yang lihat
//   - 'admin'              -> SEMUA akun admin melihatnya
//   - 'all'                -> SEMUA user (admin + warga) melihatnya
//
// Query di NotificationService memakai array-contains-any dengan
// [myUid, myRole, 'all'], jadi satu dokumen bisa "ditembak" ke
// banyak audience sekaligus tanpa perlu banyak baris berbeda.
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;        // lihat daftar type di notification_service.dart
  final String? refId;      // id dokumen terkait (pengaduan/surat/dll), opsional
  final List<String> audience;
  final List<String> readBy;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.refId,
    required this.audience,
    required this.readBy,
    required this.createdAt,
  });

  bool isReadBy(String uid) => readBy.contains(uid);

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: doc.id,
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      type: d['type'] ?? 'info',
      refId: d['ref_id'],
      audience: List<String>.from(d['audience'] ?? const []),
      readBy: List<String>.from(d['read_by'] ?? const []),
      createdAt: d['created_at'] is Timestamp
          ? (d['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'type': type,
        'ref_id': refId,
        'audience': audience,
        'read_by': readBy,
        'created_at': Timestamp.fromDate(createdAt),
      };
}
