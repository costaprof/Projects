import '../models/suchbegriff.dart';
import 'database_service.dart';

class StichwortsuchverlaufTable {
  static int idCounter = 2;

  Future<void> addSuchbegriff(
      {int id = -1, required String suchbegriff}) async {
    final database = await DatabaseService().database;
    if(id==-1){
      await database.insert("Stichwortsuchverlauf", {
        "datetime": DateTime.now().millisecondsSinceEpoch.toInt(),
        "suchbegriff": suchbegriff
      });
    }else{
      await database.insert("Stichwortsuchverlauf", {
        "id": id,
        "datetime": DateTime.now().millisecondsSinceEpoch.toInt(),
        "suchbegriff": suchbegriff
      });
    }
  }

  Future<bool> checkIfRezeptIdNotExists({required int id}) async {
    if (id >= 1) {
      List<Map<String, Object?>> rawRezept =
          await fetchRawSuchverlaufByID(id: id);
      if (rawRezept.isEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<List<Map<String, Object?>>> fetchRawSuchverlauf() async {
    final database = await DatabaseService().database;
    return await database.query("Stichwortsuchverlauf",
        columns: ["id", "datetime", "suchbegriff"]);
  }

  Future<List<Map<String, Object?>>> fetchRawSuchverlaufByID(
      {required int id}) async {
    final database = await DatabaseService().database;
    return await database.query("Stichwortsuchverlauf",
        columns: ["id", "datetime", "suchbegriff"],
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> fetchRawSuchverlaufBySuchbegriff(
      {required String suchbegriff}) async {
    final database = await DatabaseService().database;
    return await database.query("Stichwortsuchverlauf",
        columns: ["id", "datetime", "suchbegriff"],
        where: 'suchbegriff = ?',
        whereArgs: [suchbegriff]/*,
        orderBy: "datetime ASC"*/);
    // return await database.rawQuery("""SELECT id,datetime,suchbegriff FROM Stichwortsuchverlauf ORDER BY datetime""");
  }

  Future<List<Suchbegriff>> fetchSuchverlauf() async {
    final rawSuchverlauf = await fetchRawSuchverlauf();
    if (rawSuchverlauf.isEmpty) {
      return [];
    } else {
      print('----------------------------------------------------------------');
      print('Stichwortsuchverlauf');
      print("id | datetime | suchbegriff ");
      for (var suchbegriff in rawSuchverlauf) {
        print(
            '${suchbegriff['id'].toString()} | ${suchbegriff['datetime']
                .toString()} | ${suchbegriff['suchbegriff'].toString()}');
      }
      print('----------------------------------------------------------------');
      return rawSuchverlauf
          .map((suchverlauf) => Suchbegriff.fromSqfliteDatabase(suchverlauf))
          .toList();
    }
  }

  Future<Suchbegriff?> fetchSuchverlaufByID({required int id}) async {
    final rawSuchverlauf = await fetchRawSuchverlauf();
    if (rawSuchverlauf.isEmpty) {
      return null;
    } else {
      return Suchbegriff.fromSqfliteDatabase(rawSuchverlauf.first);
    }
  }

  Future<int> getIdCounter() async {
    bool isIdAvailable = false;
    while (!isIdAvailable) {
      StichwortsuchverlaufTable.idCounter += 1;
      if (await checkIfRezeptIdNotExists(
          id: StichwortsuchverlaufTable.idCounter)) {
        isIdAvailable = true;
      }
    }
    return StichwortsuchverlaufTable.idCounter;
  }

  Future<int> getIdBySuchbegriff({required String suchbegriff}) async {
    final rawSuchverlauf = await fetchRawSuchverlaufBySuchbegriff(suchbegriff: suchbegriff);
    int? id;
    if(rawSuchverlauf.isEmpty){
      return -1;
    }else{
      int id = int.parse(rawSuchverlauf.first['id'].toString());
      return id;
    }
  }

  Future<void> updateSuchbegriffDate(
      {required int id}) async {
    final database = await DatabaseService().database;
    database.update("Stichwortsuchverlauf",
        {"datetime": DateTime.now().millisecondsSinceEpoch.toInt()},
        where: 'id = ?', whereArgs: [id]);
  }

  // Future<void> deleteSuchbegriff({required int id}) async {}
}
