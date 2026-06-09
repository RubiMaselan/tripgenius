import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'destination_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _apiService = ApiService();
  List<Map<String, dynamic>> _destinations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() => _loading = true);
    try {
      final data = await _apiService.getDestinations(search: search);
      setState(() => _destinations = data);
    } catch (e) {
      setState(() => _destinations = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  final List<String> _emojis = ['🗼','🏝','🏛','🌆','🗽','🏔','🌴','🎌'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DISCOVER',
                      style: TextStyle(fontSize: 11,
                          color: const Color(0xFFD4AF37).withOpacity(0.8),
                          letterSpacing: 3.0, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('Destinations',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                          color: Color(0xFFEAE6D7), fontFamily: 'Georgia')),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Color(0xFFEAE6D7)),
                    onChanged: (v) => _load(search: v),
                    decoration: InputDecoration(
                      hintText: 'Search destinations...',
                      hintStyle: TextStyle(
                          color: const Color(0xFFEAE6D7).withOpacity(0.25)),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFFD4AF37), size: 20),
                      filled: true,
                      fillColor: const Color(0xFF131929),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF1E2540))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF1E2540))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFD4AF37), width: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(
                      color: Color(0xFFD4AF37)))
                  : _destinations.isEmpty
                      ? Center(
                          child: Text('No destinations found',
                              style: TextStyle(
                                  color: const Color(0xFFEAE6D7).withOpacity(0.4))))
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _destinations.length,
                          itemBuilder: (context, index) {
                            final d = _destinations[index];
                            final emoji = _emojis[index % _emojis.length];
                            return GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) =>
                                      DestinationDetailScreen(
                                          destination: d))),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F1422),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: const Color(0xFF1E2540), width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 110,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD4AF37)
                                            .withOpacity(0.08),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          topRight: Radius.circular(18),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(emoji,
                                            style: const TextStyle(fontSize: 48)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(d['name'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFEAE6D7),
                                                  fontFamily: 'Georgia')),
                                          const SizedBox(height: 4),
                                          Text(d['country'] ?? '',
                                              style: TextStyle(fontSize: 12,
                                                  color: const Color(0xFFEAE6D7)
                                                      .withOpacity(0.4))),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD4AF37)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: const Color(0xFFD4AF37)
                                                      .withOpacity(0.3)),
                                            ),
                                            child: Text(d['category'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFFD4AF37),
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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