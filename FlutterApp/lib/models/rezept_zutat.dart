
class RezeptZutat {
  // final int rezeptID;
  final int zutatID;
  final String name;
  double anzahl;
  final String einheit;
  RezeptZutat(
      {/*required this.rezeptID,*/
      required this.zutatID,
      required this.name,
      required this.anzahl,
      required this.einheit});

  factory RezeptZutat.fromSqfliteDatabase(Map<String, dynamic> map) =>
      RezeptZutat(
          // rezeptID: map['rezeptID'],
          zutatID: map['zutatID'],
          name: map['name'],
          anzahl: map['anzahl'],
          einheit: map['einheit']
      );
}
