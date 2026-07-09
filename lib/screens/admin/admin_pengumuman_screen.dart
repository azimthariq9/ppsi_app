import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class AdminPengumumanScreen extends StatefulWidget {
  const AdminPengumumanScreen({super.key});

  @override
  State<AdminPengumumanScreen> createState() => _AdminPengumumanScreenState();
}

class _AdminPengumumanScreenState extends State<AdminPengumumanScreen> {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  static const List<String> _kategoriList = ['Informasi', 'Kegiatan', 'Kebijakan', 'Keuangan', 'Kesehatan'];

  String _formatTanggal(DateTime date) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }

  Future<void> _hapus(String id) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pengumuman'),
        content: const Text('Apakah Anda yakin ingin menghapus pengumuman ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (konfirmasi == true) {
      await _db.deletePengumuman(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengumuman dihapus'), backgroundColor: AppColors.primaryGreen),
        );
      }
    }
  }

  void _showForm({PengumumanModel? existing}) {
    final judulCtrl = TextEditingController(text: existing?.judul ?? '');
    final isiCtrl = TextEditingController(text: existing?.isi ?? '');
    String kategori = existing?.kategori ?? 'Informasi';
    PickedFile? fotoBaru;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
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
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 16),
                  Text(existing == null ? 'Tambah Pengumuman' : 'Edit Pengumuman',
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
                    controller: judulCtrl,
                    decoration: InputDecoration(
                      labelText: 'Judul',
                      filled: true, fillColor: AppColors.bgGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: kategori,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      filled: true, fillColor: AppColors.bgGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: _kategoriList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                    onChanged: (v) => setSheetState(() => kategori = v ?? 'Informasi'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: isiCtrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Isi Pengumuman',
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
                              if (judulCtrl.text.trim().isEmpty || isiCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Judul dan isi wajib diisi'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              setSheetState(() => isSaving = true);
                              try {
                                final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                                final adminUser = await _db.getUser(uid);

                                String? gambarUrl = existing?.gambarUrl;
                                if (fotoBaru != null) {
                                  gambarUrl = await _storage.uploadGambarPengumuman(fotoBaru!);
                                }

                                if (existing == null) {
                                  await _db.createPengumuman(PengumumanModel(
                                    id: '',
                                    judul: judulCtrl.text.trim(),
                                    isi: isiCtrl.text.trim(),
                                    kategori: kategori,
                                    gambarUrl: gambarUrl,
                                    createdById: uid,
                                    createdByNama: adminUser?.nama ?? 'Admin',
                                    createdAt: DateTime.now(),
                                  ));
                                } else {
                                  await _db.updatePengumuman(existing.id, {
                                    'judul': judulCtrl.text.trim(),
                                    'isi': isiCtrl.text.trim(),
                                    'kategori': kategori,
                                    'gambar_url': gambarUrl,
                                  });
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(existing == null ? 'Pengumuman ditambahkan' : 'Pengumuman diperbarui'),
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
                          : Text(existing == null ? 'Tambah Pengumuman' : 'Simpan Perubahan', style: const TextStyle(fontWeight: FontWeight.w700)),
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
      body: StreamBuilder<List<PengumumanModel>>(
        stream: _db.streamPengumuman(),
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
              child: Text('Belum ada pengumuman. Tekan + untuk menambah.', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(6)),
                            child: Text(item.kategori, style: const TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 8),
                          Text(item.judul, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          const SizedBox(height: 4),
                          Text(item.isi, style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Text(_formatTanggal(item.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
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
