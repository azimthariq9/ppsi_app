import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class AdminUmkmScreen extends StatefulWidget {
  const AdminUmkmScreen({super.key});

  @override
  State<AdminUmkmScreen> createState() => _AdminUmkmScreenState();
}

class _AdminUmkmScreenState extends State<AdminUmkmScreen> {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  static const List<String> _kategoriList = ['Kuliner', 'Sembako', 'Jasa', 'Otomotif', 'Kerajinan', 'Fashion'];

  Future<void> _toggleAktif(UMKMModel item) async {
    await _db.updateUMKM(item.id, {'is_active': !item.isActive});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(item.isActive ? 'UMKM dinonaktifkan' : 'UMKM diaktifkan'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  Future<void> _hapus(String id) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus UMKM'),
        content: const Text('Apakah Anda yakin ingin menghapus UMKM ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (konfirmasi == true) {
      await _db.deleteUMKM(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('UMKM dihapus'), backgroundColor: AppColors.primaryGreen),
        );
      }
    }
  }

  void _showFormTambah() {
    final namaCtrl = TextEditingController();
    final deskripsiCtrl = TextEditingController();
    final alamatCtrl = TextEditingController();
    final noHpCtrl = TextEditingController();
    String kategori = 'Kuliner';
    PickedFile? foto;
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
                  const Text('Tambah UMKM (Manual)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
                  const SizedBox(height: 4),
                  const Text('Untuk warga yang didaftarkan langsung oleh admin',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final f = await _storage.pickImage();
                      if (f != null) setSheetState(() => foto = f);
                    },
                    child: Container(
                      height: 120,
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
                                  Text('Tambah Foto Usaha (opsional)', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12.5)),
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
                      labelText: 'Nama Usaha',
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
                    onChanged: (v) => setSheetState(() => kategori = v ?? 'Kuliner'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: deskripsiCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Usaha',
                      filled: true, fillColor: AppColors.bgGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: alamatCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      filled: true, fillColor: AppColors.bgGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noHpCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'No HP / WhatsApp',
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
                              if (namaCtrl.text.trim().isEmpty || alamatCtrl.text.trim().isEmpty || noHpCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mohon lengkapi semua field wajib'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              setSheetState(() => isSaving = true);
                              try {
                                final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                                final docId = await _db.createUMKMAndGetId(UMKMModel(
                                  id: '',
                                  pemilikId: adminUid,
                                  namaUmkm: namaCtrl.text.trim(),
                                  deskripsi: deskripsiCtrl.text.trim(),
                                  kategori: kategori,
                                  alamat: alamatCtrl.text.trim(),
                                  noHp: noHpCtrl.text.trim(),
                                  isActive: true,
                                  createdAt: DateTime.now(),
                                ));

                                if (foto != null) {
                                  final url = await _storage.uploadFotoUMKM(docId, foto!);
                                  await _db.updateUMKM(docId, {'foto_url': url});
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('UMKM berhasil ditambahkan'), backgroundColor: AppColors.primaryGreen),
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
                          : const Text('Tambah UMKM', style: TextStyle(fontWeight: FontWeight.w700)),
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
        onPressed: _showFormTambah,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: StreamBuilder<List<UMKMModel>>(
        stream: _db.streamUMKM(),
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
              child: Text('Belum ada UMKM terdaftar. Tekan + untuk menambah.', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
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
                    if (item.fotoUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(item.fotoUrl!, width: 56, height: 56, fit: BoxFit.cover),
                      )
                    else
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.store_rounded, color: AppColors.accentGreen),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(item.namaUmkm, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: item.isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.isActive ? 'Aktif' : 'Nonaktif',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: item.isActive ? AppColors.primaryGreen : const Color(0xFFC62828)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(item.kategori, style: const TextStyle(fontSize: 11.5, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(item.deskripsi, style: const TextStyle(fontSize: 12, color: AppColors.textGrey), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(item.noHp, style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _toggleAktif(item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(8)),
                                  child: Text(item.isActive ? 'Nonaktifkan' : 'Aktifkan',
                                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _hapus(item.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: const Color(0xFFC62828), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
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
