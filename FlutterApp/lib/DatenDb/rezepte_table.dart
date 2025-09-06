import 'package:flutter/services.dart';

import '../models/rezept.dart';
import '../services/my_food_db.dart';
import './zutaten_table.dart';
import 'database_service.dart';
import 'rezept_zutaten_table.dart';

class RezepteTable {
  static int idCounter = 2;
  MealApiService mealApiService = MealApiService();
  RezeptZutatenTable rezeptZutatenTable = RezeptZutatenTable();
  ZutatenTable zutatenTable = ZutatenTable();

  Future addRezept({required String name,
    required int id,
    required String zubereitung,
    required String notizen,
    required image}) async {
    // print('RezepteTable().addRezept(name: name, id: id, zubereitung: zubereitung, notizen: notizen, image: image)');
    final database = await DatabaseService().database;
    if(id==-1){
      await database.insert("Rezepte", {
        "name": name,
        "bewertung": -1.0,
        "zubereitung": zubereitung,
        "notizen": notizen,
        "image": image
      });
    }else if (await checkIfRezeptIdNotExists(id: id)) {
      await database.insert("Rezepte", {
        "id": id,
        "name": name,
        "bewertung": -1.0,
        "zubereitung": zubereitung,
        "notizen": notizen,
        "image": image
      });
    } else {
      // when editing a recipe already in the collection
      await RezepteTable().updateRezept(
        id: id,
        name: name,
        zubereitung: zubereitung,
        notizen: notizen,
      );
    }
  }

  Future addRezeptFromMfdId({required int id}) async {
    // print('DatenDb().addRezeptFromMfdId(id: id)');
    final response = await mealApiService.lookupMealById(id.toString());
    if (response != null && response['meals'] != null) {
      final map = response['meals'][0];
      int idMeal = int.parse(map['idMeal']);
      String imageUrl = map['strMealThumb'];

      try{
        final ByteData data1 =
        await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
        Uint8List bytes = data1.buffer.asUint8List();
        await addRezept(
            id: idMeal,
            name: map['strMeal'],
            zubereitung: map['strMeal'],
            notizen: "",
            image: bytes);

        for (int i = 1; i <= 20; i++) {
          final ingredient = map['strIngredient$i'];
          final measureRaw = map['strMeasure$i'];
          if (ingredient != null && ingredient.isNotEmpty) {
            var (anzahl, measure) =
            splitApiMeasure(measureRaw: measureRaw);

            int zutatID =
            await zutatenTable.getZutatId(name: ingredient, einheit: measure);
            if (zutatID == -1) {
              zutatID = idMeal*100+i;
              await zutatenTable.addZutat(
                  id: zutatID, name: ingredient, einheit: measure);
            }
            await rezeptZutatenTable.addZutatZuRezept(
                rezeptID: idMeal, zutatID: zutatID, anzahl: anzahl);
          }
        }
      }catch(error){
        print('Error fetching NetworkAssetBundle: $error');
      }
    }
  }

