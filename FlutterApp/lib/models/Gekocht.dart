// lib/models/gekocht.dart

class Gekocht {
  final DateTime datum;
  final String rezept;

  Gekocht({
    required this.datum,
    required this.rezept,
  });

  // Convert a Gekocht into a Map. The keys must correspond to the field names.
  Map<String, dynamic> toJson() {
    return {
      'datum': datum.toIso8601String(),
      'rezept': rezept,
    };
  }

  // A method that converts a map into a Gekocht instance.
  factory Gekocht.fromJson(Map<String, dynamic> json) {
    return Gekocht(
      datum: DateTime.parse(json['datum']),
      rezept: json['rezept'],
    );
  }
}
