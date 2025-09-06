import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './rezept_zutat.dart';

class Rezept {
  final int id;
  final String name;
  final double bewertung;
  final String zubereitung;
  final String notizen;
  final Image image;
  List<RezeptZutat> zutaten;

  Rezept({
    required this.id,
    required this.name,
    this.bewertung = -1,
    required this.zubereitung,
    this.notizen = "",
    required this.image,
    required this.zutaten,
  });

  factory Rezept.fromSqfliteDatabase(Map<String, dynamic> map) => Rezept(
        id: int.tryParse(map['id'].toString()) ?? -1,
        name: map['name'] ?? '',
        bewertung: map['bewertung']?.toDouble() ?? -1.0,
        zubereitung: map['zubereitung'] ?? '',
        notizen: map['notizen'] ?? '',
        image: Image.memory(Uint8List.fromList(map['image']),
            gaplessPlayback: true),
        zutaten: [],
      );

  factory Rezept.fromMFDresponse(Map<String, dynamic> map) {
    List<RezeptZutat> zutaten = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = map['strIngredient$i'];
      final measureRaw = map['strMeasure$i'];
      String measure = "";
      String splittedMeasure2nd = "";
      double anzahl = 1.0;
      if (ingredient != null && ingredient.isNotEmpty) {
        List<String> splittedMeasure = measureRaw.toString().split(' ');
        int zahlenabschnitte = 0;
        for (var measure in splittedMeasure) {
          if (double.tryParse(measure) != null) zahlenabschnitte += 1;
        }
        if (zahlenabschnitte <= 1) {
          for (int i = 1; i < splittedMeasure.length; i++) {
            splittedMeasure2nd += ("${splittedMeasure.elementAt(i)} ");
          }
          final anzahlRaw = double.tryParse(splittedMeasure.elementAt(0));
          if (anzahlRaw != null) {
            anzahl = anzahlRaw;
            measure = splittedMeasure2nd;
          } else if (splittedMeasure.elementAt(0).contains('/')) {
            List<String> bruchzahl = splittedMeasure.elementAt(0).split('/');
            var zahl0 = double.tryParse(bruchzahl.elementAt(0));
            var zahl1 = double.tryParse(bruchzahl.elementAt(1));
            if (bruchzahl.length == 2 && zahl0 != null && zahl1 != null) {
              anzahl = zahl0 / zahl1;
              measure = splittedMeasure2nd;
            }
          } else if (measureRaw.replaceAll(RegExp(r'[0-9]'), '') == 'g') {
            final anzahlRaw =
                double.tryParse(measureRaw.replaceAll(RegExp(r'[^0-9]'), ''));
            if (anzahlRaw != null) {
              anzahl = anzahlRaw;
              measure = 'gramm';
            }
          }
        } else {
          anzahl = 1.0;
          measure = measureRaw;
        }

        zutaten.add(RezeptZutat(
          zutatID: 0,
          name: ingredient,
          anzahl: anzahl,
          einheit: measure,
        ));
      }
    }

    return Rezept(
      id: int.parse(map['idMeal'].toString()),
      name: map['strMeal'],
      zubereitung: map['strInstructions'] ?? '',
      image: Image.network(map['strMealThumb']),
      zutaten: zutaten,
    );
  }

  Widget getBewertungSterne(
      {double iconSize = 16,
      double fontSize = 16,
      Color textColor = Colors.grey,
      String text1 = 'Bewertung: ',
      String text2 = 'Rezept wurde noch nicht bewertet',
      Color iconColor = Colors.black}) {
    Text text = Text(
      '$text1$bewertung',
      style: TextStyle(fontSize: fontSize, color: textColor),
    );
    if (bewertung > 4.75) {
      return Row(
        children: [
          text,
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
        ],
      );
    } else if (bewertung > 4.25) {
      return Row(
        children: [
          text,
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star_half, color: iconColor, size: iconSize),
        ],
      );
    } else if (bewertung > 3.75) {
      return Row(
        children: [
          text,
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
        ],
      );
    } else if (bewertung > 3.25) {
      return Row(
        children: [
          text,
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star_half, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
        ],
      );
    } else if (bewertung > 2.75) {
      return Row(
        children: [
          text,
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
        ],
      );
    } else if (bewertung > 2.25) {
      return Row(
        children: [
          text,
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star_half, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
        ],
      );
    } else if (bewertung > 1.75) {
      return Row(
        children: [
          text,
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
        ],
      );
    } else if (bewertung > 1.25) {
      return Row(
        children: [
          text,
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star_half, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
        ],
      );
    } else if (bewertung > 0.75) {
      return Row(
        children: [
          text,
          Icon(Icons.star, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
        ],
      );
    } else if (bewertung > 0.25) {
      return Row(
        children: [
          text,
          Icon(Icons.star_half, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
        ],
      );
    } else if (bewertung >= 0.0) {
      return Row(
        children: [
          text,
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
          Icon(Icons.star_border, color: iconColor, size: iconSize),
        ],
      );
    }
    return Container();
  }
}
