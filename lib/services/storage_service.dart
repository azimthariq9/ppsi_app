// ============================================================
// lib/services/storage_service.dart
// Upload file (gambar & PDF) ke Cloudinary.
//
// Kenapa Cloudinary, bukan Firebase Storage?
// Sejak Februari 2026, Firebase Storage mewajibkan project ada
// di plan Blaze (berbayar) untuk akses bucket apa pun. Cloudinary
// punya free tier (25 kredit/bulan, ~25GB storage+bandwidth)
// yang cukup besar untuk skala aplikasi RT/RW dan tidak perlu
// kartu kredit sama sekali.
//
// Pendekatan: "unsigned upload" — upload langsung dari app
// Flutter ke Cloudinary tanpa server perantara, memakai
// upload preset yang sudah dikonfigurasi sebagai "Unsigned" di
// Cloudinary Console. API Secret TIDAK dibutuhkan di sisi app
// sama sekali untuk operasi upload.
//
// CROSS-PLATFORM (mobile + web):
// dart:io File TIDAK ADA di web (browser tidak punya filesystem
// asli), jadi semua file di sini direpresentasikan sebagai bytes
// (Uint8List) lewat wrapper PickedFile di bawah — ini bekerja
// identik di Android, iOS, maupun web tanpa kode bercabang
// per-platform.
// ============================================================

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../config/cloudinary_config.dart';

/// Representasi file yang sudah dipilih user, cross-platform.
/// Dipakai sebagai pengganti dart:io File supaya kode yang sama
/// bekerja di Android, iOS, dan Web.
class PickedFile {
  final Uint8List bytes;
  final String name;

  PickedFile({required this.bytes, required this.name});
}

class StorageService {
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  // ─── PILIH GAMBAR (dari galeri/kamera) ───────────────────────────────────

  Future<PickedFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 75, // Compress untuk hemat kuota Cloudinary
      maxWidth: 1080,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return PickedFile(bytes: bytes, name: picked.name);
  }

  // ─── PILIH FILE PDF ───────────────────────────────────────────────────────

  Future<PickedFile?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // wajib true agar 'bytes' terisi di web
    );
    if (result == null || result.files.single.bytes == null) return null;
    final picked = result.files.single;
    return PickedFile(bytes: picked.bytes!, name: picked.name);
  }

  // ─── UPLOAD GENERIK KE CLOUDINARY ────────────────────────────────────────
  // folder: nama folder tujuan di Cloudinary (mis. 'pengumuman', 'pengaduan/uid123')
  // publicId: nama file custom (opsional, kalau null Cloudinary generate random)

  Future<String> _uploadToCloudinary(
    PickedFile file, {
    required String folder,
    String? publicId,
  }) async {
    final uri = Uri.parse(CloudinaryConfig.uploadUrl);
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = folder;

    if (publicId != null) {
      request.fields['public_id'] = publicId;
    }

    request.files.add(
      http.MultipartFile.fromBytes('file', file.bytes, filename: file.name),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Upload ke Cloudinary gagal (${response.statusCode}): ${response.body}');
    }

    // Parsing manual tanpa dependency tambahan (dart:convert sudah built-in)
    final body = response.body;
    final match = RegExp(r'"secure_url"\s*:\s*"([^"]+)"').firstMatch(body);
    if (match == null) {
      throw Exception('Respons Cloudinary tidak mengandung secure_url: $body');
    }
    // Cloudinary mengembalikan URL dengan escape "\/" -> ganti jadi "/"
    return match.group(1)!.replaceAll(r'\/', '/');
  }

  // ─── UPLOAD FOTO PROFIL ──────────────────────────────────────────────────

  Future<String> uploadFotoProfil(String userId, PickedFile file) {
    return _uploadToCloudinary(file, folder: 'profil', publicId: userId);
  }

  // ─── UPLOAD GAMBAR PENGUMUMAN ────────────────────────────────────────────

  Future<String> uploadGambarPengumuman(PickedFile file) {
    return _uploadToCloudinary(file, folder: 'pengumuman', publicId: _uuid.v4());
  }

  // ─── UPLOAD GAMBAR KEGIATAN ──────────────────────────────────────────────

  Future<String> uploadGambarKegiatan(PickedFile file) {
    return _uploadToCloudinary(file, folder: 'kegiatan', publicId: _uuid.v4());
  }

  // ─── UPLOAD FOTO PENGADUAN ───────────────────────────────────────────────

  Future<String> uploadFotoPengaduan(String userId, PickedFile file) {
    return _uploadToCloudinary(file, folder: 'pengaduan/$userId', publicId: _uuid.v4());
  }

  // ─── UPLOAD BUKTI PEMBAYARAN ─────────────────────────────────────────────

  Future<String> uploadBuktiBayar(String userId, String bulan, PickedFile file) {
    return _uploadToCloudinary(file, folder: 'pembayaran/$userId', publicId: bulan);
  }

  /// Upload dengan progress callback.
  /// Catatan: Cloudinary REST API via http.MultipartRequest tidak
  /// mengekspos progress per-byte secara native seperti Firebase Storage.
  /// onProgress dipanggil 0.0 di awal dan 1.0 setelah selesai supaya
  /// UI yang sudah memakai progress indicator tetap berfungsi.
  Future<String> uploadBuktiBayarWithProgress(
    String userId,
    String bulan,
    PickedFile file, {
    Function(double)? onProgress,
  }) async {
    onProgress?.call(0.0);
    final url = await uploadBuktiBayar(userId, bulan, file);
    onProgress?.call(1.0);
    return url;
  }

  // ─── UPLOAD GAMBAR GALERI ────────────────────────────────────────────────

  Future<String> uploadGambarGaleri(PickedFile file) {
    return _uploadToCloudinary(file, folder: 'galeri', publicId: _uuid.v4());
  }

  // ─── UPLOAD FOTO UMKM ───────────────────────────────────────────────────

  Future<String> uploadFotoUMKM(String umkmId, PickedFile file) {
    return _uploadToCloudinary(file, folder: 'umkm', publicId: umkmId);
  }

  // ─── UPLOAD PDF — LAMPIRAN PERMOHONAN SURAT (oleh warga) ─────────────────

  Future<String> uploadLampiranSurat(String userId, PickedFile file) {
    return _uploadToCloudinary(file, folder: 'permohonan_surat/$userId', publicId: _uuid.v4());
  }

  // ─── UPLOAD PDF — SURAT BALASAN RESMI (oleh admin) ───────────────────────

  Future<String> uploadFileSuratJadi(String permohonanId, PickedFile file) {
    return _uploadToCloudinary(file, folder: 'surat_jadi', publicId: permohonanId);
  }

  // ─── HAPUS FILE ──────────────────────────────────────────────────────────
  // Catatan: menghapus asset di Cloudinary memerlukan request yang
  // di-sign dengan API Secret (signed request), yang TIDAK BOLEH
  // dilakukan dari kode client (app Flutter) demi keamanan.
  // Untuk skala aplikasi ini, asset lama dibiarkan tersimpan di
  // Cloudinary (free tier 25GB lebih dari cukup) daripada
  // mengekspos API Secret di client. Jika suatu saat perlu
  // penghapusan asset secara terprogram, itu harus lewat backend
  // terpisah (Cloud Function/server) yang menyimpan API Secret
  // dengan aman di sisi server.
  Future<void> deleteFile(String downloadUrl) async {
    // Sengaja tidak diimplementasikan di sisi client.
    // Lihat catatan di atas.
  }
}

