import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'destination_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _wishlist = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _apiService.getWishlist();
      setState(() => _wishlist = data);
    } catch (e) {
      setState(() => _wishlist = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _remove(int id) async {
    await _apiService.removeFromWishlist(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SAVED',
                      style: TextStyle(fontSize: 11,
                          color: const Color(0xFFD4AF37).withOpacity(0.8),
                          letterSpacing: 3.0, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('Wishlist',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                          color: Color(0xFFEAE6D7), fontFamily: 'Georgia')),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(
                      color: Color(0xFFD4AF37)))
                  : _wishlist.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('❤️', style: TextStyle(fontSize: 56)),
                              const SizedBox(height: 16),
                              const Text('No saved destinations',
                                  style: TextStyle(fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEAE6D7),
                                      fontFamily: 'Georgia')),
                              const SizedBox(height: 8),
                              Text('Add destinations from the Search tab',
                                  style: TextStyle(fontSize: 13,
                                      color: const Color(0xFFEAE6D7)
                                          .withOpacity(0.4))),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                          itemCount: _wishlist.length,
                          itemBuilder: (context, index) {
                            final item = _wishlist[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) =>
                                      DestinationDetailScreen(destination: item))),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F1422),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: const Color(0xFF1E2540), width: 1),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  leading: Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFD4AF37)
                                              .withOpacity(0.3)),
                                    ),
                                    child: const Center(
                                        child: Text('🌍',
                                            style: TextStyle(fontSize: 22))),
                                  ),
                                  title: Text(item['name'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFFEAE6D7),
                                          fontFamily: 'Georgia')),
                                  subtitle: Text(item['country'] ?? '',
                                      style: const TextStyle(
                                          color: Color(0xFF4A5270))),
                                  trailing: GestureDetector(
                                    onTap: () => _remove(item['id']),
                                    child: Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444)
                                            .withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFEF4444)
                                                .withOpacity(0.2)),
                                      ),
                                      child: const Icon(Icons.favorite,
                                          color: Color(0xFFEF4444), size: 16),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}