import 'package:flutter/material.dart';
import '../models/trip_input.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'itinerary_screen.dart';

class TripBuilderScreen extends StatefulWidget {
  const TripBuilderScreen({super.key});
  @override
  State<TripBuilderScreen> createState() => _TripBuilderScreenState();
}

class _TripBuilderScreenState extends State<TripBuilderScreen>
    with TickerProviderStateMixin {
  final _destinationController = TextEditingController();
  final _daysController = TextEditingController();
  final _apiService = ApiService();

  final List<String> _allInterests = ['Food', 'Nature', 'Shopping', 'Culture'];
  final List<String> _selectedInterests = [];
  String _budget = 'Medium';
  bool _isLoading = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Map<String, IconData> _interestIcons = {
    'Food': Icons.restaurant_outlined,
    'Nature': Icons.forest_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Culture': Icons.museum_outlined,
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _destinationController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  Future<void> _generateItinerary() async {
    final token = await AuthService.getToken();
    print('DEBUG token: $token');

    if (token == null || token.isEmpty) {
      _showSnack('Not logged in — please sign out and login again');
      return;
    }

    if (_destinationController.text.trim().isEmpty) {
      _showSnack('Please enter a destination');
      return;
    }
    if (_daysController.text.trim().isEmpty) {
      _showSnack('Please enter number of days');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final input = TripInput(
        destination: _destinationController.text.trim(),
        days: int.parse(_daysController.text.trim()),
        interests: _selectedInterests.isEmpty
            ? ['General sightseeing']
            : _selectedInterests,
        budget: _budget,
      );

      final itinerary = await _apiService.generateItinerary(input);

      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, a, __) => ItineraryScreen(itinerary: itinerary),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Georgia')),
        backgroundColor: const Color(0xFF1E2540),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4AF37).withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 100, left: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withOpacity(0.04),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                            child: Text('✈', style: TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TripGenius',
                              style: TextStyle(fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEAE6D7),
                                  fontFamily: 'Georgia',
                                  letterSpacing: 0.5)),
                          Text('AI-Powered Travel Planner',
                              style: TextStyle(fontSize: 12,
                                  color: const Color(0xFFD4AF37).withOpacity(0.8),
                                  letterSpacing: 1.5)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  const Text('Where would you\nlike to go?',
                      style: TextStyle(fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEAE6D7),
                          fontFamily: 'Georgia',
                          height: 1.2)),
                  const SizedBox(height: 8),
                  Text('Let AI craft your perfect journey',
                      style: TextStyle(fontSize: 14,
                          color: const Color(0xFFEAE6D7).withOpacity(0.4))),
                  const SizedBox(height: 36),
                  _sectionLabel('DESTINATION'),
                  const SizedBox(height: 10),
                  _premiumField(controller: _destinationController,
                      hint: 'e.g. Tokyo, Paris, Bali...',
                      icon: Icons.location_on_outlined),
                  const SizedBox(height: 24),
                  _sectionLabel('DURATION'),
                  const SizedBox(height: 10),
                  _premiumField(controller: _daysController,
                      hint: 'Number of days',
                      icon: Icons.calendar_today_outlined,
                      isNumber: true),
                  const SizedBox(height: 24),
                  _sectionLabel('INTERESTS'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.8,
                    children: _allInterests.map((interest) {
                      final selected = _selectedInterests.contains(interest);
                      return GestureDetector(
                        onTap: () => _toggleInterest(interest),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFD4AF37).withOpacity(0.15)
                                : const Color(0xFF131929),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? const Color(0xFFD4AF37) : const Color(0xFF1E2540),
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_interestIcons[interest], size: 16,
                                  color: selected ? const Color(0xFFD4AF37) : const Color(0xFF4A5270)),
                              const SizedBox(width: 8),
                              Text(interest,
                                  style: TextStyle(fontSize: 13,
                                      color: selected ? const Color(0xFFD4AF37) : const Color(0xFF4A5270),
                                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('BUDGET'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF131929),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1E2540), width: 1),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: ['Low', 'Medium', 'High'].map((b) {
                        final selected = _budget == b;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _budget = b),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFFD4AF37) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(b,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? const Color(0xFF0A0E1A) : const Color(0xFF4A5270))),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _isLoading ? null : _generateItinerary,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (_, child) => Transform.scale(
                        scale: _isLoading ? 1.0 : _pulseAnimation.value,
                        child: child,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF0A0E1A), strokeWidth: 2.5))
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.auto_awesome,
                                        color: Color(0xFF0A0E1A), size: 18),
                                    SizedBox(width: 10),
                                    Text('Generate Itinerary',
                                        style: TextStyle(fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0A0E1A),
                                            fontFamily: 'Georgia',
                                            letterSpacing: 0.5)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: Color(0xFFD4AF37), letterSpacing: 2.0));

  Widget _premiumField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) =>
      TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Color(0xFFEAE6D7),
            fontFamily: 'Georgia', fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: const Color(0xFFEAE6D7).withOpacity(0.25),
              fontFamily: 'Georgia'),
          prefixIcon: Icon(icon,
              color: const Color(0xFFD4AF37).withOpacity(0.7), size: 20),
          filled: true,
          fillColor: const Color(0xFF131929),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1E2540), width: 1)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1E2540), width: 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5)),
        ),
      );
}