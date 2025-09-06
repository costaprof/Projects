import 'zutat.dart';

class ListZutat extends Zutat{

  final double anzahl;
  /*final*/ bool erledigt;
  
  ListZutat({
    required super.id,
    required super.name,
    required super.einheit,
    required this.anzahl,
    required this.erledigt
});

  factory ListZutat.fromSqfliteDatabase(Map<String, dynamic> map) {
    return ListZutat(
      id: map['zutatID'],
      name: map['name'],
      einheit: map['einheit'],
      anzahl: double.parse(map['anzahl'].toString()),
      erledigt: map['erledigt']==0?false:true
    );
  }
}