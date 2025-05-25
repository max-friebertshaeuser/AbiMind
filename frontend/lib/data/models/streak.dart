class StreakDay {
  final DateTime date;
  final int minutes;
  final int goal;

  StreakDay({
    required this.date,
    required this.minutes,
    required this.goal,
  });

  double get progressPercent =>
      goal == 0 ? 0 : minutes / goal;
}