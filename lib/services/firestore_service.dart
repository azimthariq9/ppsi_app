// ============================================================
// lib/services/firestore_service.dart
// CRUD lengkap untuk semua koleksi Firestore
//
// CATATAN PENTING soal index:
// Firestore mewajibkan composite index untuk query yang
// menggabungkan where() pada satu field + orderBy() pada field
// LAIN. Daripada wajib membuat index manual di Firebase Console
// untuk tiap kombinasi filter (dan index baru lagi tiap nambah
// fitur), strategi di sini adalah: query Firestore HANYA dengan
// where() (tanpa orderBy di server), lalu sorting dilakukan di
// sisi Dart/client setelah data diterima. Untuk skala data RT
// (puluhan-ratusan dokumen) ini cepat dan tidak butuh index sama
// sekali — gratis di plan Spark, tanpa setup tambahan.
//
// ============================================================
// PEMBARUAN: NOTIFIKASI REALTIME IN-APP
// Setiap alur kirim -> diterima admin -> diproses -> selesai,
// sekarang otomatis mengirim notifikasi (koleksi /notifications)
// ke pihak yang relevan (admin dan/atau warga pengirim).
// Tidak ada perubahan pada signature method2 yang sudah dipakai
// di layar2 lama, jadi TIDAK PERLU mengubah satupun file screen.
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notif = NotificationService();

  // ════════════════════════════════════════════════════════════════════════
  // USERS
  // ════════════════════════════════════════════════════════════════════════

  /// Simpan data user ke Firestore saat register
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  /// Update sebagian data profil user (nama, no HP, alamat, foto, dll)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  /// Ambil data user berdasarkan UID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Stream semua warga (untuk admin kelola warga)
  /// where() saja di server, sort terbaru-dulu dilakukan di client
  /// agar tidak memerlukan composite index.
  Stream<List<UserModel>> streamSemuaWarga() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'warga')
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(UserModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Stream semua admin (dipakai di layar "Kelola Admin")
  Stream<List<UserModel>> streamSemuaAdmin() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(UserModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ════════════════════════════════════════════════════════════════════════
  // PROFIL RT
  // ════════════════════════════════════════════════════════════════════════

  /// Ambil data profil RT (1 dokumen)
  Future<ProfilRTModel?> getProfilRT() async {
    final doc = await _db.collection('rt_info').doc('main').get();
    if (!doc.exists) return null;
    return ProfilRTModel.fromFirestore(doc);
  }

  /// Update data profil RT — hanya admin
  Future<void> updateProfilRT(Map<String, dynamic> data) async {
    await _db.collection('rt_info').doc('main').set(data, SetOptions(merge: true));
    await _notif.kirim(
      title: 'Profil RT Diperbarui',
      body: 'Admin memperbarui data profil RT/RW.',
      type: 'profil',
      audience: const ['all'],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // PENGUMUMAN
  // ════════════════════════════════════════════════════════════════════════

  /// Stream semua pengumuman (realtime, urut terbaru)
  /// Hanya orderBy() tanpa where() -> aman, tidak butuh index.
  Stream<List<PengumumanModel>> streamPengumuman() {
    return _db
        .collection('pengumuman')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PengumumanModel.fromFirestore).toList());
  }

  Future<void> createPengumuman(PengumumanModel p) async {
    final ref = await _db.collection('pengumuman').add(p.toMap());
    await _notif.kirim(
      title: 'Pengumuman Baru',
      body: p.judul,
      type: 'pengumuman',
      refId: ref.id,
      audience: const ['all'],
    );
  }

  Future<void> updatePengumuman(String id, Map<String, dynamic> data) async {
    await _db.collection('pengumuman').doc(id).update(data);
    await _notif.kirim(
      title: 'Pengumuman Diperbarui',
      body: data['judul'] != null
          ? 'Pengumuman "${data['judul']}" telah diperbarui.'
          : 'Ada pengumuman yang diperbarui admin.',
      type: 'pengumuman',
      refId: id,
      audience: const ['all'],
    );
  }

  Future<void> deletePengumuman(String id) async {
    await _db.collection('pengumuman').doc(id).delete();
  }

  // ════════════════════════════════════════════════════════════════════════
  // KEGIATAN
  // ════════════════════════════════════════════════════════════════════════

  /// Stream semua kegiatan (realtime) — hanya orderBy(), aman.
  Stream<List<KegiatanModel>> streamKegiatan() {
    return _db
        .collection('kegiatan')
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(KegiatanModel.fromFirestore).toList());
  }

  /// Kegiatan mendatang saja.
  /// where('tanggal', >=) + orderBy('tanggal') -> field SAMA,
  /// ini aman secara default di Firestore (tidak butuh composite index)
  /// karena where dan orderBy memakai field yang identik.
  Stream<List<KegiatanModel>> streamKegiatanMendatang() {
    return _db
        .collection('kegiatan')
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('tanggal')
        .limit(5)
        .snapshots()
        .map((snap) => snap.docs.map(KegiatanModel.fromFirestore).toList());
  }

  Future<void> createKegiatan(KegiatanModel k) async {
    final ref = await _db.collection('kegiatan').add(k.toMap());
    await _notif.kirim(
      title: 'Kegiatan Baru',
      body: '${k.namaKegiatan} — ${k.lokasi}',
      type: 'kegiatan',
      refId: ref.id,
      audience: const ['all'],
    );
  }

  Future<void> updateKegiatan(String id, Map<String, dynamic> data) async {
    await _db.collection('kegiatan').doc(id).update(data);
    await _notif.kirim(
      title: 'Kegiatan Diperbarui',
      body: data['nama_kegiatan'] != null
          ? 'Kegiatan "${data['nama_kegiatan']}" telah diperbarui.'
          : 'Ada kegiatan yang diperbarui admin.',
      type: 'kegiatan',
      refId: id,
      audience: const ['all'],
    );
  }

  Future<void> deleteKegiatan(String id) async {
    await _db.collection('kegiatan').doc(id).delete();
  }

  // ════════════════════════════════════════════════════════════════════════
  // PENGADUAN
  // ════════════════════════════════════════════════════════════════════════

  /// Stream pengaduan milik warga tertentu.
  /// where('user_id') saja di server, sort di client -> tanpa index.
  Stream<List<PengaduanModel>> streamPengaduanByUser(String userId) {
    return _db
        .collection('pengaduan')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(PengaduanModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Stream semua pengaduan (untuk admin).
  /// Tanpa filter -> orderBy aman. Dengan filter status -> where saja,
  /// sort dilakukan di client.
  Stream<List<PengaduanModel>> streamSemuaPengaduan({String? statusFilter}) {
    if (statusFilter == null) {
      return _db
          .collection('pengaduan')
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(PengaduanModel.fromFirestore).toList());
    }
    return _db
        .collection('pengaduan')
        .where('status', isEqualTo: statusFilter)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(PengaduanModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Warga kirim pengaduan -> notifikasi masuk ke SEMUA admin.
  Future<void> createPengaduan(PengaduanModel p) async {
    final ref = await _db.collection('pengaduan').add(p.toMap());
    await _notif.kirim(
      title: 'Pengaduan Baru',
      body: '${p.namaWarga} mengirim pengaduan: ${p.judul}',
      type: 'pengaduan_baru',
      refId: ref.id,
      audience: const ['admin'],
    );
  }

  /// Admin mengubah status pengaduan -> notifikasi masuk ke warga
  /// pemilik pengaduan (diproses / selesai / ditolak, dll).
  Future<void> updateStatusPengaduan(String id, String status, {String? catatan}) async {
    final ref = _db.collection('pengaduan').doc(id);
    final before = await ref.get();

    await ref.update({
      'status': status,
      if (catatan != null) 'catatan_admin': catatan,
      'updated_at': Timestamp.now(),
    });

    if (before.exists) {
      final d = before.data()!;
      final userId = d['user_id'] as String? ?? '';
      final judul = d['judul'] as String? ?? 'pengaduan kamu';
      if (userId.isNotEmpty) {
        await _notif.kirim(
          title: 'Status Pengaduan Diperbarui',
          body: 'Pengaduan "$judul" sekarang: ${NotificationService.labelStatus(status)}',
          type: 'pengaduan_update',
          refId: id,
          audience: [userId],
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // PERMOHONAN SURAT
  // ════════════════════════════════════════════════════════════════════════

  Stream<List<PermohonanSuratModel>> streamSuratByUser(String userId) {
    return _db
        .collection('permohonan_surat')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(PermohonanSuratModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<PermohonanSuratModel>> streamSemuaSurat({String? statusFilter}) {
    if (statusFilter == null) {
      return _db
          .collection('permohonan_surat')
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(PermohonanSuratModel.fromFirestore).toList());
    }
    return _db
        .collection('permohonan_surat')
        .where('status', isEqualTo: statusFilter)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(PermohonanSuratModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Warga ajukan surat -> notifikasi masuk ke SEMUA admin.
  Future<void> createPermohonanSurat(PermohonanSuratModel s) async {
    final ref = await _db.collection('permohonan_surat').add(s.toMap());
    await _notif.kirim(
      title: 'Permohonan Surat Baru',
      body: '${s.namaWarga} mengajukan surat ${s.jenisSurat}',
      type: 'surat_baru',
      refId: ref.id,
      audience: const ['admin'],
    );
  }

  /// Admin mengubah status surat -> notifikasi masuk ke warga pemohon.
  Future<void> updateStatusSurat(String id, String status, {String? catatan, String? fileUrl}) async {
    final ref = _db.collection('permohonan_surat').doc(id);
    final before = await ref.get();

    await ref.update({
      'status': status,
      if (catatan != null) 'catatan_admin': catatan,
      if (fileUrl != null) 'file_surat_url': fileUrl,
      'updated_at': Timestamp.now(),
    });

    if (before.exists) {
      final d = before.data()!;
      final userId = d['user_id'] as String? ?? '';
      final jenis = d['jenis_surat'] as String? ?? 'Surat';
      if (userId.isNotEmpty) {
        await _notif.kirim(
          title: 'Status Permohonan Surat Diperbarui',
          body: 'Permohonan surat $jenis sekarang: ${NotificationService.labelStatus(status)}'
              '${fileUrl != null ? ' — file surat sudah tersedia.' : ''}',
          type: 'surat_update',
          refId: id,
          audience: [userId],
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // PEMBAYARAN
  // ════════════════════════════════════════════════════════════════════════

  /// Stream riwayat pembayaran warga.
  /// where('user_id') saja di server, sort di client -> tanpa index.
  Stream<List<PembayaranModel>> streamPembayaranByUser(String userId) {
    return _db
        .collection('pembayaran')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(PembayaranModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Status pembayaran bulan ini.
  /// 3x where() pada field berbeda TANPA orderBy -> Firestore tidak
  /// memerlukan composite index untuk kombinasi where-only seperti ini
  /// (index otomatis/single-field sudah cukup).
  Future<PembayaranModel?> getPembayaranBulanIni(String userId, String bulan) async {
    final snap = await _db
        .collection('pembayaran')
        .where('user_id', isEqualTo: userId)
        .where('bulan', isEqualTo: bulan)
        .where('jenis_iuran', isEqualTo: 'Iuran Bulanan')
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return PembayaranModel.fromFirestore(snap.docs.first);
  }

  /// Stream semua pembayaran untuk admin.
  /// Filter via where() saja, sort & filter kedua dilakukan di client
  /// supaya tidak perlu composite index untuk tiap kombinasi filter.
  Stream<List<PembayaranModel>> streamSemuaPembayaran({String? statusFilter, String? bulanFilter}) {
    Query<Map<String, dynamic>> query = _db.collection('pembayaran');

    // Hanya terapkan SATU where() di server (yang paling selektif).
    // Filter kedua (jika ada) diterapkan di client setelah data diterima.
    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter);
    } else if (bulanFilter != null) {
      query = query.where('bulan', isEqualTo: bulanFilter);
    }

    return query.snapshots().map((snap) {
      var list = snap.docs.map(PembayaranModel.fromFirestore).toList();
      if (statusFilter != null && bulanFilter != null) {
        list = list.where((p) => p.bulan == bulanFilter).toList();
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Warga submit bukti bayar -> notifikasi masuk ke SEMUA admin.
  Future<void> createPembayaran(PembayaranModel p) async {
    final ref = await _db.collection('pembayaran').add(p.toMap());
    await _notif.kirim(
      title: 'Bukti Pembayaran Baru',
      body: '${p.namaWarga} mengirim bukti bayar ${p.jenisIuran} (${p.bulan})',
      type: 'pembayaran_baru',
      refId: ref.id,
      audience: const ['admin'],
    );
  }

  /// Admin verifikasi pembayaran -> notifikasi masuk ke warga.
  Future<void> verifikasiPembayaran(String id, String adminId) async {
    final ref = _db.collection('pembayaran').doc(id);
    final before = await ref.get();

    await ref.update({
      'status': 'lunas',
      'verified_by_id': adminId,
      'tanggal_bayar': Timestamp.now(),
    });

    if (before.exists) {
      final d = before.data()!;
      final userId = d['user_id'] as String? ?? '';
      final bulan = d['bulan'] as String? ?? '';
      if (userId.isNotEmpty) {
        await _notif.kirim(
          title: 'Pembayaran Terverifikasi',
          body: 'Pembayaran iuran bulan $bulan sudah diverifikasi & lunas. Terima kasih!',
          type: 'pembayaran_update',
          refId: id,
          audience: [userId],
        );
      }
    }
  }

  /// Admin tolak bukti pembayaran -> notifikasi masuk ke warga.
  Future<void> tolakPembayaran(String id) async {
    final ref = _db.collection('pembayaran').doc(id);
    final before = await ref.get();

    await ref.update({'status': 'belum'});

    if (before.exists) {
      final d = before.data()!;
      final userId = d['user_id'] as String? ?? '';
      final bulan = d['bulan'] as String? ?? '';
      if (userId.isNotEmpty) {
        await _notif.kirim(
          title: 'Bukti Pembayaran Ditolak',
          body: 'Bukti bayar iuran bulan $bulan ditolak admin. Silakan upload ulang bukti yang valid.',
          type: 'pembayaran_update',
          refId: id,
          audience: [userId],
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // GALERI
  // ════════════════════════════════════════════════════════════════════════

  Stream<List<GaleriModel>> streamGaleri() {
    return _db
        .collection('galeri')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(GaleriModel.fromFirestore).toList());
  }

  Future<void> createGaleri(GaleriModel g) async {
    final ref = await _db.collection('galeri').add(g.toMap());
    await _notif.kirim(
      title: 'Galeri Diperbarui',
      body: 'Foto baru ditambahkan: ${g.judul}',
      type: 'galeri',
      refId: ref.id,
      audience: const ['all'],
    );
  }

  Future<void> deleteGaleri(String id) async {
    await _db.collection('galeri').doc(id).delete();
  }

  // ════════════════════════════════════════════════════════════════════════
  // UMKM
  // ════════════════════════════════════════════════════════════════════════

  /// where('is_active') saja di server, sort terbaru-dulu di client
  /// -> tidak memerlukan composite index.
  Stream<List<UMKMModel>> streamUMKM() {
    return _db
        .collection('umkm')
        .where('is_active', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(UMKMModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<UMKMModel>> streamUMKMByOwner(String userId) {
    return _db
        .collection('umkm')
        .where('pemilik_id', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map(UMKMModel.fromFirestore).toList());
  }

  Future<void> createUMKM(UMKMModel u) async {
    await _db.collection('umkm').add(u.toMap());
    await _notif.kirim(
      title: 'UMKM Baru',
      body: '${u.namaUmkm} baru saja terdaftar di direktori UMKM.',
      type: 'umkm_baru',
      audience: const ['all'],
    );
  }

  /// Dipakai baik oleh ADMIN (admin_umkm_screen) maupun WARGA
  /// (umkm_screen) untuk mendaftarkan UMKM baru -> notifikasi
  /// masuk ke SEMUA user (admin & warga) sesuai permintaan.
  Future<String> createUMKMAndGetId(UMKMModel u) async {
    final docRef = await _db.collection('umkm').add(u.toMap());
    await _notif.kirim(
      title: 'UMKM Baru Ditambahkan',
      body: '${u.namaUmkm} baru saja terdaftar di direktori UMKM.',
      type: 'umkm_baru',
      refId: docRef.id,
      audience: const ['all'],
    );
    return docRef.id;
  }

  Future<void> updateUMKM(String id, Map<String, dynamic> data) async {
    await _db.collection('umkm').doc(id).update(data);
  }

  Future<void> deleteUMKM(String id) async {
    await _db.collection('umkm').doc(id).update({'is_active': false});
  }

  // ════════════════════════════════════════════════════════════════════════
  // RINGKASAN DASHBOARD (untuk home screen & admin dashboard)
  // ════════════════════════════════════════════════════════════════════════

  /// Semua count() di sini aman: tanpa orderBy, jadi tidak butuh
  /// composite index sama sekali.
  Future<Map<String, int>> getDashboardStats() async {
    final results = await Future.wait([
      _db.collection('pengumuman').count().get(),
      _db.collection('kegiatan').where('tanggal', isGreaterThan: Timestamp.now()).count().get(),
      _db.collection('umkm').where('is_active', isEqualTo: true).count().get(),
      _db.collection('pengaduan').where('status', isEqualTo: 'menunggu').count().get(),
    ]);

    return {
      'pengumuman': results[0].count ?? 0,
      'kegiatan': results[1].count ?? 0,
      'umkm': results[2].count ?? 0,
      'pengaduan_baru': results[3].count ?? 0,
    };
  }
}
