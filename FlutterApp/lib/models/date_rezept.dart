import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'rezept.dart';

class DateRezept extends Rezept{
  final DateTime dateTime;

  DateRezept({
    required super.id,
    required super.name,
    super.bewertung = -1,
    required super.zubereitung,
    super.notizen = "",
    required super.image,
    required super.zutaten,
    required this.dateTime
  });

  factory DateRezept.fromSqfliteDatabase(Map<String, dynamic> map) => DateRezept(
    id: int.tryParse(map['id'].toString()) ?? -1,
    name: map['name'] ?? '',
    bewertung: map['bewertung']?.toDouble() ?? -1.0,
    zubereitung: map['zubereitung'] ?? '',
    notizen: map['notizen'] ?? '',
    image: Image.memory(Uint8List.fromList(map['image']),gaplessPlayback: true,),
    zutaten: [],
    dateTime: DateTime.fromMillisecondsSinceEpoch(int.parse(map['datetime'].toString()))
  );

  Widget getDate(){
    return Text(DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(dateTime),
        style: const TextStyle(
        fontSize: 14));
  }
}