import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _authService = AuthService();
  User? _user;
  bool _loading = false;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getUser();
    setState(() {
      _user = user;
      _nameCtrl.text = user?.name ?? '';
    });
  }

  Future<void> _updateProfile() async {
    setState(() => _loading = true);
    try {
      await _authService.updateProfile(_nameCtrl.text.trim());
      final updated = User(
          id: _user!.id,
          name: _nameCtrl.text.trim(),
          email: _user!.email);
      await AuthService.saveUser(updated);
      setState(() {
        _user = updated;
        _editing = false;
      });
      _showSnack('Profile updated!');
    } catch (e) {
      _showSnack('Update failed');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('MY PROFILE',
                  style: TextStyle(fontSize: 11,
                      color: const Color(0xFFD4AF37).withOpacity(0.8),
                      letterSpacing: 3.0, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('Account Settings',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                      color: Color(0xFFEAE6D7), fontFamily: 'Georgia')),
              const SizedBox(height: 36),

              // Avatar
              Center(
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      _user?.name.isNotEmpty == true
                          ? _user!.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                          fontFamily: 'Georgia'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(_user?.email ?? '',
                    style: TextStyle(fontSize: 13,
                        color: const Color(0xFFEAE6D7).withOpacity(0.4))),
              ),
              const SizedBox(height: 36),

              // Name field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1422),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2540)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('FULL NAME',
                            style: TextStyle(fontSize: 11,
                                color: Color(0xFFD4AF37),
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w600)),
                        GestureDetector(
                          onTap: () => setState(() => _editing = !_editing),
                          child: Text(_editing ? 'Cancel' : 'Edit',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFFD4AF37))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _editing
                        ? TextField(
                            controller: _nameCtrl,
                            style: const TextStyle(color: Color(0xFFEAE6D7),
                                fontFamily: 'Georgia'),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF131929),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E2540))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1E2540))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFD4AF37), width: 1.5)),
                            ),
                          )
                        : Text(_user?.name ?? '',
                            style: const TextStyle(fontSize: 16,
                                color: Color(0xFFEAE6D7),
                                fontFamily: 'Georgia')),
                    if (_editing) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const SizedBox(width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF0A0E1A), strokeWidth: 2))
                              : const Text('Save Changes',
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                      color: Color(0xFF0A0E1A))),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Logout
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
                  label: const Text('Sign Out',
                      style: TextStyle(color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444), width: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
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