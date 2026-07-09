import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/modern_app_bar.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class UMKMScreen extends StatefulWidget {
  const UMKMScreen({super.key});

  @override
  State<UMKMScreen> createState() => _UMKMScreenState();
}

class _UMKMScreenState extends State<UMKMScreen> {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  static const Map<String, IconData> _kategoriIcon = {
    'Kuliner': Icons.restaurant_rounded,
    'Sembako': Icons.shopping_basket_rounded,
    'Jasa': Icons.miscellaneous_services_rounded,
    'Otomotif': Icons.build_rounded,
    'Kerajinan': Icons.handyman_rounded,
    'Fashion': Icons.checkroom_rounded,
  };

  static const Map<String, Color> _kategoriColor = {
    'Kuliner': Color(0xFFFFF8F0),
    'Sembako': Color(0xFFF0FFF4),
    'Jasa': Color(0xFFF0F8FF),
    'Otomotif': Color(0xFFFFF0F0),
    'Kerajinan': Color(0xFFF5F0FF),
    'Fashion': Color(0xFFFFF0F8),
  };

  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  String _kategoriTerpilih = 'Kuliner';
  PickedFile? _fotoTerpilih;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    final file = await _storage.pickImage();
    if (file != null) setState(() => _fotoTerpilih = file);
  }

  Future<void> _submitDaftarUMKM() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (_namaController.text.trim().isEmpty ||
        _deskripsiController.text.trim().isEmpty ||
        _alamatController.text.trim().isEmpty ||
        _noHpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? fotoUrl;
      final docRef = await _db.createUMKMAndGetId(
        UMKMModel(
          id: '',
          pemilikId: uid,
          namaUmkm: _namaController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          kategori: _kategoriTerpilih,
          alamat: _alamatController.text.trim(),
          noHp: _noHpController.text.trim(),
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );

      if (_fotoTerpilih != null) {
        fotoUrl = await _storage.uploadFotoUMKM(docRef, _fotoTerpilih!);
        await _db.updateUMKM(docRef, {'foto_url': fotoUrl});
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('UMKM berhasil didaftarkan!'), backgroundColor: AppColors.primaryGreen),
      );
      _namaController.clear();
      _deskripsiController.clear();
      _alamatController.clear();
      _noHpController.clear();
      setState(() {
        _fotoTerpilih = null;
        _kategoriTerpilih = 'Kuliner';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendaftarkan UMKM: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showFormDaftar() {
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
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Daftarkan Usaha Anda',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      await _pilihFoto();
                      setSheetState(() {});
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.bgGreen,
                        borderRadius: BorderRadius.circular(12),
                        image: _fotoTerpilih != null
                            ? DecorationImage(image: MemoryImage(_fotoTerpilih!.bytes), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _fotoTerpilih == null
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, color: AppColors.primaryGreen, size: 28),
                                  SizedBox(height: 6),
                                  Text('Tambah Foto Usaha', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12.5)),
                                ],
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _formField('Nama Usaha', _namaController),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _kategoriTerpilih,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      filled: true,
                      fillColor: AppColors.bgGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: _kategoriIcon.keys
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) => setSheetState(() => _kategoriTerpilih = v ?? 'Kuliner'),
                  ),
                  const SizedBox(height: 12),
                  _formField('Deskripsi Usaha', _deskripsiController, maxLines: 3),
                  const SizedBox(height: 12),
                  _formField('Alamat', _alamatController, maxLines: 2),
                  const SizedBox(height: 12),
                  _formField('No HP / WhatsApp', _noHpController),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              setSheetState(() {});
                              await _submitDaftarUMKM();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Daftar Sekarang', style: TextStyle(fontWeight: FontWeight.w700)),
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

  Widget _formField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.bgGreen,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: ModernAppBar(title: 'UMKM'),
      drawer: const AppDrawer(currentRoute: '/umkm'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              color: AppColors.primaryGreen,
              child: const Column(
                children: [
                  Icon(Icons.storefront_rounded, color: Colors.white, size: 36),
                  SizedBox(height: 8),
                  Text(
                    'UMKM RT 03 RW 011',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Dukung pelaku usaha lokal di lingkungan kita',
                    style: TextStyle(color: Color(0xFFB7E4C7), fontSize: 12.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  StreamBuilder<List<UMKMModel>>(
                    stream: _db.streamUMKM(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Terjadi kesalahan: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: CircularProgressIndicator(color: AppColors.primaryGreen),
                        );
                      }
                      final items = snapshot.data!;
                      if (items.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('Belum ada UMKM terdaftar', style: TextStyle(color: AppColors.textGrey)),
                        );
                      }
                      return Column(
                        children: items.map((item) => _buildUMKMCard(item)).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // CTA - Daftarkan UMKM
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primaryGreen, AppColors.darkGreen], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.add_business_rounded, color: Colors.white, size: 32),
                        const SizedBox(height: 8),
                        const Text('Daftarkan Usaha Anda', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        const Text(
                          'Punya usaha di RT 003/011? Daftarkan dan promosikan usaha Anda kepada warga.',
                          style: TextStyle(color: Color(0xFFB7E4C7), fontSize: 12, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: _showFormDaftar,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: const Text('Daftar Sekarang', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUMKMCard(UMKMModel item) {
    final icon = _kategoriIcon[item.kategori] ?? Icons.store_rounded;
    final color = _kategoriColor[item.kategori] ?? AppColors.bgGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
              image: item.fotoUrl != null
                  ? DecorationImage(image: NetworkImage(item.fotoUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: item.fotoUrl == null
                ? Center(child: Icon(icon, size: 44, color: AppColors.accentGreen))
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.namaUmkm, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(6)),
                      child: Text(item.kategori, style: const TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item.deskripsi, style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey, height: 1.5)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.phone_rounded, size: 13, color: AppColors.accentGreen),
                    const SizedBox(width: 6),
                    Text(item.noHp, style: const TextStyle(fontSize: 12.5, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
