import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> destination;
  const DestinationDetailScreen({super.key, required this.destination});
  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _detail;
  bool _loading = true;
  bool _inWishlist = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _apiService
          .getDestinationDetail(widget.destination['id']);
      setState(() => _detail = data);
    } catch (e) {
      setState(() => _detail = widget.destination);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleWishlist() async {
    try {
      await _apiService.addToWishlist(widget.destination['id']);
      setState(() => _inWishlist = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Added to wishlist!'),
        backgroundColor: Color(0xFF1E2540),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Already in wishlist'),
        backgroundColor: Color(0xFF1E2540),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail ?? widget.destination;
    final attractions =
        (d['attractions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final accommodation =
        (d['accommodation'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0F1422),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E2540)),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Color(0xFFEAE6D7), size: 16),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: _toggleWishlist,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E2540)),
                  ),
                  child: Icon(
                    _inWishlist ? Icons.favorite : Icons.favorite_outline,
                    color: const Color(0xFFEF4444), size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFF0F1422),
                child: Center(
                  child: Text('🌍', style: const TextStyle(fontSize: 80)),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(d['name'] ?? '',
                    style: const TextStyle(fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEAE6D7),
                        fontFamily: 'Georgia')),
                const SizedBox(height: 6),
                Text(d['country'] ?? '',
                    style: TextStyle(fontSize: 14,
                        color: const Color(0xFFEAE6D7).withOpacity(0.4),
                        letterSpacing: 1)),
                const SizedBox(height: 16),
                Text(d['description'] ?? '',
                    style: TextStyle(fontSize: 14,
                        color: const Color(0xFFEAE6D7).withOpacity(0.7),
                        height: 1.6)),
                if (attractions.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _sectionTitle('Top Attractions'),
                  const SizedBox(height: 12),
                  ...attractions.map((a) => _infoCard(
                      Icons.place_outlined, a['name'] ?? '',
                      a['description'] ?? '')),
                ],
                if (accommodation.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _sectionTitle('Where to Stay'),
                  const SizedBox(height: 12),
                  ...accommodation.map((a) => _infoCard(
                      Icons.hotel_outlined, a['name'] ?? '',
                      '${a['type'] ?? ''} · ${a['price_range'] ?? ''}')),
                ],
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: Color(0xFFD4AF37), letterSpacing: 2.0));

  Widget _infoCard(IconData icon, String title, String subtitle) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1422),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E2540)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w600, color: Color(0xFFEAE6D7))),
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(fontSize: 12,
                  color: const Color(0xFFEAE6D7).withOpacity(0.4))),
            ],
          )),
        ]),
      );
}