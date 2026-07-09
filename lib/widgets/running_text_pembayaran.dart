import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../services/firestore_service.dart';

/// Banner berjalan (running text) di bawah card "Selamat Datang" di Home.
///
/// - Kalau iuran bulan ini SUDAH lunas -> teks hijau:
///     "Selamat, <nama> — pembayaran iuran anda lancar"
/// - Kalau BELUM (belum bayar / masih menunggu verifikasi) -> teks amber,
///   dan bisa diketuk untuk langsung menuju halaman Pembayaran:
///     "Mohon agar tetap menjaga iuran bersama untuk bulan <bulan>,
///      dari anda untuk anda"
class PembayaranRunningText extends StatefulWidget {
  const PembayaranRunningText({super.key});

  @override
  State<PembayaranRunningText> createState() => _PembayaranRunningTextState();
}

class _PembayaranRunningTextState extends State<PembayaranRunningText> {
  final FirestoreService _db = FirestoreService();

  bool _loading = true;
  bool _lunas = false;
  String _nama = '';

  static const List<String> _bulanIndo = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  late final DateTime _now = DateTime.now();
  late final String _bulanKey =
      '${_now.year}-${_now.month.toString().padLeft(2, '0')}';
  late final String _bulanLabel = '${_bulanIndo[_now.month - 1]} ${_now.year}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final user = await _db.getUser(uid);
      final pembayaran = await _db.getPembayaranBulanIni(uid, _bulanKey);
      if (!mounted) return;
      setState(() {
        _nama = user?.nama ?? 'Warga';
        _lunas = pembayaran?.status == 'lunas';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox(height: 0);

    final String text = _lunas
        ? 'Selamat, $_nama — pembayaran iuran anda lancar untuk bulan $_bulanLabel. Terima kasih atas kontribusinya menjaga lingkungan bersama! 🌿'
        : 'Mohon agar tetap menjaga iuran bersama untuk bulan $_bulanLabel, dari anda untuk anda 🤝 — ketuk untuk bayar sekarang.';

    final Color bg = _lunas ? AppColors.statusSuccessBg : AppColors.statusWarningBg;
    final Color fg = _lunas ? AppColors.statusSuccess : AppColors.statusWarning;
    final IconData icon = _lunas ? Icons.verified_rounded : Icons.campaign_rounded;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GestureDetector(
        onTap: _lunas ? null : () => Navigator.pushNamed(context, '/pembayaran'),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: fg.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fg.withOpacity(0.14),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                ),
                child: Icon(icon, color: fg, size: 18),
              ),
              Expanded(
                child: ClipRect(
                  child: _Marquee(
                    text: text,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Marquee sederhana tanpa dependency eksternal: teks digandakan lalu
/// digeser terus-menerus ke kiri menggunakan AnimationController,
/// dan begitu satu salinan penuh sudah lewat, posisi direset ke 0
/// (karena salinan kedua identik, transisinya terlihat seamless/menyambung).
class _Marquee extends StatefulWidget {
  final String text;
  final Color color;

  const _Marquee({required this.text, required this.color});

  @override
  State<_Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<_Marquee> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _textWidth = 0;
  static const double _gap = 48;
  static const double _pixelsPerSecond = 42;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndStart());
  }

  void _measureAndStart() {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: _textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final width = painter.width + _gap;
    final seconds = width / _pixelsPerSecond;
    if (!mounted) return;
    setState(() => _textWidth = width);
    _controller.duration = Duration(milliseconds: (seconds * 1000).round());
    _controller.repeat();
  }

  TextStyle get _textStyle => TextStyle(
        color: widget.color,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_textWidth == 0) {
      // Belum sempat diukur -> tampilkan statis dulu supaya tidak kosong.
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          widget.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _textStyle,
        ),
      );
    }

    final double dx = -(_controller.value * _textWidth);

    return Stack(
      children: [
        Positioned(
          left: dx + 10,
          top: 0,
          bottom: 0,
          child: Row(
            children: [
              Center(child: Text(widget.text, style: _textStyle, maxLines: 1)),
              SizedBox(width: _gap),
              Center(child: Text(widget.text, style: _textStyle, maxLines: 1)),
            ],
          ),
        ),
      ],
    );
  }
}
