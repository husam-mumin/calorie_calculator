class MealRecord {
  final int? id;
  final String date; // YYYY-MM-DD
  final String mealType; // breakfast/lunch/dinner/snacks
  final String name;
  final int calories;
  final double? carbs;
  final double? protein;
  final double? fat;

  MealRecord({
    this.id,
    required this.date,
    required this.mealType,
    required this.name,
    required this.calories,
    this.carbs,
    this.protein,
    this.fat,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'date': date,
    'mealType': mealType,
    'name': name,
    'calories': calories,
    'carbs': carbs,
    'protein': protein,
    'fat': fat,
  };

  static MealRecord fromMap(Map<String, Object?> map) => MealRecord(
    id: map['id'] as int?,
    date: map['date'] as String,
    mealType: map['mealType'] as String,
    name: map['name'] as String,
    calories: map['calories'] as int,
    carbs: (map['carbs'] as num?)?.toDouble(),
    protein: (map['protein'] as num?)?.toDouble(),
    fat: (map['fat'] as num?)?.toDouble(),
  );
}
