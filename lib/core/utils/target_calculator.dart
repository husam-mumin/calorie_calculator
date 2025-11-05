class TargetResult {
  final double bmr;
  final double tdee;
  final double targetCalories;
  final Map<String, double> macros; // grams
  final String formula;
  final double activityMultiplier;

  TargetResult({
    required this.bmr,
    required this.tdee,
    required this.targetCalories,
    required this.macros,
    required this.formula,
    required this.activityMultiplier,
  });
}

class TargetCalculator {
  static const _activityMultipliers = <String, double>{
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'very': 1.725,
    'extra': 1.9,
  };

  static TargetResult calculate({
    required String gender,
    required int age,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
    required String goal, // lose/maintain/gain
    double targetRateKgPerWeek = 0.5,
    Map<String, int> macroSplit = const {'carbs': 50, 'protein': 25, 'fat': 25},
  }) {
    // Mifflin–St Jeor
    double bmr;
    if (gender == 'male') {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }

    final mult = _activityMultipliers[activityLevel] ?? 1.2;
    final tdee = bmr * mult;

    // Adjust for goal
    // Roughly 7700 kcal per kg of fat; per week => per day adjustment
    final dailyAdj = (7700 * targetRateKgPerWeek) / 7.0;
    double target = tdee;
    if (goal == 'lose') target -= dailyAdj;
    if (goal == 'gain') target += dailyAdj;

    target = target.clamp(1000, 5000);

    // Macros in grams from percentages (carb/protein 4 kcal/g, fat 9 kcal/g)
    final carbsCal = target * (macroSplit['carbs']! / 100);
    final proteinCal = target * (macroSplit['protein']! / 100);
    final fatCal = target * (macroSplit['fat']! / 100);
    final macros = <String, double>{
      'carbs': carbsCal / 4,
      'protein': proteinCal / 4,
      'fat': fatCal / 9,
    };

    return TargetResult(
      bmr: bmr,
      tdee: tdee,
      targetCalories: target,
      macros: macros,
      formula: 'Mifflin–St Jeor',
      activityMultiplier: mult,
    );
  }
}
