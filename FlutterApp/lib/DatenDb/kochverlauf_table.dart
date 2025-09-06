import 'database_service.dart';
import '../models/date_rezept.dart';
import 'rezepte_table.dart';

class KochverlaufTable {
  RezepteTable rezepteTable = RezepteTable();

  Future<void> addToKochverlauf(
      {required int rezeptID, required DateTime datetime}) async {
    final database = await DatabaseService().database;
    if (!await rezepteTable.checkIfRezeptIdNotExists(id: rezeptID)) {
      if (await fetchKochverlaufById(rezeptID: rezeptID) == null) {
        await database.insert("Kochverlauf", {
          "rezeptID": rezeptID,
          "datetime": datetime.millisecondsSinceEpoch.toInt()
        });
      }
    }
  }

  Future<void> deleteFromKochverlauf({required int rezeptID}) async {
    // print('MeineRezepteTable().deleteFromMeineRezepte(rezeptID: rezeptID)');
    final database = await DatabaseService().database;
    await database
        .delete("Kochverlauf", where: 'rezeptID = ?', whereArgs: [rezeptID]);
  }

  Future<List<Map<String, Object?>>> fetchRawKochverlaufById(
      {required int rezeptID}) async {
    final database = await DatabaseService().database;
    return await database.rawQuery(
        """SELECT rezeptID,datetime,name,bewertung,zubereitung,notizen,image FROM Rezepte JOIN Kochverlauf ON Rezepte.id = Kochverlauf.rezeptID WHERE rezeptID = ?;""",
        [rezeptID]);
  }

  Future<DateRezept?> fetchKochverlaufById({required int rezeptID}) async {
    List<Map<String, Object?>> lRawDateRezept =
        await fetchRawKochverlaufById(rezeptID: rezeptID);
    if (lRawDateRezept.isEmpty) {
      return null;
    } else {
      return DateRezept.fromSqfliteDatabase(lRawDateRezept.first);
    }
  }

  Future<List<Map<String, Object?>>> fetchRawKochverlauf() async {
    final database = await DatabaseService().database;
    return await database.rawQuery(
        """SELECT rezeptID,datetime,name,bewertung,zubereitung,notizen,image FROM Rezepte JOIN Kochverlauf ON Rezepte.id = Kochverlauf.rezeptID;""");
  }

  Future<List<DateRezept>> fetchKochverlauf() async {
    // print('RezeptZutatenTable().fetchZutaten()');
    List<Map<String, Object?>> lRawDateRezepte = await fetchRawKochverlauf();
    if (lRawDateRezepte.isEmpty) {
      return [];
    } else {
      print('----------------------------------------------------------------');
      print('Kochverlauf');
      print("rezeptID | datetime | name | bewertung");
      for (var zutat in lRawDateRezepte) {
        print(
            '${zutat['rezeptID'].toString()} | ${zutat['datetime'].toString()} | ${zutat['name'].toString()} | ${zutat['bewertung'].toString()}');
      }
      print('----------------------------------------------------------------');
      return lRawDateRezepte
          .map((rezeptZutat) => DateRezept.fromSqfliteDatabase(rezeptZutat))
          .toList();
    }
  }
}
