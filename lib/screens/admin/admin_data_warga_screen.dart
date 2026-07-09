import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/admin_auth_service.dart';

class AdminDataWargaScreen extends StatefulWidget {
  const AdminDataWargaScreen({super.key});

  @override
  State<AdminDataWargaScreen> createState() => _AdminDataWargaScreenState();
}

class _AdminDataWargaScreenState extends State<AdminDataWargaScreen> {
  final FirestoreService _db = FirestoreService();
  final AdminAuthService _adminAuth = AdminAuthService();
  String _query = '';

  void _showFormTambah() {
    final namaCtrl = TextEditingController();
    final nikCtrl = TextEditingController();
    final noHpCtrl = TextEditingController();
    final alamatCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool isSaving = false;
    bool showPassword = false;

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
                  const Text('Tambah Warga (Manual)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
                  const SizedBox(height: 4),
                  const Text('Admin membuat akun login awal untuk warga ini',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: namaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      filled: true, fillColor: AppColors.bgGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nikCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'NIK (16 digit)',
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
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Akun Login Warga', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkGreen)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true, fillColor: AppColors.bgGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password Awal (min. 6 karakter)',
                      filled: true, fillColor: AppColors.bgGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: Icon(showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
                        onPressed: () => setSheetState(() => showPassword = !showPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Beritahu email & password ini ke warga agar bisa login. Warga dapat mengganti password setelah login pertama.',
                    style: TextStyle(fontSize: 11, color: AppColors.textGrey, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (namaCtrl.text.trim().isEmpty ||
                                  nikCtrl.text.trim().isEmpty ||
                                  noHpCtrl.text.trim().isEmpty ||
                                  emailCtrl.text.trim().isEmpty ||
                                  passwordCtrl.text.trim().length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Lengkapi semua field. Password minimal 6 karakter.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              setSheetState(() => isSaving = true);
                              try {
                                await _adminAuth.buatAkunWargaBaru(
                                  email: emailCtrl.text.trim(),
                                  password: passwordCtrl.text.trim(),
                                  nama: namaCtrl.text.trim(),
                                  nik: nikCtrl.text.trim(),
                                  noHp: noHpCtrl.text.trim(),
                                  alamat: alamatCtrl.text.trim(),
                                );

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Akun warga berhasil dibuat'), backgroundColor: AppColors.primaryGreen),
                                  );
                                }
                              } catch (e) {
                                setSheetState(() => isSaving = false);
                                if (context.mounted) {
                                  String msg = 'Gagal membuat akun: $e';
                                  if (e.toString().contains('email-already-in-use')) {
                                    msg = 'Email ini sudah terdaftar';
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(msg), backgroundColor: Colors.red),
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
                          : const Text('Buat Akun Warga', style: TextStyle(fontWeight: FontWeight.w700)),
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
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari nama warga...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _db.streamSemuaWarga(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }
                var items = snapshot.data!;
                if (_query.isNotEmpty) {
                  items = items.where((u) => u.nama.toLowerCase().contains(_query) || u.nik.contains(_query)).toList();
                }
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Belum ada warga terdaftar', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final u = items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(color: AppColors.lightGreen, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                u.nama.isNotEmpty ? u.nama[0].toUpperCase() : '?',
                                style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.nama, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                                const SizedBox(height: 2),
                                Text('NIK: ${u.nik}', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                Text(u.noHp, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                if (u.alamat.isNotEmpty)
                                  Text(u.alamat, style: const TextStyle(fontSize: 11.5, color: AppColors.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
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
          ),
        ],
      ),
    );
  }
}
