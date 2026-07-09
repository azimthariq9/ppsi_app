import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  UserModel? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  PickedFile? _fotoBaru;

  final _namaCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _noHpCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfil() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final user = await _db.getUser(uid);
    if (mounted) {
      setState(() {
        _user = user;
        _namaCtrl.text = user?.nama ?? '';
        _noHpCtrl.text = user?.noHp ?? '';
        _alamatCtrl.text = user?.alamat ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _pilihFoto() async {
    final file = await _storage.pickImage();
    if (file != null) setState(() => _fotoBaru = file);
  }

  Future<void> _simpanProfil() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _user == null) return;

    if (_namaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? fotoUrl = _user!.fotoUrl;
      if (_fotoBaru != null) {
        fotoUrl = await _storage.uploadFotoProfil(uid, _fotoBaru!);
      }

      await _db.updateUser(uid, {
        'nama': _namaCtrl.text.trim(),
        'no_hp': _noHpCtrl.text.trim(),
        'alamat': _alamatCtrl.text.trim(),
        'foto_url': fotoUrl,
      });

      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _fotoBaru = null;
      });
      await _loadProfil();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: AppColors.primaryGreen),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (konfirmasi != true) return;

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgGreen,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  if (_isEditing) _buildEditActions() else _buildMenuActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Profil Saya',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    if (!_isEditing)
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Colors.white),
                        onPressed: () => setState(() => _isEditing = true),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
                        image: _fotoBaru != null
                            ? DecorationImage(image: MemoryImage(_fotoBaru!.bytes), fit: BoxFit.cover)
                            : (_user?.fotoUrl != null
                                ? DecorationImage(image: NetworkImage(_user!.fotoUrl!), fit: BoxFit.cover)
                                : null),
                      ),
                      child: (_fotoBaru == null && _user?.fotoUrl == null)
                          ? Center(
                              child: Text(
                                _user != null && _user!.nama.isNotEmpty ? _user!.nama[0].toUpperCase() : '?',
                                style: const TextStyle(color: AppColors.primaryGreen, fontSize: 36, fontWeight: FontWeight.w800),
                              ),
                            )
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pilihFoto,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(_user?.nama ?? '-',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _user?.isAdmin == true ? 'Admin RT' : 'Warga RT 03/011',
                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── INFO CARD ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Pribadi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
          const SizedBox(height: 16),
          _isEditing
              ? Column(
                  children: [
                    _editField('Nama Lengkap', _namaCtrl, Icons.person_rounded),
                    const SizedBox(height: 12),
                    _editField('No HP / WhatsApp', _noHpCtrl, Icons.phone_rounded, keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _editField('Alamat', _alamatCtrl, Icons.home_rounded, maxLines: 2),
                  ],
                )
              : Column(
                  children: [
                    _infoRow(Icons.badge_rounded, 'NIK', _user?.nik ?? '-'),
                    const Divider(height: 24),
                    _infoRow(Icons.email_rounded, 'Email', _user?.email ?? '-'),
                    const Divider(height: 24),
                    _infoRow(Icons.phone_rounded, 'No HP', _user?.noHp.isNotEmpty == true ? _user!.noHp : '-'),
                    const Divider(height: 24),
                    _infoRow(Icons.home_rounded, 'Alamat', _user?.alamat.isNotEmpty == true ? _user!.alamat : '-'),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: AppColors.bgGreen, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primaryGreen, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textGrey)),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editField(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
        filled: true,
        fillColor: AppColors.bgGreen,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  // ── ACTIONS ───────────────────────────────────────────────────────────────

  Widget _buildEditActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving
                ? null
                : () => setState(() {
                      _isEditing = false;
                      _fotoBaru = null;
                      _namaCtrl.text = _user?.nama ?? '';
                      _noHpCtrl.text = _user?.noHp ?? '';
                      _alamatCtrl.text = _user?.alamat ?? '';
                    }),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Batal', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _simpanProfil,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow(),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.bgGreen, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFC62828), size: 18),
            ),
            title: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
