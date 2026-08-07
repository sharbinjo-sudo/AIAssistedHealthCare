class DashboardData {
  const DashboardData({
    required this.healthScore,
    required this.bmi,
    required this.bioAge,
    required this.bp,
    required this.heartRate,
    required this.sleep,
    required this.steps,
    required this.water,
    required this.calories,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
        healthScore: json['healthScore'] as int,
        bmi: (json['bmi'] as num).toDouble(),
        bioAge: json['bioAge'] as int,
        bp: json['bp'] as String,
        heartRate: json['heartRate'] as int,
        sleep: (json['sleep'] as num).toDouble(),
        steps: json['steps'] as int,
        water: json['water'] as String,
        calories: json['calories'] as int,
      );

  final int healthScore;
  final double bmi;
  final int bioAge;
  final String bp;
  final int heartRate;
  final double sleep;
  final int steps;
  final String water;
  final int calories;
}
