import '../models/zutat.dart';
import './database_service.dart';

class ZutatenTable {
  static int idCounter = 0;

  Future<int> addZutat(
      {required String name, int id = -1, String einheit = ""}) async {
    // print('ZutatenTable().addZutat(name: name)');
    final database = await DatabaseService().database;
    int zutatId = await getZutatId(name: name, einheit: einheit);
    if (zutatId == -1) {
      await database.insert("Zutaten",
          {"id": id != -1 ? id : '', "name": name, "einheit": einheit});
      return -1;
    } else {
      return zutatId;
    }
  }

  Future<bool> checkIfZutatIdNotExists({required int id}) async {
    // print('ZutatenTable().checkIfZutatIdNotExists(id: id)');
    if (id >= 1) {
      List<Map<String, Object?>> rawZutat = await fetchRawZutatByID(id);
      if (rawZutat.isEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<void> deleteZutat({required int id}) async {
    final database = await DatabaseService().database;
    await database.delete("Zutaten", where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> fetchRawEinheiten() async {
    // print('ZutatenTable().fetchRawZutaten()');
    final database = await DatabaseService().database;
    return await database.query("Zutaten", columns: ["einheit"]);
  }

  Future<List<Map<String, Object?>>> fetchRawZutatByID(int id) async {
    // print('ZutatenTable().fetchRawZutatByID(id)');
    final database = await DatabaseService().database;
    return await database.query("Zutaten",
        columns: ["id", "name", "einheit"], where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> fetchRawZutaten() async {
    // print('ZutatenTable().fetchRawZutaten()');
    final database = await DatabaseService().database;
    return await database.query("Zutaten", columns: ["id", "name", "einheit"]);
  }

  Future<List<String>> fetchEinheiten() async {
    // print('ZutatenTable().fetchZutaten()');
    List<Map<String, Object?>> lEinheiten = await fetchRawEinheiten();
    List<String> ausgabe = [];
    if (lEinheiten.isEmpty) {
      return [];
    } else {
      print('----------------------------------------------------------------');
      print('Einheiten');
      print("einheit");
      for (var zutat in lEinheiten) {
        String lString = zutat['einheit'].toString();
        ausgabe.add(lString);
        print(lString);
      }
      print('----------------------------------------------------------------');
      return ausgabe;
    }
  }

  Future<Zutat> fetchZutatByID({required int id}) async {
    // print('ZutatenTable().fetchRawZutatByID(id)');
    List<Map<String, Object?>> lzutaten = await fetchRawZutatByID(id);

    return Zutat.fromSqfliteDatabase(lzutaten.first);
  }

  Future<List<Zutat>> fetchZutaten() async {
    // print('ZutatenTable().fetchZutaten()');
    List<Map<String, Object?>> lzutaten = await fetchRawZutaten();
    if (lzutaten.isEmpty) {
      return [];
    } else {
      print('----------------------------------------------------------------');
      print('Zutaten');
      print("id | name | einheit");
      for (var zutat in lzutaten) {
        print(
            '${zutat['id'].toString()} | ${zutat['name'].toString()} | ${zutat['einheit'].toString()}');
      }
      print('----------------------------------------------------------------');
      return lzutaten.map((zutat) => Zutat.fromSqfliteDatabase(zutat)).toList();
    }
  }

  Future<int> getIdCounter() async {
    print('ZutatenTable().getIdCounter()');
    bool isIdAvailable = false;
    while (!isIdAvailable) {
      ZutatenTable.idCounter += 1;
      if (await checkIfZutatIdNotExists(id: ZutatenTable.idCounter)) {
        isIdAvailable = true;
      }
    }
    return ZutatenTable.idCounter;
    // final database = await DatabaseService().database;
    // List<Map<String, Object?>> map = await database.query('sqlite_sequence',
    // columns: ["*"],
    // where: "name = 'Zutaten'");
    // int idCounter = int.parse(map.first['seq'].toString());
    // return idCounter+1;
  }

  Future<int> getZutatId(
      {required String name, required String einheit}) async {
    // print('ZutatenTable().getZutatId(name: name, einheit: einheit)');
    final database = await DatabaseService().database;
    List<Map<String, Object?>> rawZutat = await database.query("Zutaten",
        columns: ["id", "name", "einheit"],
        where: 'name = ? AND einheit = ?',
        whereArgs: [name, einheit]);
    if (rawZutat.isEmpty) {
      return -1;
    } else {
      Map<String, Object?> map = rawZutat.first;

      return int.parse(map['id'].toString());
    }
  }
}
