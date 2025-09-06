class Suchbegriff{
  final int id;
  final DateTime datetime;
  final String suchbegriff;

  Suchbegriff({
    required this.id,
    required this.datetime,
    required this.suchbegriff
});

  factory Suchbegriff.fromSqfliteDatabase(Map<String, dynamic> map){
    return Suchbegriff(
        id: int.parse(map['id'].toString()),
        datetime: DateTime.fromMillisecondsSinceEpoch(int.parse(map['datetime'].toString())),
        suchbegriff: map['suchbegriff']);
  }
}