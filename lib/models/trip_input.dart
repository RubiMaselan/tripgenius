class TripInput {
  final String destination;
  final int days;
  final List<String> interests;
  final String budget;

  TripInput({
    required this.destination,
    required this.days,
    required this.interests,
    required this.budget,
  });

  Map<String, dynamic> toJson() => {
        'destination': destination,
        'days': days,
        'interests': interests,
        'budget': budget,
      };
}