class DayPlan {
  final int day;
  final String morning;
  final String afternoon;
  final String evening;

  DayPlan({
    required this.day,
    required this.morning,
    required this.afternoon,
    required this.evening,
  });

  factory DayPlan.fromJson(Map<String, dynamic> json) => DayPlan(
        day: json['day'],
        morning: json['morning'],
        afternoon: json['afternoon'],
        evening: json['evening'],
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'morning': morning,
        'afternoon': afternoon,
        'evening': evening,
      };
}

class Itinerary {
  final String id;
  final String destination;
  final int days;
  final List<DayPlan> plan;
  final DateTime createdAt;

  Itinerary({
    required this.id,
    required this.destination,
    required this.days,
    required this.plan,
    required this.createdAt,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) => Itinerary(
        id: json['id'],
        destination: json['destination'],
        days: json['days'],
        plan: (json['plan'] as List).map((e) => DayPlan.fromJson(e)).toList(),
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'destination': destination,
        'days': days,
        'plan': plan.map((e) => e.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
      };
}