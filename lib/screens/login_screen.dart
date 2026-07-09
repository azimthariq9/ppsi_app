import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/hover_scale.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  // LOGIN
  final TextEditingController loginEmailController =
      TextEditingController();

  final TextEditingController loginPasswordController =
      TextEditingController();

  // REGISTER
  final TextEditingController regNamaController =
      TextEditingController();

  final TextEditingController regNikController =
      TextEditingController();

  final TextEditingController regEmailController =
      TextEditingController();

  final TextEditingController regPasswordController =
      TextEditingController();

  final TextEditingController regNoHpController =
      TextEditingController();

  final TextEditingController regAlamatController =
      TextEditingController();

  bool obscureLogin = true;
  bool obscureRegister = true;

  bool loadingLogin = false;
  bool loadingRegister = false;

  int _activeTab = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _activeTab) {
        setState(() => _activeTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();

    loginEmailController.dispose();
    loginPasswordController.dispose();

    regNamaController.dispose();
    regNikController.dispose();
    regEmailController.dispose();
    regPasswordController.dispose();
    regNoHpController.dispose();
    regAlamatController.dispose();

    super.dispose();
  }

  void _goToTab(int index) {
    if (_activeTab == index) return;
    HapticFeedback.selectionClick();
    setState(() => _activeTab = index);
    _tabController.animateTo(index);
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<void> login() async {
    try {
      setState(() {
        loadingLogin = true;
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login berhasil'),
        ),
      );

      // Cek role lalu arahkan ke dashboard yang sesuai
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final role = userDoc.data()?['role'] ?? 'warga';
        if (!mounted) return;
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }

    } on FirebaseAuthException catch (e) {

      // ignore: avoid_print
      print('LOGIN ERROR CODE: ${e.code} | MESSAGE: ${e.message}');

      String message = 'Terjadi kesalahan (${e.code})';

      if (e.code == 'user-not-found') {
        message = 'Email tidak ditemukan';
      }

      if (e.code == 'wrong-password') {
        message = 'Password salah';
      }

      // Firebase Auth versi terbaru menggabungkan user-not-found
      // dan wrong-password menjadi satu kode ini demi keamanan.
      if (e.code == 'invalid-credential' ||
          e.code == 'invalid-login-credentials') {
        message = 'Email atau password salah';
      }

      if (e.code == 'invalid-email') {
        message = 'Format email salah';
      }

      if (e.code == 'user-disabled') {
        message = 'Akun ini telah dinonaktifkan';
      }

      if (e.code == 'too-many-requests') {
        message = 'Terlalu banyak percobaan, coba lagi nanti';
      }

      if (e.code == 'network-request-failed') {
        message = 'Tidak ada koneksi internet';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

    } finally {
      setState(() {
        loadingLogin = false;
      });
    }
  }

  // =========================================================
  // REGISTER
  // =========================================================

  Future<void> register() async {
    try {
      setState(() {
        loadingRegister = true;
      });

      UserCredential credential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: regEmailController.text.trim(),
        password: regPasswordController.text.trim(),
      );

      await credential.user?.updateDisplayName(
        regNamaController.text.trim(),
      );

      // Simpan data user ke Firestore dengan role warga
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'nama': regNamaController.text.trim(),
        'nik': regNikController.text.trim(),
        'email': regEmailController.text.trim(),
        'no_hp': regNoHpController.text.trim(),
        'alamat': regAlamatController.text.trim(),
        'role': 'warga',
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Register berhasil'),
        ),
      );

      _goToTab(0);

    } on FirebaseAuthException catch (e) {

      String message = 'Terjadi kesalahan';

      if (e.code == 'email-already-in-use') {
        message = 'Email sudah digunakan';
      }

      if (e.code == 'weak-password') {
        message = 'Password terlalu lemah';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

    } finally {
      setState(() {
        loadingRegister = false;
      });
    }
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.authBackgroundGradient,
        ),
        child: Stack(
          children: [
            // Aksen blob dekoratif untuk kesan futuristik/glow
            Positioned(
              top: -60,
              right: -50,
              child: _glowBlob(220, AppColors.neonMint.withOpacity(0.25)),
            ),
            Positioned(
              top: 160,
              left: -70,
              child: _glowBlob(180, AppColors.glowLime.withOpacity(0.16)),
            ),
            Positioned(
              bottom: -80,
              right: -40,
              child: _glowBlob(240, AppColors.primaryGreen.withOpacity(0.3)),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  children: [
                    const AppLogo(size: 78),
                    const SizedBox(height: 18),
                    const Text(
                      'RT 03 RW 011',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aren Jaya, Bekasi Timur',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Kartu kaca (glassmorphism)
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.glassBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _segmentedToggle(),
                          const SizedBox(height: 22),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.03),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                            child: _activeTab == 0
                                ? buildLogin()
                                : buildRegister(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),
                    Text(
                      '© 2026 RT 03 RW 011 • Bersama Kita Maju',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }

  // =========================================================
  // SEGMENTED TOGGLE (Masuk / Daftar)
  // =========================================================

  Widget _segmentedToggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: _activeTab == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.glowShadow(color: AppColors.neonMint, opacity: 0.5),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: _segmentedItem('Masuk', 0)),
              Expanded(child: _segmentedItem('Daftar', 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _segmentedItem(String label, int index) {
    final bool active = _activeTab == index;
    return HoverScale(
      hoverScale: 1.0,
      pressScale: 0.97,
      onTap: () => _goToTab(index),
      child: Container(
        alignment: Alignment.center,
        height: 40,
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.darkGreen : Colors.white.withOpacity(0.75),
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // LOGIN UI
  // =========================================================

  Widget buildLogin() {

    return Column(
      key: const ValueKey('login-form'),
      children: [

        inputField(
          controller: loginEmailController,
          label: 'Email',
          icon: Icons.email_outlined,
        ),

        const SizedBox(height: 14),

        inputField(
          controller: loginPasswordController,
          label: 'Password',
          icon: Icons.lock_outline,
          obscure: obscureLogin,

          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                obscureLogin = !obscureLogin;
              });
            },

            icon: Icon(
              obscureLogin
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),

        const SizedBox(height: 22),

        submitButton(
          label: 'MASUK',
          icon: Icons.login_rounded,
          loading: loadingLogin,
          onTap: login,
        ),
      ],
    );
  }

  // =========================================================
  // REGISTER UI
  // =========================================================

  Widget buildRegister() {

    return Column(
      key: const ValueKey('register-form'),
      children: [

        inputField(
          controller: regNamaController,
          label: 'Nama Lengkap',
          icon: Icons.person_outline,
        ),

        const SizedBox(height: 14),

        inputField(
          controller: regNikController,
          label: 'NIK',
          icon: Icons.credit_card,
        ),

        const SizedBox(height: 14),

        inputField(
          controller: regEmailController,
          label: 'Email',
          icon: Icons.email_outlined,
        ),

        const SizedBox(height: 14),

        inputField(
          controller: regPasswordController,
          label: 'Password',
          icon: Icons.lock_outline,
          obscure: obscureRegister,

          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                obscureRegister = !obscureRegister;
              });
            },

            icon: Icon(
              obscureRegister
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),

        const SizedBox(height: 14),

        inputField(
          controller: regNoHpController,
          label: 'No HP',
          icon: Icons.phone,
        ),

        const SizedBox(height: 14),

        inputField(
          controller: regAlamatController,
          label: 'Alamat',
          icon: Icons.home_outlined,
          maxLines: 3,
        ),

        const SizedBox(height: 22),

        submitButton(
          label: 'DAFTAR',
          icon: Icons.app_registration_rounded,
          loading: loadingRegister,
          onTap: register,
        ),
      ],
    );
  }

  // =========================================================
  // INPUT (gelas gelap dengan glow saat fokus)
  // =========================================================

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {

    return _FocusGlowField(
      child: TextField(
        controller: controller,
        obscureText: obscure,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14.5),
        cursorColor: AppColors.glowLime,

        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.65)),

          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.75),
          ),

          suffixIcon: suffixIcon,

          filled: true,
          fillColor: Colors.black.withOpacity(0.16),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.neonMint, width: 1.4),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BUTTON
  // =========================================================

  Widget submitButton({
    required String label,
    required IconData icon,
    required bool loading,
    required VoidCallback onTap,
  }) {

    return HoverScale(
      onTap: loading ? null : onTap,
      enableHoverGlow: true,
      glowColor: AppColors.neonMint,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.neonMint, AppColors.primaryGreen],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.glowShadow(opacity: 0.28),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 19),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Bungkus TextField dengan glow halus saat field itu fokus, supaya
/// terlihat "hidup" mengikuti tema futuristik tanpa mengubah logic input.
class _FocusGlowField extends StatefulWidget {
  final Widget child;
  const _FocusGlowField({required this.child});

  @override
  State<_FocusGlowField> createState() => _FocusGlowFieldState();
}

class _FocusGlowFieldState extends State<_FocusGlowField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (has) => setState(() => _focused = has),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _focused
              ? AppColors.glowShadow(color: AppColors.neonMint, opacity: 0.28)
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}
