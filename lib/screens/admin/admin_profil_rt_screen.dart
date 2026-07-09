import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';

class AdminProfilRtScreen extends StatefulWidget {
  const AdminProfilRtScreen({super.key});

  @override
  State<AdminProfilRtScreen> createState() => _AdminProfilRtScreenState();
}

class _AdminProfilRtScreenState extends State<AdminProfilRtScreen> {
  final FirestoreService _db = FirestoreService();

  final _namaRTCtrl = TextEditingController();
  final _namaRWCtrl = TextEditingController();
  final _kelurahanCtrl = TextEditingController();
  final _kecamatanCtrl = TextEditingController();
  final _kotaCtrl = TextEditingController();
  final _kodePosCtrl = TextEditingController();
  final _namaKetuaCtrl = TextEditingController();
  final _namaWakilKetuaCtrl = TextEditingController();
  final _namaSekretarisCtrl = TextEditingController();
  final _namaBendaharaCtrl = TextEditingController();
  final _noHpKetuaCtrl = TextEditingController();
  final _jumlahKKCtrl = TextEditingController();
  final _jumlahPriaCtrl = TextEditingController();
  final _jumlahWanitaCtrl = TextEditingController();
  final _jumlahBalitaCtrl = TextEditingController();
  final _jumlahAnakSekolahCtrl = TextEditingController();
  final _visiCtrl = TextEditingController();
  final _misiCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profil = await _db.getProfilRT();
    if (profil != null) {
      _namaRTCtrl.text = profil.namaRT;
      _namaRWCtrl.text = profil.namaRW;
      _kelurahanCtrl.text = profil.kelurahan;
      _kecamatanCtrl.text = profil.kecamatan;
      _kotaCtrl.text = profil.kota;
      _kodePosCtrl.text = profil.kodePos;
      _namaKetuaCtrl.text = profil.namaKetua;
      _namaWakilKetuaCtrl.text = profil.namaWakilKetua;
      _namaSekretarisCtrl.text = profil.namaSekretaris;
      _namaBendaharaCtrl.text = profil.namaBendahara;
      _noHpKetuaCtrl.text = profil.noHpKetua;
      _jumlahKKCtrl.text = profil.jumlahKK.toString();
      _jumlahPriaCtrl.text = profil.jumlahPria.toString();
      _jumlahWanitaCtrl.text = profil.jumlahWanita.toString();
      _jumlahBalitaCtrl.text = profil.jumlahBalita.toString();
      _jumlahAnakSekolahCtrl.text = profil.jumlahAnakSekolah.toString();
      _visiCtrl.text = profil.visi;
      _misiCtrl.text = profil.misi;
    } else {
      _namaRTCtrl.text = 'RT 03';
      _namaRWCtrl.text = 'RW 011';
      _kelurahanCtrl.text = 'Aren Jaya';
      _kecamatanCtrl.text = 'Bekasi Timur';
      _kotaCtrl.text = 'Kota Bekasi';
      _kodePosCtrl.text = '17111';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _namaRTCtrl.dispose();
    _namaRWCtrl.dispose();
    _kelurahanCtrl.dispose();
    _kecamatanCtrl.dispose();
    _kotaCtrl.dispose();
    _kodePosCtrl.dispose();
    _namaKetuaCtrl.dispose();
    _namaWakilKetuaCtrl.dispose();
    _namaSekretarisCtrl.dispose();
    _namaBendaharaCtrl.dispose();
    _noHpKetuaCtrl.dispose();
    _jumlahKKCtrl.dispose();
    _jumlahPriaCtrl.dispose();
    _jumlahWanitaCtrl.dispose();
    _jumlahBalitaCtrl.dispose();
    _jumlahAnakSekolahCtrl.dispose();
    _visiCtrl.dispose();
    _misiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    setState(() => _isSaving = true);
    try {
      final data = ProfilRTModel(
        namaRT: _namaRTCtrl.text.trim(),
        namaRW: _namaRWCtrl.text.trim(),
        kelurahan: _kelurahanCtrl.text.trim(),
        kecamatan: _kecamatanCtrl.text.trim(),
        kota: _kotaCtrl.text.trim(),
        kodePos: _kodePosCtrl.text.trim(),
        namaKetua: _namaKetuaCtrl.text.trim(),
        namaWakilKetua: _namaWakilKetuaCtrl.text.trim(),
        namaSekretaris: _namaSekretarisCtrl.text.trim(),
        namaBendahara: _namaBendaharaCtrl.text.trim(),
        noHpKetua: _noHpKetuaCtrl.text.trim(),
        jumlahKK: int.tryParse(_jumlahKKCtrl.text.trim()) ?? 0,
        jumlahPria: int.tryParse(_jumlahPriaCtrl.text.trim()) ?? 0,
        jumlahWanita: int.tryParse(_jumlahWanitaCtrl.text.trim()) ?? 0,
        jumlahBalita: int.tryParse(_jumlahBalitaCtrl.text.trim()) ?? 0,
        jumlahAnakSekolah: int.tryParse(_jumlahAnakSekolahCtrl.text.trim()) ?? 0,
        visi: _visiCtrl.text.trim(),
        misi: _misiCtrl.text.trim(),
      );
      await _db.updateProfilRT(data.toMap());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil RT berhasil disimpan'), backgroundColor: AppColors.primaryGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
      backgroundColor: AppColors.bgGreen,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Data Wilayah'),
            _formCard([
              _field('Nama RT', _namaRTCtrl),
              _field('Nama RW', _namaRWCtrl),
              _field('Kelurahan', _kelurahanCtrl),
              _field('Kecamatan', _kecamatanCtrl),
              _field('Kota', _kotaCtrl),
              _field('Kode Pos', _kodePosCtrl, keyboardType: TextInputType.number),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Struktur Pengurus'),
            _formCard([
              _field('Nama Ketua RT', _namaKetuaCtrl),
              _field('Nama Wakil Ketua', _namaWakilKetuaCtrl),
              _field('Nama Sekretaris', _namaSekretarisCtrl),
              _field('Nama Bendahara', _namaBendaharaCtrl),
              _field('No. HP Ketua RT', _noHpKetuaCtrl, keyboardType: TextInputType.phone),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Data Kependudukan'),
            _formCard([
              _field('Jumlah KK', _jumlahKKCtrl, keyboardType: TextInputType.number),
              _field('Jumlah Pria', _jumlahPriaCtrl, keyboardType: TextInputType.number),
              _field('Jumlah Wanita', _jumlahWanitaCtrl, keyboardType: TextInputType.number),
              _field('Jumlah Balita', _jumlahBalitaCtrl, keyboardType: TextInputType.number),
              _field('Jumlah Anak Sekolah', _jumlahAnakSekolahCtrl, keyboardType: TextInputType.number),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Visi & Misi'),
            _formCard([
              _field('Visi', _visiCtrl, maxLines: 3),
              _field('Misi', _misiCtrl, maxLines: 5),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
    );
  }

  Widget _formCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.bgGreen,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
