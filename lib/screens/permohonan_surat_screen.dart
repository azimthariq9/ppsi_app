import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';

class PermohonanSuratScreen extends StatefulWidget {
  const PermohonanSuratScreen({super.key});

  @override
  State<PermohonanSuratScreen> createState() => _PermohonanSuratScreenState();
}

class _PermohonanSuratScreenState extends State<PermohonanSuratScreen> {
  final _namaCtrl = TextEditingController();
  final _noKtpCtrl = TextEditingController();
  final _kepCtrl = TextEditingController();
  String _jenisSurat = 'Surat Keterangan Domisili';
  bool _submitted = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _noKtpCtrl.dispose();
    _kepCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_namaCtrl.text.isEmpty || _noKtpCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua field'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permohonan surat berhasil dikirim!'), backgroundColor: AppColors.primaryGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jenisSuratList = [
      'Surat Keterangan Domisili',
      'Surat Keterangan Tidak Mampu',
      'Surat Keterangan Usaha',
      'Surat Pengantar KTP',
      'Surat Pengantar KK',
      'Surat Keterangan Kelahiran',
      'Surat Keterangan Kematian',
      'Surat Keterangan Lainnya',
    ];

    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Permohonan Surat', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/permohonan-surat'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_submitted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentGreen),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 22),
                    SizedBox(width: 10),
                    Expanded(child: Text('Permohonan surat berhasil dikirim! Surat akan diproses dalam 2-3 hari kerja.', style: TextStyle(color: AppColors.darkGreen, fontSize: 13))),
                  ],
                ),
              ),

            // Jenis Surat Options
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jenis Surat Tersedia', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkGreen)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: jenisSuratList.map((s) {
                      final isSelected = _jenisSurat == s;
                      return GestureDetector(
                        onTap: () => setState(() => _jenisSurat = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryGreen : AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Form
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description_rounded, color: AppColors.primaryGreen, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _jenisSurat,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Isi formulir berikut untuk mengajukan surat', style: TextStyle(fontSize: 12.5, color: AppColors.textGrey)),
                  const SizedBox(height: 20),

                  _buildLabel('Nama Lengkap *'),
                  _buildTextField(_namaCtrl, 'Sesuai KTP'),
                  const SizedBox(height: 14),

                  _buildLabel('Nomor KTP *'),
                  _buildTextField(_noKtpCtrl, '16 digit nomor KTP', keyboardType: TextInputType.number),
                  const SizedBox(height: 14),

                  _buildLabel('Keperluan'),
                  _buildTextField(_kepCtrl, 'Contoh: Keperluan melamar kerja'),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Ajukan Permohonan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primaryGreen, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Surat akan diproses dalam 2-3 hari kerja. Ambil surat di Sekretariat RT 003/011 setelah mendapat konfirmasi.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.darkGreen, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
      ),
    );
  }
}