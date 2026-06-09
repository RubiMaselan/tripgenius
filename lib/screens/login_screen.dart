import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      _showSnack('Please fill all fields');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await _authService.login(
          _emailCtrl.text.trim(), _passCtrl.text.trim());
      if (res['success'] == true) {
        await AuthService.saveToken(res['token']);
        await AuthService.saveUser(User.fromJson(res['user']));
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showSnack(res['error'] ?? 'Login failed');
      }
    } catch (e) {
      _showSnack('Connection error');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF1E2540),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                    child: Text('✈', style: TextStyle(fontSize: 26))),
              ),
              const SizedBox(height: 28),
              const Text('Welcome back',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEAE6D7),
                      fontFamily: 'Georgia')),
              const SizedBox(height: 8),
              Text('Sign in to continue your journey',
                  style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFFEAE6D7).withOpacity(0.4))),
              const SizedBox(height: 40),
              _label('EMAIL'),
              const SizedBox(height: 8),
              _field(controller: _emailCtrl, hint: 'your@email.com',
                  icon: Icons.mail_outline, isEmail: true),
              const SizedBox(height: 20),
              _label('PASSWORD'),
              const SizedBox(height: 8),
              _field(controller: _passCtrl, hint: '••••••••',
                  icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Color(0xFF0A0E1A), strokeWidth: 2.5))
                      : const Text('Sign In',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A0E1A),
                              fontFamily: 'Georgia')),
                ),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Don't have an account? ",
                    style: TextStyle(
                        color: const Color(0xFFEAE6D7).withOpacity(0.4))),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Sign Up',
                      style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: Color(0xFFD4AF37), letterSpacing: 2.0));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isEmail = false,
  }) =>
      TextField(
        controller: controller,
        obscureText: isPassword ? _obscure : false,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: const TextStyle(color: Color(0xFFEAE6D7), fontFamily: 'Georgia'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: const Color(0xFFEAE6D7).withOpacity(0.25)),
          prefixIcon: Icon(icon, color: const Color(0xFFD4AF37).withOpacity(0.7), size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF4A5270), size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure))
              : null,
          filled: true,
          fillColor: const Color(0xFF131929),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1E2540))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1E2540))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5)),
        ),
      );
}