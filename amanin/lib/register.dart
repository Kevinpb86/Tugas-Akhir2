import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart'; // For navigation to login
import 'services/api_config.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  OverlayEntry? _currentOverlayEntry;

  void _showTopNotification(String message, {bool isSuccess = false}) {
    if (_currentOverlayEntry != null) {
      _currentOverlayEntry!.remove();
      _currentOverlayEntry = null;
    }

    _currentOverlayEntry = OverlayEntry(
      builder: (context) => TopNotification(
        message: message,
        isSuccess: isSuccess,
        onDismiss: () {
          if (_currentOverlayEntry != null) {
            _currentOverlayEntry!.remove();
            _currentOverlayEntry = null;
          }
        },
      ),
    );

    Overlay.of(context).insert(_currentOverlayEntry!);
  }

  @override
  void dispose() {
    if (_currentOverlayEntry != null) {
      _currentOverlayEntry!.remove();
      _currentOverlayEntry = null;
    }
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      // Sign out first to force the account picker dialog to appear
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': googleUser.email,
            'full_name': googleUser.displayName ?? 'Pengguna Google',
            'google_id': googleUser.id,
          }),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            _showTopNotification('Registrasi Google Berhasil! Silakan masuk.', isSuccess: true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        } else {
          final error = jsonDecode(response.body);
          if (mounted) {
            _showTopNotification('Registrasi Google gagal: ${error['detail'] ?? 'Gagal menghubungi server'}', isSuccess: false);
          }
        }
      } else {
        if (mounted) {
          _showTopNotification('Daftar Google gagal/dibatalkan', isSuccess: false);
        }
      }
    } catch (error) {
      if (mounted) {
        _showTopNotification('Daftar Google gagal: $error', isSuccess: false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF00BCD4), const Color(0xFF092C4C)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Hero(
                      tag: 'register_app_logo',
                      child: Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo_amanin.png',
                            height: 110,
                            width: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 32,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buat Akun',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Color(0xFF092C4C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Daftar untuk informasi bencana terkini',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildInputField(
                              label: 'Nama Lengkap',
                              controller: _nameController,
                              icon: Icons.person_outline,
                              hintText: 'Masukkan nama lengkap',
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              label: 'Email',
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              hintText: 'Masukkan email Anda',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              label: 'Kata Sandi',
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              hintText: 'Buat kata sandi',
                              isPassword: true,
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              label: 'Konfirmasi Kata Sandi',
                              controller: _confirmPasswordController,
                              icon: Icons.lock_outline,
                              hintText: 'Ulangi kata sandi',
                              isPassword: true,
                              isConfirmPassword: true,
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0xFF00BCD4),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00BCD4,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Daftar Akun',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: const [
                                Expanded(
                                  child: Divider(color: Color(0xFFE0E0E0)),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Atau daftar dengan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Color(0xFFE0E0E0)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(
                                  const Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFEA4335),
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  'Google',
                                  _signInWithGoogle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Register dengan seluruh data kosong
    if (name.isEmpty && email.isEmpty && password.isEmpty && confirmPassword.isEmpty) {
      _showTopNotification('Semua field tidak boleh kosong!', isSuccess: false);
      return;
    }

    // 2. Register dengan nama kosong
    if (name.isEmpty) {
      _showTopNotification('Data nama tidak boleh kosong atau data tidak valid.', isSuccess: false);
      return;
    }

    // 3. Register dengan email kosong
    if (email.isEmpty) {
      _showTopNotification('Email tidak boleh kosong atau data tidak valid.', isSuccess: false);
      return;
    }

    // 4. Register dengan format email tidak valid
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      _showTopNotification('Format email tidak valid.', isSuccess: false);
      return;
    }

    // 5. Register dengan kata sandi kosong
    if (password.isEmpty) {
      _showTopNotification('Kata sandi tidak boleh kosong.', isSuccess: false);
      return;
    }

    // 6. Register dengan kata sandi dan konfirmasi kata sandi tidak sama
    if (password != confirmPassword) {
      _showTopNotification('Kata sandi tidak cocok!', isSuccess: false);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': name,
          'email': email,
          'password': password,
        }),
      );

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          _showTopNotification('Pendaftaran Berhasil! Silakan login.', isSuccess: true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          _showTopNotification(error['detail'] ?? 'Pendaftaran Gagal', isSuccess: false);
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        _showTopNotification('Terjadi kesalahan: $e', isSuccess: false);
      }
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType? keyboardType,
  }) {
    bool obscure = isConfirmPassword
        ? _obscureConfirmPassword
        : _obscurePassword;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF092C4C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? obscure : false,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 22),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isConfirmPassword) {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          } else {
                            _obscurePassword = !_obscurePassword;
                          }
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    Widget iconWidget,
    String label,
    VoidCallback onTap,
  ) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF092C4C).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(child: iconWidget),
        ),
      ),
    );
  }
}

class TopNotification extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback onDismiss;

  const TopNotification({
    super.key,
    required this.message,
    required this.isSuccess,
    required this.onDismiss,
  });

  @override
  State<TopNotification> createState() => _TopNotificationState();
}

class _TopNotificationState extends State<TopNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    if (_controller.isAnimating || _controller.status == AnimationStatus.dismissed) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.isSuccess ? const Color(0xFF81C784) : const Color(0xFFE57373),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                        color: widget.isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: widget.isSuccess ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _dismiss,
                        child: Icon(
                          Icons.close,
                          color: widget.isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
