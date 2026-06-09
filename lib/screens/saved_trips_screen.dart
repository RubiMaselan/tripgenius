import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import '../services/api_service.dart';
import 'itinerary_screen.dart';

class SavedTripsScreen extends StatefulWidget {
  const SavedTripsScreen({super.key});
  @override
  State<SavedTripsScreen> createState() => _SavedTripsScreenState();
}

class _SavedTripsScreenState extends State<SavedTripsScreen> {
  final _apiService = ApiService();
  List<Itinerary> _trips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);
    try {
      final trips = await _apiService.getSavedTrips();
      setState(() => _trips = trips);
    } catch (e) {
      setState(() => _trips = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteTrip(String id) async {
    await _apiService.deleteTrip(id);
    _loadTrips();
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MY TRIPS',
                      style: TextStyle(fontSize: 11,
                          color: const Color(0xFFD4AF37).withOpacity(0.8),
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('Saved Journeys',
                      style: TextStyle(fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEAE6D7),
                          fontFamily: 'Georgia')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(
                      color: Color(0xFFD4AF37)))
                  : _trips.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🗺️',
                                  style: TextStyle(fontSize: 64)),
                              const SizedBox(height: 16),
                              const Text('No saved trips yet',
                                  style: TextStyle(fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEAE6D7),
                                      fontFamily: 'Georgia')),
                              const SizedBox(height: 8),
                              Text('Generate your first itinerary!',
                                  style: TextStyle(
                                      color: const Color(0xFFEAE6D7)
                                          .withOpacity(0.4))),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                          itemCount: _trips.length,
                          itemBuilder: (context, index) {
                            final trip = _trips[index];
                            return _TripCard(
                              trip: trip,
                              onDelete: () => _deleteTrip(trip.id),
                              onTap: () => Navigator.push(context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, a, __) =>
                                        ItineraryScreen(itinerary: trip),
                                    transitionsBuilder: (_, anim, __, child) =>
                                        FadeTransition(opacity: anim, child: child),
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                  )),
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

class _TripCard extends StatelessWidget {
  final Itinerary trip;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _TripCard({required this.trip, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1422),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1E2540), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
              ),
              child: const Center(
                  child: Text('✈️', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.destination,
                    style: const TextStyle(fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEAE6D7),
                        fontFamily: 'Georgia')),
                const SizedBox(height: 4),
                Row(children: [
                  _pill('${trip.days} days'),
                  const SizedBox(width: 6),
                  _pill('${trip.createdAt.day}/${trip.createdAt.month}/${trip.createdAt.year}'),
                ]),
              ],
            )),
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF131929),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('Delete trip?',
                      style: TextStyle(color: Color(0xFFEAE6D7),
                          fontFamily: 'Georgia')),
                  content: Text('Remove ${trip.destination}?',
                      style: const TextStyle(color: Color(0xFF4A5270))),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(color: Color(0xFF4A5270)))),
                    TextButton(
                        onPressed: () { Navigator.pop(context); onDelete(); },
                        child: const Text('Delete',
                            style: TextStyle(color: Color(0xFFEF4444)))),
                  ],
                ),
              ),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.2), width: 1),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Color(0xFFEF4444), size: 16),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2035),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 11, color: Color(0xFF4A5270))),
      );
}