import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class PembayaranScreen extends StatefulWidget {
  const PembayaranScreen({super.key});

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen>
    with SingleTickerProviderStateMixin {
  int _methodIndex = 0; // 0=QRIS, 1=Transfer, 2=Tunai
  bool _isScanning = false;
  bool _isUploading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  String get _bulanIni {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String get _bulanIniLabel {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final now = DateTime.now();
    return '${bulan[now.month - 1]} ${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _doScanAndUpload() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    HapticFeedback.mediumImpact();

    final file = await _storage.pickImage();
    if (file == null) return;

    setState(() => _isScanning = true);
    await _submitBuktiBayar(file, 'QRIS');
    if (mounted) setState(() => _isScanning = false);
  }

  Future<void> _pilihDanSubmitBukti(String metode) async {
    final file = await _storage.pickImage();
    if (file == null) return;
    await _submitBuktiBayar(file, metode);
  }

  Future<void> _submitBuktiBayar(PickedFile file, String metode) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isUploading = true);

    try {
      final user = await _db.getUser(uid);
      final url = await _storage.uploadBuktiBayar(uid, _bulanIni, file);

      await _db.createPembayaran(PembayaranModel(
        id: '',
        userId: uid,
        namaWarga: user?.nama ?? 'Warga',
        jenisIuran: 'Iuran Bulanan',
        nominal: 50000,
        bulan: _bulanIni,
        status: 'menunggu_verifikasi',
        metodeBayar: metode,
        buktiBayarUrl: url,
        createdAt: DateTime.now(),
      ));

      if (!mounted) return;
      _showScanResult();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim bukti bayar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showScanResult() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScanResultSheet(onClose: () => Navigator.pop(context)),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label disalin'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildTagihanCard(uid),
                  _buildMethodSelector(),
                  _buildPaymentContent(),
                  _buildRiwayatSection(uid),
                  const SizedBox(height: 24),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 16, 20),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.payment_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pembayaran Iuran',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('RT 03 RW 011 Aren Jaya',
                        style: TextStyle(color: Color(0xFFB7E4C7), fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TAGIHAN CARD ──────────────────────────────────────────────────────────

  Widget _buildTagihanCard(String? uid) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FutureBuilder<PembayaranModel?>(
        future: uid != null ? _db.getPembayaranBulanIni(uid, _bulanIni) : Future.value(null),
        builder: (context, snapshot) {
          final pembayaran = snapshot.data;
          final isLunas = pembayaran?.status == 'lunas';
          final isMenunggu = pembayaran?.status == 'menunggu_verifikasi';

          String statusText = 'Belum Lunas';
          Color statusColor = const Color(0xFFE65100);
          Color statusBg = const Color(0xFFFFF3E0);
          IconData statusIcon = Icons.pending_rounded;

          if (isLunas) {
            statusText = 'Lunas';
            statusColor = AppColors.primaryGreen;
            statusBg = const Color(0xFFE8F5E9);
            statusIcon = Icons.check_circle_rounded;
          } else if (isMenunggu) {
            statusText = 'Menunggu Verifikasi';
            statusColor = const Color(0xFF1565C0);
            statusBg = const Color(0xFFE3F2FD);
            statusIcon = Icons.hourglass_top_rounded;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Tagihan',
                                style: TextStyle(color: AppColors.textGrey, fontSize: 12.5, fontWeight: FontWeight.w500)),
                            SizedBox(height: 4),
                            Text('Rp 50.000',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkGreen,
                                  letterSpacing: -0.5,
                                )),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, color: statusColor, size: 13),
                              const SizedBox(width: 5),
                              Text(statusText,
                                  style: TextStyle(
                                      fontSize: 11.5, fontWeight: FontWeight.w700, color: statusColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _tagihanDetail(Icons.calendar_month_rounded, 'Periode', _bulanIniLabel),
                          _vDivider(),
                          _tagihanDetail(Icons.home_work_rounded, 'Untuk', 'RT 03/011'),
                          _vDivider(),
                          _tagihanDetail(Icons.account_balance_wallet_rounded, 'Jenis', 'Iuran Rutin'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Color(0xFFE65100), size: 14),
                    const SizedBox(width: 6),
                    const Text('Jatuh tempo: ', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                    const Text('Tanggal 10',
                        style: TextStyle(color: Color(0xFFE65100), fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tagihanDetail(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 16),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 10.5)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(color: AppColors.darkGreen, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(width: 1, height: 36, color: Colors.grey.shade200);
  }

  // ── METHOD SELECTOR ───────────────────────────────────────────────────────

  Widget _buildMethodSelector() {
    final methods = [
      {'icon': Icons.qr_code_rounded, 'label': 'QRIS'},
      {'icon': Icons.account_balance_rounded, 'label': 'Transfer'},
      {'icon': Icons.payments_rounded, 'label': 'Tunai'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: List.generate(methods.length, (i) {
          final isActive = _methodIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _methodIndex = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      methods[i]['icon'] as IconData,
                      size: 16,
                      color: isActive ? Colors.white : AppColors.textGrey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      methods[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? Colors.white : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── PAYMENT CONTENT ───────────────────────────────────────────────────────

  Widget _buildPaymentContent() {
    switch (_methodIndex) {
      case 0:
        return _buildQRISContent();
      case 1:
        return _buildTransferContent();
      default:
        return _buildTunaiContent();
    }
  }

  // ── QRIS CONTENT ──────────────────────────────────────────────────────────

  Widget _buildQRISContent() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('QRIS',
                      style: TextStyle(color: AppColors.darkGreen, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Scan dengan e-wallet/m-banking',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isScanning ? AppColors.accentGreen : Colors.grey.shade200,
                      width: _isScanning ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isScanning
                            ? AppColors.primaryGreen.withOpacity(0.15)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _isScanning
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                              strokeWidth: 3,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/qris.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _buildQRFallback(),
                            ),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payments_rounded, size: 14, color: AppColors.accentGreen),
                  const SizedBox(width: 6),
                  const Text('Rp 50.000',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.darkGreen)),
                  const SizedBox(width: 6),
                  Text('· $_bulanIniLabel', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: (_isScanning || _isUploading) ? null : _doScanAndUpload,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isScanning
                        ? [const Color(0xFF74C69D), const Color(0xFF52B788)]
                        : [const Color(0xFF40916C), const Color(0xFF1B4332)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isScanning ? Icons.crop_free_rounded : Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isScanning ? 'Mengunggah bukti...' : 'Upload Bukti Bayar QRIS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              'Setelah membayar, unggah bukti pembayaran untuk diverifikasi admin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 11.5, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRFallback() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 80, color: AppColors.darkGreen.withOpacity(0.7)),
          const SizedBox(height: 8),
          Text('QRIS RT 03/011', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ── TRANSFER CONTENT ──────────────────────────────────────────────────────

  Widget _buildTransferContent() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_rounded, color: Color(0xFF1565C0), size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transfer Bank', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.darkGreen)),
                    Text('Salin nomor rekening di bawah', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            _bankAccountCard('BCA', '1234567890', 'RT 03 RW 011 Aren Jaya', const Color(0xFF1565C0)),
            const SizedBox(height: 12),
            _bankAccountCard('Mandiri', '9876543210', 'RT 03 RW 011 Aren Jaya', const Color(0xFF1B5E20)),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFCC02).withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFFE65100)),
                      SizedBox(width: 6),
                      Text('Petunjuk Transfer',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFE65100))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._transferSteps(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: _isUploading ? null : () => _pilihDanSubmitBukti('Transfer'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF40916C), Color(0xFF1B4332)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _isUploading
                    ? const Center(
                        child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Upload Bukti Transfer',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bankAccountCard(String bank, String noRek, String atas, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(bank.substring(0, 1),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
                const SizedBox(height: 2),
                Text(noRek,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.textDark, letterSpacing: 1.5)),
                Text('a.n. $atas', style: const TextStyle(fontSize: 11.5, color: AppColors.textGrey)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _copyToClipboard(noRek, 'No. Rekening $bank'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded, size: 13, color: color),
                  const SizedBox(width: 4),
                  Text('Salin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _transferSteps() {
    final steps = [
      'Transfer sesuai nominal tagihan (Rp 50.000)',
      'Tambahkan 3 digit kode unik: Rp 50.XXX',
      'Simpan bukti transfer',
      'Upload bukti transfer di bawah ini',
    ];
    return steps.asMap().entries.map((e) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(color: Color(0xFFE65100), shape: BoxShape.circle),
              child: Center(
                child: Text('${e.key + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(e.value, style: const TextStyle(fontSize: 12.5, color: AppColors.textDark, height: 1.4))),
          ],
        ),
      );
    }).toList();
  }

  // ── TUNAI CONTENT ─────────────────────────────────────────────────────────

  Widget _buildTunaiContent() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.payments_rounded, color: AppColors.primaryGreen, size: 38),
            ),
            const SizedBox(height: 16),
            const Text('Bayar Tunai ke Petugas',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
            const SizedBox(height: 8),
            const Text(
              'Pembayaran tunai dapat dilakukan langsung kepada ketua RT atau petugas yang ditunjuk',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jadwal Pengumpulan Iuran',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.darkGreen)),
                  const SizedBox(height: 12),
                  _tunaiRow(Icons.calendar_today_rounded, 'Tanggal', 'Tgl 1 – 10 setiap bulan'),
                  const SizedBox(height: 8),
                  _tunaiRow(Icons.access_time_rounded, 'Waktu', '18:00 – 21:00 WIB'),
                  const SizedBox(height: 8),
                  _tunaiRow(Icons.location_on_rounded, 'Lokasi', 'Sekretariat RT 03/011'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tunaiRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.accentGreen),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: AppColors.textGrey, fontSize: 12.5)),
        Text(value, style: const TextStyle(color: AppColors.darkGreen, fontSize: 12.5, fontWeight: FontWeight.w700)),
      ],
    );
  }

  // ── RIWAYAT ───────────────────────────────────────────────────────────────

  String _formatTanggalSingkat(DateTime? date) {
    if (date == null) return '-';
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day.toString().padLeft(2, '0')} ${bulan[date.month - 1]}';
  }

  String _formatBulanLabel(String bulanKode) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final parts = bulanKode.split('-');
    if (parts.length != 2) return bulanKode;
    final bulanIdx = int.tryParse(parts[1]);
    if (bulanIdx == null || bulanIdx < 1 || bulanIdx > 12) return bulanKode;
    return '${bulan[bulanIdx - 1]} ${parts[0]}';
  }

  Widget _buildRiwayatSection(String? uid) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Riwayat Pembayaran',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
            const SizedBox(height: 14),
            if (uid == null)
              const Text('Belum login', style: TextStyle(color: AppColors.textGrey, fontSize: 13))
            else
              StreamBuilder<List<PembayaranModel>>(
                stream: _db.streamPembayaranByUser(uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                  }
                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return const Text('Belum ada riwayat pembayaran',
                        style: TextStyle(color: AppColors.textGrey, fontSize: 13));
                  }
                  return Column(
                    children: items.map((r) => _riwayatRow(r)).toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _riwayatRow(PembayaranModel r) {
    final isLunas = r.status == 'lunas';
    final isMenunggu = r.status == 'menunggu_verifikasi';
    final statusLabel = isLunas ? 'Lunas' : (isMenunggu ? 'Diperiksa' : 'Belum');
    final statusColor = isLunas
        ? AppColors.primaryGreen
        : (isMenunggu ? const Color(0xFF1565C0) : const Color(0xFFC62828));
    final statusBg = isLunas
        ? const Color(0xFFE8F5E9)
        : (isMenunggu ? const Color(0xFFE3F2FD) : const Color(0xFFFCE4EC));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(
              isLunas ? Icons.check_circle_rounded : (isMenunggu ? Icons.hourglass_top_rounded : Icons.cancel_rounded),
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Iuran ${_formatBulanLabel(r.bulan)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.textDark)),
                Text(
                  isLunas && r.tanggalBayar != null
                      ? 'Dibayar ${_formatTanggalSingkat(r.tanggalBayar)}'
                      : 'Via ${r.metodeBayar}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Rp ${r.nominal.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.darkGreen)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                child: Text(statusLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── SCAN RESULT BOTTOM SHEET ──────────────────────────────────────────────────

class _ScanResultSheet extends StatelessWidget {
  final VoidCallback onClose;
  const _ScanResultSheet({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: AppColors.primaryGreen, size: 34),
          ),
          const SizedBox(height: 14),
          const Text('Bukti Bayar Terkirim!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
          const SizedBox(height: 8),
          const Text('Pembayaran kamu sedang menunggu\nverifikasi dari admin RT',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: 14, height: 1.4)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.bgGreen, borderRadius: BorderRadius.circular(14)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RT 03/011 Aren Jaya', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkGreen)),
                Text('Rp 50.000', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryGreen)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF40916C), Color(0xFF1B4332)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('Selesai', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
