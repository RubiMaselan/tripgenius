import 'package:flutter/material.dart';
import '../models/itinerary.dart';

class ItineraryScreen extends StatelessWidget {
  final Itinerary itinerary;
  const ItineraryScreen({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF0F1422),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF1E2540), width: 1),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Color(0xFFEAE6D7), size: 16),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0F1422),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              const Color(0xFFD4AF37).withOpacity(0.06),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            itinerary.destination.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFD4AF37),
                              letterSpacing: 3.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Your Itinerary',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEAE6D7),
                              fontFamily: 'Georgia',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _chip(Icons.calendar_today_outlined,
                                  '${itinerary.days} Days'),
                              const SizedBox(width: 10),
                              _chip(Icons.auto_awesome_outlined,
                                  'AI Generated'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final day = itinerary.plan[index];
                  return _DayCard(day: day, index: index);
                },
                childCount: itinerary.plan.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFFD4AF37)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
}

class _DayCard extends StatefulWidget {
  final DayPlan day;
  final int index;
  const _DayCard({required this.day, required this.index});

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 100),
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1422),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF1E2540), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: Color(0xFF1E2540), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              const Color(0xFFD4AF37).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.day.day}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Day ${widget.day.day}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEAE6D7),
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ],
                ),
              ),
              // Time slots
              _TimeSlot(
                emoji: '🌅',
                label: 'MORNING',
                content: widget.day.morning,
                isLast: false,
              ),
              _TimeSlot(
                emoji: '☀️',
                label: 'AFTERNOON',
                content: widget.day.afternoon,
                isLast: false,
              ),
              _TimeSlot(
                emoji: '🌙',
                label: 'EVENING',
                content: widget.day.evening,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String emoji;
  final String label;
  final String content;
  final bool isLast;

  const _TimeSlot({
    required this.emoji,
    required this.label,
    required this.content,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                    color: Color(0xFF1A2035), width: 1)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 6),
              Container(
                width: 1,
                height: 40,
                color: isLast
                    ? Colors.transparent
                    : const Color(0xFF1E2540),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD4AF37),
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFFEAE6D7).withOpacity(0.75),
                    height: 1.6,
                    fontFamily: 'Georgia',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}