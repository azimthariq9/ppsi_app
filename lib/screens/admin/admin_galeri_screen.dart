import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class AdminGaleriScreen extends StatefulWidget {
  const AdminGaleriScreen({super.key});

  @override
  State<AdminGaleriScreen> createState() => _AdminGaleriScreenState();
}

class _AdminGaleriScreenState extends State<AdminGaleriScreen> {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  Future<void> _hapus(String id) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Foto'),
        content: const Text('Apakah Anda yakin ingin menghapus foto ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (konfirmasi == true) {
      await _db.deleteGaleri(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto dihapus'), backgroundColor: AppColors.primaryGreen),
        );
      }
    }
  }

  void _showForm() {
    final judulCtrl = TextEditingController();
    final deskripsiCtrl = TextEditingController();
    String kategori = 'Kegiatan';
    PickedFile? foto;
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
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  const Text('Tambah Foto Galeri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final f = await _storage.pickImage();
                      if (f != null) setSheetState(() => foto = f);
                    },
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.bgGreen,
                        borderRadius: BorderRadius.circular(12),
                        image: foto != null ? DecorationImage(image: MemoryImage(foto!.bytes), fit: BoxFit.cover) : null,
                      ),
                      child: foto == null
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, color: AppColors.primaryGreen, size: 28),
                                  SizedBox(height: 6),
                                  Text('Pilih Foto *', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12.5)),
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
                    items: ['Kegiatan', 'Lingkungan', 'Event', 'Lainnya'].map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                    onChanged: (v) => setSheetState(() => kategori = v ?? 'Kegiatan'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: deskripsiCtrl,
                    maxLines: 3,
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
                              if (foto == null || judulCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Foto dan judul wajib diisi'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              setSheetState(() => isSaving = true);
                              try {
                                final url = await _storage.uploadGambarGaleri(foto!);
                                await _db.createGaleri(GaleriModel(
                                  id: '',
                                  judul: judulCtrl.text.trim(),
                                  deskripsi: deskripsiCtrl.text.trim(),
                                  gambarUrl: url,
                                  kategori: kategori,
                                  createdById: '',
                                  createdAt: DateTime.now(),
                                ));
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Foto ditambahkan'), backgroundColor: AppColors.primaryGreen),
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
                          : const Text('Tambah Foto', style: TextStyle(fontWeight: FontWeight.w700)),
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
        onPressed: _showForm,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: StreamBuilder<List<GaleriModel>>(
        stream: _db.streamGaleri(),
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
              child: Text('Belum ada foto. Tekan + untuk menambah.', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                        child: Image.network(item.gambarUrl, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(item.judul,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          GestureDetector(
                            onTap: () => _hapus(item.id),
                            child: const Icon(Icons.delete_rounded, color: Color(0xFFC62828), size: 18),
                          ),
                        ],
                      ),
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
