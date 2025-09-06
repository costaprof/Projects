import '../models/rezept_zutat.dart';
import './database_service.dart';

class RezeptZutatenTable {
  Future addZutatZuRezept(
      {required int rezeptID,
      required int zutatID,
      required double anzahl}) async {
    // print('RezeptZutatenTable().addZutatZuRezept(rezeptID: rezeptID, zutatID: zutatID, anzahl: anzahl)');
    final database = await DatabaseService().database;
    if (await checkIfRezeptIdNotExists(rezeptID: rezeptID, zutatID: zutatID)) {
      await database.insert("RezeptZutaten", {
        "rezeptID": rezeptID,
        "zutatID": zutatID,
        "anzahl": anzahl,
      });
    }
  }

  Future<bool> checkIfRezeptIdNotExists(
      {required int rezeptID, required int zutatID}) async {
    // print('RezeptZutatenTable().checkIfRezeptIdNotExists(rezeptID: rezeptID, zutatID: zutatID)');
    if (rezeptID >= 1) {
      List<Map<String, Object?>> rawRezept = await fetchRawRezeptZutatenByIDs(
          rezeptID: rezeptID, zutatID: zutatID);
      if (rawRezept.isEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<void> deleteRezeptZutaten({required int rezeptID}) async {
    final database = await DatabaseService().database;
    await database.delete("RezeptZutaten", where: 'rezeptID = ?', whereArgs: [rezeptID]);
  }

  Future<List<Map<String, Object?>>> fetchRawRezeptZutatenByIDs(
      {required int rezeptID, required int zutatID}) async {
    // print('RezeptZutatenTable().fetchRawRezeptZutatenByIDs(rezeptID: rezeptID, zutatID: zutatID)');
    final database = await DatabaseService().database;
    return await database.rawQuery(
        """SELECT zutatID,name,anzahl,einheit FROM RezeptZutaten JOIN Zutaten ON Zutaten.id = RezeptZutaten.zutatID WHERE rezeptID = ? AND zutatID = ?;""",
        [rezeptID, zutatID]);
  }

  Future<List<Map<String, Object?>>> fetchRawZutatenByID(
      {required int rezeptID}) async {
    // print('RezeptZutatenTable().fetchRawZutatenByID(rezeptID: rezeptID)');
    final database = await DatabaseService().database;
    return await database.rawQuery(
        """SELECT zutatID,name,anzahl,einheit FROM RezeptZutaten JOIN Zutaten ON Zutaten.id = RezeptZutaten.zutatID WHERE rezeptID = ?;""",
        [rezeptID]);
  }

  Future<List<Map<String, Object?>>> fetchRawZutaten() async {
    // print('RezeptZutatenTable().fetchRawZutaten()');
    final database = await DatabaseService().database;
    return await database.rawQuery(
        """SELECT rezeptID,zutatID,name,anzahl,einheit FROM RezeptZutaten JOIN Zutaten ON Zutaten.id = RezeptZutaten.zutatID ORDER BY rezeptID, zutatID;""");
  }

  Future<List<RezeptZutat>> fetchZutatenByID({required int rezeptID}) async {
    // print('RezeptZutatenTable().fetchZutatenByID(rezeptID: rezeptID)');
    List<Map<String, Object?>> lrezepte =
        await fetchRawZutatenByID(rezeptID: rezeptID);
    if (lrezepte.isEmpty) {
      return [];
    } else {
      return lrezepte
          .map((rezeptZutat) => RezeptZutat.fromSqfliteDatabase(rezeptZutat))
          .toList();
    }
  }

  Future<List<RezeptZutat>> fetchRezeptZutaten() async {
    // print('RezeptZutatenTable().fetchZutaten()');
    List<Map<String, Object?>> lrezepte = await fetchRawZutaten();
    if (lrezepte.isEmpty) {
      return [];
    } else {
      print('----------------------------------------------------------------');
      print('RezeptZutaten');
      print("rezeptID | zutatID | name | anzahl | einheit");
      for (var zutat in lrezepte) {
        print(
            '${zutat['rezeptID'].toString()} | ${zutat['zutatID'].toString()} | ${zutat['name'].toString()} | ${zutat['anzahl'].toString()} | ${zutat['einheit'].toString()}');
      }
      print('----------------------------------------------------------------');
      return lrezepte
          .map((rezeptZutat) => RezeptZutat.fromSqfliteDatabase(rezeptZutat))
          .toList();
    }
  }

  Future<void> updateRezeptZutat(
      {required int rezeptID,
        required int zutatID,
        required double anzahl}) async {

  }
}