  (double, String) splitApiMeasure({required String measureRaw}) {
    // print('RezepteTable().splitApiMeasure(measureRaw: measureRaw)');
    String measure = "";
    String splittedMeasure2nd = "";
    double anzahl = 1.0;
    List<String> splittedMeasure = measureRaw.toString().split(' ');
    int zahlenabschnitte = 0;
    for (var measure in splittedMeasure) {
      if (double.tryParse(measure.replaceAll(RegExp(r'[^0-9]'), '')) !=
          null) zahlenabschnitte += 1;
    }
    if (zahlenabschnitte <= 1) {
      for (int i = 1; i < splittedMeasure.length; i++) {
        splittedMeasure2nd += ("${splittedMeasure.elementAt(i)} ");
      }
      final anzahlRaw = double.tryParse(splittedMeasure.elementAt(0));
      measure = splittedMeasure2nd;
      if (anzahlRaw != null) {
        anzahl = anzahlRaw;
      } else if (splittedMeasure.elementAt(0).contains('/')) {
        List<String> bruchzahl = splittedMeasure.elementAt(0).split('/');
        var zahl0 = double.tryParse(bruchzahl.elementAt(0));
        var zahl1 = double.tryParse(bruchzahl.elementAt(1));
        if (bruchzahl.length == 2 && zahl0 != null && zahl1 != null) {
          anzahl = zahl0 / zahl1;
        }
      }
      /*¼ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u00bc')) {
        anzahl = 1 / 4;
      }
      /*½ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u00bd')) {
        anzahl = 1 / 2;
      }
      /*¾ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u00be')) {
        anzahl = 3 / 4;
      }
      /*⅐ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u2150')) {
        anzahl = 1 / 7;
      }
      /*⅑ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u2151')) {
        anzahl = 1 / 9;
      }
      /*⅒ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u2152')) {
        anzahl = 1 / 10;
      }
      /*⅓ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u2153')) {
        anzahl = 1 / 3;
      }
      /*⅔ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u2154')) {
        anzahl = 2 / 3;
      }
      /*⅕ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u2155')) {
        anzahl = 1 / 5;
      }
      /*⅖ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u2156')) {
        anzahl = 2 / 5;
      }
      /*⅗ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u2157')) {
        anzahl = 3 / 5;
      }
      /*⅘ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u2158')) {
        anzahl = 4 / 5;
      }
      /*⅙ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u2159')) {
        anzahl = 1 / 6;
      }
      /*⅚ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u215A')) {
        anzahl = 5 / 6;
      }
      /*⅛ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u215B')) {
        anzahl = 1 / 8;
      }
      /*⅜ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u215C')) {
        anzahl = 3 / 8;
      }
      /*⅞ abfangen*/ else if (splittedMeasure
          .elementAt(0)
          .contains('\u215E')) {
        anzahl = 7 / 8;
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
    return (anzahl, measure);
  }

  Future<bool> checkIfIsMfdId({required int id}) async {
    // print('RezepteTable().checkIfIsMfdId(id: id)');
    final response = await mealApiService.lookupMealById(id.toString());
    return (response == null || response['meals'] == null);
  }

  Future<bool> checkIfRezeptIdNotExists({required int id}) async {
    // print('RezepteTable().checkIfRezeptIdNotExists(id: id)');
    if (id >= 1) {
      List<Map<String, Object?>> rawRezept = await fetchRawRezeptByID(id: id);
      if (rawRezept.isEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<void> deleteRezept({required int id}) async {
    // print('RezepteTable().deleteRezept(id: id)');
    final database = await DatabaseService().database;
    await database.delete("Rezepte", where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> fetchRawRezepte() async {
    // print('RezepteTable().fetchRawRezepte()');
    final database = await DatabaseService().database;
    //return await database.rawQuery(
    //    '''SELECT * from Rezepte ORDER BY COALESCE(id,name,bewertung,zubereitung,notizen,image)''');
    return await database.query("Rezepte", columns: [
      "id",
      "name",
      "bewertung",
      "zubereitung",
      "notizen",
      "image"
    ]);
  }

  Future<List<Rezept>> fetchRezepte() async {
    // print('RezepteTable().fetchRezepte()');
    List<Map<String, Object?>> lRawRezepte = await fetchRawRezepte();
    if (lRawRezepte.isEmpty) {
      return [];
    } else {
      print('----------------------------------------------------------------');
      print('Rezepte');
      print("id | name | bewertung ");
      for (var rezept in lRawRezepte) {
        print(
            '${rezept['id'].toString()} | ${rezept['name']
                .toString()} | ${rezept['bewertung'].toString()}');
      }
      print('----------------------------------------------------------------');

      List<Rezept> lRezepte = lRawRezepte
          .map((rezept) => Rezept.fromSqfliteDatabase(rezept))
          .toList();
      for (var rezept in lRezepte) {
        rezept.zutaten =
        await rezeptZutatenTable.fetchZutatenByID(rezeptID: rezept.id);
      }
      return lRezepte;
    }
  }

  Future<List<Map<String, Object?>>> fetchRawRezeptByID(
      {required int id}) async {
    // print('RezepteTable().fetchRawRezeptByID(id: id)');
    final database = await DatabaseService().database;
    //return await database.rawQuery('''SELECT * from Rezepte WHERE id = ?''', [id]);
    return await database.query("Rezepte",
        columns: ["id", "name", "bewertung", "zubereitung", "notizen", "image"],
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<Rezept?> fetchRezeptByID({required int id}) async {
    // print('RezepteTable().fetchRezeptByID(id: id)');
    final rawRezept = await fetchRawRezeptByID(id: id);
    if(rawRezept.isEmpty){
      return null;
    }else{
      Rezept lRezept = Rezept.fromSqfliteDatabase(rawRezept.first);
      lRezept.zutaten =
      await rezeptZutatenTable.fetchZutatenByID(rezeptID: lRezept.id);
      return lRezept;
    }
  }

  Future<int> getIdCounter() async {
    // print('RezepteTable().getIdCounter()');
    bool isIdAvailable = false;
    while (!isIdAvailable) {
      RezepteTable.idCounter += 1;
      if (await checkIfRezeptIdNotExists(id: RezepteTable.idCounter)) {
        if (await checkIfIsMfdId(id: RezepteTable.idCounter)) {
          isIdAvailable = true;
        }
      }
    }
    return RezepteTable.idCounter;
  }

  Future<void> updateRezept({required int id,
    String name = "",
    double bewertung = -1,
    String zubereitung = "",
    String notizen = ""}) async {
    // print('RezepteTable().updateRezept(id: id)');
    final database = await DatabaseService().database;
    if (name != "") {
      await database.update("Rezepte", {'name': name},
          where: 'id = ?', whereArgs: [id]);
    }
    if (bewertung != -1) {
      await database.update("Rezepte", {'bewertung': bewertung},
          where: 'id = ?', whereArgs: [id]);
    }
    if (zubereitung != "") {
      await database.update("Rezepte", {'zubereitung': zubereitung},
          where: 'id = ?', whereArgs: [id]);
    }
    if (notizen != -1) {
      await database.update("Rezepte", {'notizen': notizen},
          where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> updateRezeptImage(
      {required int id, required Uint8List image}) async {
    // print('RezepteTable().updateRezeptImage(id: id, image: image)');
    final database = await DatabaseService().database;
    await database.update("Rezepte", {'image': image},
        where: 'id = ?', whereArgs: [id]);
  }
}