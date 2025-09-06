import './zutat.dart';

class MealApiRezept {
  final int id;
  String imagePath;
  String name;
  int bewertung;
  List<Zutat> zutaten;
  String zubereitung;
  String notizen;

  MealApiRezept({
    this.id = 0,
    required this.imagePath,
    required this.name,
    this.bewertung = 0,
    required this.zutaten,
    required this.zubereitung,
    required this.notizen,
  });

  // Factory constructor for creating a new Rezept instance from a map.
  factory MealApiRezept.fromSqfliteDatabase(Map<String, dynamic> map) {
    return MealApiRezept(
      id: int.parse(map['id']) ?? -1,
      imagePath: map['imagePath'] ?? '',
      name: map['name'] ?? '',
      bewertung: int.parse(map['bewertung']) ?? 0,
      zutaten:
          (map['zutaten'] as List).map((item) => Zutat.fromSqfliteDatabase(item)).toList(),
      zubereitung: map['zubereitung'] ?? '',
      notizen: map['notizen'] ?? '',
    );
  }

  // Getters
  String get getImagePath => imagePath;
  String get getName => name;
  int get getBewertung => bewertung;
  List<Zutat> get getZutaten => zutaten;
  String get getZubereitung => zubereitung;
  String get getNotizen => notizen;

  // Setters
  set setImagePath(String newImagePath) {
    imagePath = newImagePath;
  }

  set setName(String newName) {
    name = newName;
  }

  set setBewertung(int newBewertung) {
    bewertung = newBewertung;
  }

  set setZutaten(List<Zutat> newZutaten) {
    zutaten = newZutaten;
  }

  set setZubereitung(String newZubereitung) {
    zubereitung = newZubereitung;
  }

  set setNotizen(String newNotizen) {
    notizen = newNotizen;
  }
}