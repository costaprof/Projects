import 'package:was_essen/models/list_zutat.dart';

import 'database_service.dart';

class ListZutatenTable {
  final List<String> table = ['Einkaufsliste', 'Inventar'];

  Future<void> addListZutatByID(
      {required int zutatID,
      required String table,
      double anzahl = -1,
      int erledigt = -1}) async {
    // print('ListZutatenTable().addListZutat(zutatID: zutatID, table: table)');
    final database = await DatabaseService().database;
    if (zutatID == -1) {
      database.insert(table, {"anzahl": anzahl, "erledigt": erledigt});
    } else {
      ListZutat? listZutat =
          await fetchListZutatByID(table: table, zutatID: zutatID);
      if (listZutat == null) {
        database.insert(table,
            {"zutatID": zutatID, "anzahl": anzahl, "erledigt": erledigt});
      } else {
        double altAnzahl = listZutat.anzahl;
        await updateListZutat(
            table: table, zutatID: zutatID, anzahl: altAnzahl + anzahl);
      }
    }
  }

  Future<bool> checkIfListZutatIdNotExists(
      {required int zutatID, required String table}) async {
    if (zutatID >= 1) {
      List<Map<String, Object?>> rawListZutaten =
          await fetchRawListZutatByID(zutatID: zutatID, table: table);
      if (rawListZutaten.isEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<void> deleteListZutat(
      {required String table, required int zutatID}) async {
    final database = await DatabaseService().database;
    await database.delete(table, where: 'zutatID = ?', whereArgs: [zutatID]);
  }

  Future<List<Map<String, Object?>>> fetchRawListZutatByID(
      {required int zutatID, required String table}) async {
    // print('ListZutatenTable().fetchRawListZutatByID(zutatID: zutatID, table: table)');
    final database = await DatabaseService().database;
    // return await database.query(table,
    //     columns: ["zutatID", "name", "erledigt"],
    //     where: 'zutatID = ?',
    //     whereArgs: [zutatID]);
    return await database.rawQuery(
        """SELECT id,zutatID,name,einheit,anzahl,erledigt FROM $table JOIN Zutaten ON Zutaten.id = $table.zutatID WHERE zutatID = ?;""", [zutatID]);
  }

  Future<List<Map<String, Object?>>> fetchRawListZutaten(
      {required String table}) async {
    // print('ListZutatenTable().fetchRawListZutaten(table: table)');
    final database = await DatabaseService().database;
    return await database.rawQuery(
        """SELECT id,zutatID,name,einheit,anzahl,erledigt FROM $table JOIN Zutaten ON Zutaten.id = $table.zutatID;""");
  }

  Future<ListZutat?> fetchListZutatByID(
      {required int zutatID, required String table}) async {
    List<Map<String, Object?>> lRawZutaten =
        await fetchRawListZutatByID(zutatID: zutatID, table: table);
    if (lRawZutaten.isEmpty) {
      return null;
    } else {
      return ListZutat.fromSqfliteDatabase(lRawZutaten.first);
    }
  }

  Future<List<ListZutat>> fetchListZutaten({required String table}) async {
    // print('ListZutatenTable().fetchRezepte(table: table)');
    List<Map<String, Object?>> lRawZutaten =
        await fetchRawListZutaten(table: table);
    if (lRawZutaten.isEmpty) {
      return [];
    } else {
      print('----------------------------------------------------------------');
      print(table);
      print("zutatID | anzahl | erledigt ");
      for (var zutat in lRawZutaten) {
        print(
            '${zutat['zutatID'].toString()} | ${zutat['anzahl'].toString()} | ${zutat['erledigt'].toString()}');
      }
      print('----------------------------------------------------------------');
      return lRawZutaten
          .map((rezept) => ListZutat.fromSqfliteDatabase(rezept))
          .toList();
    }
  }

  Future<void> updateListZutat(
      {required String table,
      required int zutatID,
      double anzahl = -1,
      int erledigt = -1}) async {
    final database = await DatabaseService().database;
    if (anzahl != -1) {
      await database.update(table, {'anzahl': anzahl},
          where: 'zutatID = ?', whereArgs: [zutatID]);
    }
    if (erledigt != -1) {
      await database.update(table, {'erledigt': erledigt},
          where: 'zutatID = ?', whereArgs: [zutatID]);
    }
  }
}
