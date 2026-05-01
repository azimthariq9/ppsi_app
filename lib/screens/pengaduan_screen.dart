import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_drawer.dart';

class PengaduanScreen extends StatefulWidget {
  const PengaduanScreen({super.key});

  @override
  State<PengaduanScreen> createState() => _PengaduanScreenState();
}

class _PengaduanScreenState extends State<PengaduanScreen> {
  final _namaCtrl = TextEditingController();
  final _noKtpCtrl = TextEditingController();
  final _subjekCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  String _kategori = 'Lingkungan';
  bool _submitted = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _noKtpCtrl.dispose();
    _subjekCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_namaCtrl.text.isEmpty || _isiCtrl.text.isEmpty || _subjekCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua field'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaduan berhasil dikirim!'), backgroundColor: AppColors.primaryGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGreen,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pengaduan', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/pengaduan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Expanded(child: Text('Pengaduan berhasil dikirim! Kami akan meninjau dalam 1x24 jam.', style: TextStyle(color: AppColors.darkGreen, fontSize: 13))),
                  ],
                ),
              ),

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
                  const Row(
                    children: [
                      Icon(Icons.report_problem_rounded, color: AppColors.primaryGreen, size: 22),
                      SizedBox(width: 10),
                      Text('Form Pengaduan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Sampaikan keluhan atau laporan Anda kepada pengurus RT', style: TextStyle(fontSize: 12.5, color: AppColors.textGrey)),
                  const SizedBox(height: 20),

                  _buildLabel('Nama Lengkap *'),
                  _buildTextField(_namaCtrl, 'Masukkan nama lengkap Anda'),
                  const SizedBox(height: 14),

                  _buildLabel('Nomor KTP (opsional)'),
                  _buildTextField(_noKtpCtrl, 'Masukkan nomor KTP Anda', keyboardType: TextInputType.number),
                  const SizedBox(height: 14),

                  _buildLabel('Kategori Pengaduan *'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      value: _kategori,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['Lingkungan', 'Keamanan', 'Infrastruktur', 'Sosial', 'Lainnya']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) => setState(() => _kategori = val!),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildLabel('Subjek Pengaduan *'),
                  _buildTextField(_subjekCtrl, 'Masukkan subjek pengaduan'),
                  const SizedBox(height: 14),

                  _buildLabel('Isi Pengaduan *'),
                  TextField(
                    controller: _isiCtrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Ceritakan masalah atau keluhan Anda secara detail...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
                    ),
                  ),
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
                          Text('Kirim Pengaduan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info card
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
                      'Pengaduan akan diproses dalam 1×24 jam kerja. Untuk darurat, hubungi Ketua RT langsung via WhatsApp.',
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