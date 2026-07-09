import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class AdminKegiatanScreen extends StatefulWidget {
  const AdminKegiatanScreen({super.key});

  @override
  State<AdminKegiatanScreen> createState() => _AdminKegiatanScreenState();
}

class _AdminKegiatanScreenState extends State<AdminKegiatanScreen> {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  String _formatTanggal(DateTime date) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }

  Future<void> _hapus(String id) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Kegiatan'),
        content: const Text('Apakah Anda yakin ingin menghapus kegiatan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (konfirmasi == true) {
      await _db.deleteKegiatan(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kegiatan dihapus'), backgroundColor: AppColors.primaryGreen),
        );
      }
    }
  }

  void _showForm({KegiatanModel? existing}) {
    final namaCtrl = TextEditingController(text: existing?.namaKegiatan ?? '');
    final deskripsiCtrl = TextEditingController(text: existing?.deskripsi ?? '');
    final jamCtrl = TextEditingController(text: existing?.jam ?? '');
    final lokasiCtrl = TextEditingController(text: existing?.lokasi ?? '');
    DateTime tanggal = existing?.tanggal ?? DateTime.now();
    PickedFile? fotoBaru;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Text(existing == null ? 'Tambah Kegiatan' : 'Edit Kegiatan',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final f = await _storage.pickImage();
                      if (f != null) setSheetState(() => fotoBaru = f);
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.bgGreen,
                        borderRadius: BorderRadius.circular(12),
                        image: fotoBaru != null
                            ? DecorationImage(image: MemoryImage(fotoBaru!.bytes), fit: BoxFit.cover)
                            : (existing?.gambarUrl != null
                                ? DecorationImage(image: NetworkImage(existing!.gambarUrl!), fit: BoxFit.cover)
                                : null),
                      ),
                      child: (fotoBaru == null && existing?.gambarUrl == null)
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, color: AppColors.primaryGreen, size: 28),
                                  SizedBox(height: 6),
                                  Text('Tambah Gambar (opsional)', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12.5)),
                                ],
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: namaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Kegiatan',
                      filled: true, fillColor: AppColors.bgGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tanggal,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setSheetState(() => tanggal = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(color: AppColors.bgGreen, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryGreen),
                          const SizedBox(width: 10),
                          Text(_formatTanggal(tanggal), style: const TextStyle(fontSize: 13.5, color: AppColors.textDark)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: jamCtrl,
                    decoration: InputDecoration(
                      labelText: 'Jam (contoh: 19:00)',
                      filled: true, fillColor: AppColors.bgGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lokasiCtrl,
                    decoration: InputDecoration(
                      labelText: 'Lokasi',
                      filled: true, fillColor: AppColors.bgGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: deskripsiCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      filled: true, fillColor: AppColors.bgGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (namaCtrl.text.trim().isEmpty || jamCtrl.text.trim().isEmpty || lokasiCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mohon lengkapi semua field'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              setSheetState(() => isSaving = true);
                              try {
                                String? gambarUrl = existing?.gambarUrl;
                                if (fotoBaru != null) {
                                  gambarUrl = await _storage.uploadGambarKegiatan(fotoBaru!);
                                }

                                if (existing == null) {
                                  await _db.createKegiatan(KegiatanModel(
                                    id: '',
                                    namaKegiatan: namaCtrl.text.trim(),
                                    deskripsi: deskripsiCtrl.text.trim(),
                                    tanggal: tanggal,
                                    jam: jamCtrl.text.trim(),
                                    lokasi: lokasiCtrl.text.trim(),
                                    gambarUrl: gambarUrl,
                                    createdById: '',
                                    createdAt: DateTime.now(),
                                  ));
                                } else {
                                  await _db.updateKegiatan(existing.id, {
                                    'nama_kegiatan': namaCtrl.text.trim(),
                                    'deskripsi': deskripsiCtrl.text.trim(),
                                    'tanggal': Timestamp.fromDate(tanggal),
                                    'jam': jamCtrl.text.trim(),
                                    'lokasi': lokasiCtrl.text.trim(),
                                    'gambar_url': gambarUrl,
                                  });
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(existing == null ? 'Kegiatan ditambahkan' : 'Kegiatan diperbarui'),
                                      backgroundColor: AppColors.primaryGreen,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setSheetState(() => isSaving = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(existing == null ? 'Tambah Kegiatan' : 'Simpan Perubahan', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: StreamBuilder<List<KegiatanModel>>(
        stream: _db.streamKegiatan(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Text('Belum ada kegiatan. Tekan + untuk menambah.', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.gambarUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(item.gambarUrl!, width: 56, height: 56, fit: BoxFit.cover),
                      )
                    else
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.event_rounded, color: AppColors.accentGreen),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.namaKegiatan, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          const SizedBox(height: 4),
                          Text('${_formatTanggal(item.tanggal)} · ${item.jam}', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                          Text(item.lokasi, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: AppColors.primaryGreen, size: 20),
                          onPressed: () => _showForm(existing: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Color(0xFFC62828), size: 20),
                          onPressed: () => _hapus(item.id),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
