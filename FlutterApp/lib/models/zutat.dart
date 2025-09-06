class Zutat {
  final int id;
  String name;
  final String einheit;

  Zutat({
    required this.id,
    required this.name,
    this.einheit = '',
  });

  // Factory method to create a Zutat instance from a map
  factory Zutat.fromSqfliteDatabase(Map<String, dynamic> map) {
    return Zutat(
      id: map['id'],
      name: map['name'] ?? '',
      einheit: map['einheit'] ?? '',
    );
  }

  // Getters
  String get getName => name;

  String get getEinheit => einheit;
}