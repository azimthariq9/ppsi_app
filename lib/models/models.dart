// ============================================================
// lib/models/models.dart
// Semua model data yang merepresentasikan koleksi Firestore
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Parsing integer yang aman dari Firestore.
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Parsing angka desimal yang aman dari Firestore.
double? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Parsing tanggal yang aman dari Firestore.
/// Menangani Timestamp (format normal), String (data lama/manual),
/// dan null tanpa membuat app crash.
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// USER MODEL
// Koleksi Firestore: /users/{uid}
// ─────────────────────────────────────────────────────────────────────────────
class UserModel {
  final String id;         // = Firebase Auth UID
  final String nama;
  final String nik;        // 16 digit
  final String email;
  final String noHp;
  final String role;       // 'admin' | 'warga'
  final String alamat;
  final String? fotoUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.nama,
    required this.nik,
    required this.email,
    required this.noHp,
    required this.role,
    required this.alamat,
    this.fotoUrl,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      nama: d['nama'] ?? '',
      nik: d['nik'] ?? '',
      email: d['email'] ?? '',
      noHp: d['no_hp'] ?? '',
      role: d['role'] ?? 'warga',
      alamat: d['alamat'] ?? '',
      fotoUrl: d['foto_url'],
      createdAt: _parseDate(d['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'nama': nama,
    'nik': nik,
    'email': email,
    'no_hp': noHp,
    'role': role,
    'alamat': alamat,
    'foto_url': fotoUrl,
    'created_at': Timestamp.fromDate(createdAt),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// PENGUMUMAN MODEL
// Koleksi Firestore: /pengumuman/{id}
// ─────────────────────────────────────────────────────────────────────────────
class PengumumanModel {
  final String id;
  final String judul;
  final String isi;
  final String kategori;   // 'Informasi' | 'Kegiatan' | 'Kebijakan' | 'Keuangan' | 'Kesehatan'
  final String? gambarUrl;
  final String createdById;
  final String createdByNama;
  final DateTime createdAt;

  PengumumanModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    this.gambarUrl,
    required this.createdById,
    required this.createdByNama,
    required this.createdAt,
  });

  factory PengumumanModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PengumumanModel(
      id: doc.id,
      judul: d['judul'] ?? '',
      isi: d['isi'] ?? '',
      kategori: d['kategori'] ?? 'Informasi',
      gambarUrl: d['gambar_url'],
      createdById: d['created_by_id'] ?? '',
      createdByNama: d['created_by_nama'] ?? '',
      createdAt: _parseDate(d['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'judul': judul,
    'isi': isi,
    'kategori': kategori,
    'gambar_url': gambarUrl,
    'created_by_id': createdById,
    'created_by_nama': createdByNama,
    'created_at': Timestamp.fromDate(createdAt),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// KEGIATAN MODEL
// Koleksi Firestore: /kegiatan/{id}
// ─────────────────────────────────────────────────────────────────────────────
class KegiatanModel {
  final String id;
  final String namaKegiatan;
  final String deskripsi;
  final DateTime tanggal;
  final String jam;
  final String lokasi;
  final String? gambarUrl;
  final String createdById;
  final DateTime createdAt;

  KegiatanModel({
    required this.id,
    required this.namaKegiatan,
    required this.deskripsi,
    required this.tanggal,
    required this.jam,
    required this.lokasi,
    this.gambarUrl,
    required this.createdById,
    required this.createdAt,
  });

  factory KegiatanModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return KegiatanModel(
      id: doc.id,
      namaKegiatan: d['nama_kegiatan'] ?? '',
      deskripsi: d['deskripsi'] ?? '',
      tanggal: _parseDate(d['tanggal']) ?? DateTime.now(),
      jam: d['jam'] ?? '',
      lokasi: d['lokasi'] ?? '',
      gambarUrl: d['gambar_url'],
      createdById: d['created_by_id'] ?? '',
      createdAt: _parseDate(d['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'nama_kegiatan': namaKegiatan,
    'deskripsi': deskripsi,
    'tanggal': Timestamp.fromDate(tanggal),
    'jam': jam,
    'lokasi': lokasi,
    'gambar_url': gambarUrl,
    'created_by_id': createdById,
    'created_at': Timestamp.fromDate(createdAt),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// PENGADUAN MODEL
// Koleksi Firestore: /pengaduan/{id}
// ─────────────────────────────────────────────────────────────────────────────
class PengaduanModel {
  final String id;
  final String userId;
  final String namaWarga;
  final String judul;
  final String isiPengaduan;
  final String? fotoUrl;
  final String status;     // 'menunggu' | 'diproses' | 'selesai' | 'ditolak'
  final String? catatanAdmin;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PengaduanModel({
    required this.id,
    required this.userId,
    required this.namaWarga,
    required this.judul,
    required this.isiPengaduan,
    this.fotoUrl,
    required this.status,
    this.catatanAdmin,
    required this.createdAt,
    this.updatedAt,
  });

  factory PengaduanModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PengaduanModel(
      id: doc.id,
      userId: d['user_id'] ?? '',
      namaWarga: d['nama_warga'] ?? '',
      judul: d['judul'] ?? '',
      isiPengaduan: d['isi_pengaduan'] ?? '',
      fotoUrl: d['foto_url'],
      status: d['status'] ?? 'menunggu',
      catatanAdmin: d['catatan_admin'],
      createdAt: _parseDate(d['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(d['updated_at']),
    );
  }

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'nama_warga': namaWarga,
    'judul': judul,
    'isi_pengaduan': isiPengaduan,
    'foto_url': fotoUrl,
    'status': status,
    'catatan_admin': catatanAdmin,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// PERMOHONAN SURAT MODEL
// Koleksi Firestore: /permohonan_surat/{id}
// ─────────────────────────────────────────────────────────────────────────────
class PermohonanSuratModel {
  final String id;
  final String userId;
  final String namaWarga;
  final String nik;
  final String jenisSurat;  // 'Domisili' | 'Usaha' | 'Keterangan Tidak Mampu' | dll
  final String keperluan;
  final String status;      // 'menunggu' | 'diterima' | 'ditolak' | 'selesai'
  final String? lampiranUrl;   // PDF lampiran dari warga (opsional)
  final String? fileSuratUrl;  // PDF surat balasan resmi dari admin
  final String? catatanAdmin;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PermohonanSuratModel({
    required this.id,
    required this.userId,
    required this.namaWarga,
    required this.nik,
    required this.jenisSurat,
    required this.keperluan,
    required this.status,
    this.lampiranUrl,
    this.fileSuratUrl,
    this.catatanAdmin,
    required this.createdAt,
    this.updatedAt,
  });

  factory PermohonanSuratModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PermohonanSuratModel(
      id: doc.id,
      userId: d['user_id'] ?? '',
      namaWarga: d['nama_warga'] ?? '',
      nik: d['nik'] ?? '',
      jenisSurat: d['jenis_surat'] ?? '',
      keperluan: d['keperluan'] ?? '',
      status: d['status'] ?? 'menunggu',
      lampiranUrl: d['lampiran_url'],
      fileSuratUrl: d['file_surat_url'],
      catatanAdmin: d['catatan_admin'],
      createdAt: _parseDate(d['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(d['updated_at']),
    );
  }

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'nama_warga': namaWarga,
    'nik': nik,
    'jenis_surat': jenisSurat,
    'keperluan': keperluan,
    'status': status,
    'lampiran_url': lampiranUrl,
    'file_surat_url': fileSuratUrl,
    'catatan_admin': catatanAdmin,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// PEMBAYARAN MODEL
// Koleksi Firestore: /pembayaran/{id}
// ─────────────────────────────────────────────────────────────────────────────
class PembayaranModel {
  final String id;
  final String userId;
  final String namaWarga;
  final String jenisIuran;  // 'Iuran Bulanan' | 'Keamanan' | 'Kebersihan' | dll
  final double nominal;
  final String bulan;       // Format: '2026-05' (YYYY-MM)
  final String status;      // 'lunas' | 'belum' | 'menunggu_verifikasi'
  final String metodeBayar; // 'QRIS' | 'Transfer' | 'Tunai'
  final String? buktiBayarUrl;
  final DateTime? tanggalBayar;
  final String? verifiedById;
  final DateTime createdAt;

  PembayaranModel({
    required this.id,
    required this.userId,
    required this.namaWarga,
    required this.jenisIuran,
    required this.nominal,
    required this.bulan,
    required this.status,
    required this.metodeBayar,
    this.buktiBayarUrl,
    this.tanggalBayar,
    this.verifiedById,
    required this.createdAt,
  });

  factory PembayaranModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PembayaranModel(
      id: doc.id,
      userId: d['user_id'] ?? '',
      namaWarga: d['nama_warga'] ?? '',
      jenisIuran: d['jenis_iuran'] ?? 'Iuran Bulanan',
      nominal: _parseNum(d['nominal']) ?? 0.0,
      bulan: d['bulan'] ?? '',
      status: d['status'] ?? 'belum',
      metodeBayar: d['metode_bayar'] ?? 'QRIS',
      buktiBayarUrl: d['bukti_bayar_url'],
      tanggalBayar: _parseDate(d['tanggal_bayar']),
      verifiedById: d['verified_by_id'],
      createdAt: _parseDate(d['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'nama_warga': namaWarga,
    'jenis_iuran': jenisIuran,
    'nominal': nominal,
    'bulan': bulan,
    'status': status,
    'metode_bayar': metodeBayar,
    'bukti_bayar_url': buktiBayarUrl,
    'tanggal_bayar': tanggalBayar != null ? Timestamp.fromDate(tanggalBayar!) : null,
    'verified_by_id': verifiedById,
    'created_at': Timestamp.fromDate(createdAt),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// GALERI MODEL
// Koleksi Firestore: /galeri/{id}
// ─────────────────────────────────────────────────────────────────────────────
class GaleriModel {
  final String id;
  final String judul;
  final String deskripsi;
  final String gambarUrl;
  final String kategori;   // 'Kegiatan' | 'Lingkungan' | 'Event' | dll
  final String createdById;
  final DateTime createdAt;

  GaleriModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.gambarUrl,
    required this.kategori,
    required this.createdById,
    required this.createdAt,
  });

  factory GaleriModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GaleriModel(
      id: doc.id,
      judul: d['judul'] ?? '',
      deskripsi: d['deskripsi'] ?? '',
      gambarUrl: d['gambar_url'] ?? '',
      kategori: d['kategori'] ?? 'Kegiatan',
      createdById: d['created_by_id'] ?? '',
      createdAt: _parseDate(d['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'judul': judul,
    'deskripsi': deskripsi,
    'gambar_url': gambarUrl,
    'kategori': kategori,
    'created_by_id': createdById,
    'created_at': Timestamp.fromDate(createdAt),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// UMKM MODEL
// Koleksi Firestore: /umkm/{id}
// ─────────────────────────────────────────────────────────────────────────────
class UMKMModel {
  final String id;
  final String pemilikId;
  final String namaUmkm;
  final String deskripsi;
  final String kategori;   // 'Kuliner' | 'Kerajinan' | 'Jasa' | 'Fashion' | dll
  final String alamat;
  final String noHp;
  final String? fotoUrl;
  final bool isActive;
  final DateTime createdAt;

  UMKMModel({
    required this.id,
    required this.pemilikId,
    required this.namaUmkm,
    required this.deskripsi,
    required this.kategori,
    required this.alamat,
    required this.noHp,
    this.fotoUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory UMKMModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UMKMModel(
      id: doc.id,
      pemilikId: d['pemilik_id'] ?? '',
      namaUmkm: d['nama_umkm'] ?? '',
      deskripsi: d['deskripsi'] ?? '',
      kategori: d['kategori'] ?? 'Kuliner',
      alamat: d['alamat'] ?? '',
      noHp: d['no_hp'] ?? '',
      fotoUrl: d['foto_url'],
      isActive: d['is_active'] ?? true,
      createdAt: _parseDate(d['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'pemilik_id': pemilikId,
    'nama_umkm': namaUmkm,
    'deskripsi': deskripsi,
    'kategori': kategori,
    'alamat': alamat,
    'no_hp': noHp,
    'foto_url': fotoUrl,
    'is_active': isActive,
    'created_at': Timestamp.fromDate(createdAt),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// PROFIL RT MODEL
// Dokumen Firestore: /rt_info/main  (1 dokumen saja)
// ─────────────────────────────────────────────────────────────────────────────
class ProfilRTModel {
  final String namaRT;
  final String namaRW;
  final String kelurahan;
  final String kecamatan;
  final String kota;
  final String kodePos;
  final String namaKetua;
  final String namaWakilKetua;
  final String namaSekretaris;
  final String namaBendahara;
  final String noHpKetua;
  final int jumlahKK;
  final int jumlahPria;
  final int jumlahWanita;
  final int jumlahBalita;
  final int jumlahAnakSekolah;
  final String visi;
  final String misi;

  ProfilRTModel({
    required this.namaRT,
    required this.namaRW,
    required this.kelurahan,
    required this.kecamatan,
    required this.kota,
    required this.kodePos,
    required this.namaKetua,
    required this.namaWakilKetua,
    required this.namaSekretaris,
    required this.namaBendahara,
    required this.noHpKetua,
    required this.jumlahKK,
    required this.jumlahPria,
    required this.jumlahWanita,
    required this.jumlahBalita,
    required this.jumlahAnakSekolah,
    required this.visi,
    required this.misi,
  });

  factory ProfilRTModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProfilRTModel(
      namaRT: d['nama_rt'] ?? 'RT 03',
      namaRW: d['nama_rw'] ?? 'RW 011',
      kelurahan: d['kelurahan'] ?? 'Aren Jaya',
      kecamatan: d['kecamatan'] ?? 'Bekasi Timur',
      kota: d['kota'] ?? 'Kota Bekasi',
      kodePos: d['kode_pos'] ?? '17111',
      namaKetua: d['nama_ketua'] ?? '',
      namaWakilKetua: d['nama_wakil_ketua'] ?? '',
      namaSekretaris: d['nama_sekretaris'] ?? '',
      namaBendahara: d['nama_bendahara'] ?? '',
      noHpKetua: d['no_hp_ketua'] ?? '',
      jumlahKK: _parseInt(d['jumlah_kk']) ?? 0,
      jumlahPria: _parseInt(d['jumlah_pria']) ?? 0,
      jumlahWanita: _parseInt(d['jumlah_wanita']) ?? 0,
      jumlahBalita: _parseInt(d['jumlah_balita']) ?? 0,
      jumlahAnakSekolah: _parseInt(d['jumlah_anak_sekolah']) ?? 0,
      visi: d['visi'] ?? '',
      misi: d['misi'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'nama_rt': namaRT,
    'nama_rw': namaRW,
    'kelurahan': kelurahan,
    'kecamatan': kecamatan,
    'kota': kota,
    'kode_pos': kodePos,
    'nama_ketua': namaKetua,
    'nama_wakil_ketua': namaWakilKetua,
    'nama_sekretaris': namaSekretaris,
    'nama_bendahara': namaBendahara,
    'no_hp_ketua': noHpKetua,
    'jumlah_kk': jumlahKK,
    'jumlah_pria': jumlahPria,
    'jumlah_wanita': jumlahWanita,
    'jumlah_balita': jumlahBalita,
    'jumlah_anak_sekolah': jumlahAnakSekolah,
    'visi': visi,
    'misi': misi,
  };
}
