import '../models/rezept.dart';
import 'database_service.dart';
import 'rezepte_table.dart';

class MeineRezepteTable {
  RezepteTable rezepteTable = RezepteTable();

  Future<void> addToMeineRezepte({required int rezeptID}) async {
    // print('MeineRezepteTable().addToMeineRezepte(rezeptID: rezeptID)');
    final database = await DatabaseService().database;
    if (!await rezepteTable.checkIfRezeptIdNotExists(id: rezeptID)) {
      if(await fetchMeinRezeptByID(rezeptID: rezeptID)==null){
        await database.insert("MeineRezepte", {"rezeptID": rezeptID});
      }
    }
  }

  Future<void> deleteFromMeineRezepte({required int rezeptID}) async {
    // print('MeineRezepteTable().deleteFromMeineRezepte(rezeptID: rezeptID)');
    final database = await DatabaseService().database;
    await database
        .delete("MeineRezepte", where: 'rezeptID = ?', whereArgs: [rezeptID]);
  }

  Future<List<Map<String, Object?>>> fetchRawMeinRezeptById() async {
    final database = await DatabaseService().database;
    return await database.query("MeineRezepte", columns: ["rezeptID"]);
  }

  Future<Rezept?> fetchMeinRezeptByID({required int rezeptID}) async{
    List<Map<String, Object?>> lRawRezepte = await fetchRawMeinRezeptById();
    if(lRawRezepte.isEmpty){
      return null;
    }else{
      return await RezepteTable().fetchRezeptByID(id: rezeptID);
    }
  }

  Future<List<Map<String, Object?>>> fetchRawMeineRezepte() async {
    final database = await DatabaseService().database;
    return await database.query("MeineRezepte", columns: ["rezeptID"]);
  }

  Future<List<Rezept>> fetchMeineRezepte() async {
    // print('RezepteTable().fetchRezepte()');
    List<Map<String, Object?>> lRawRezepte = await fetchRawMeineRezepte();
    List<Rezept> lMeineRezepte = [];
    if (lRawRezepte.isEmpty) {
      return [];
    } else {
      print('----------------------------------------------------------------');
      print('MeineRezepte');
      print("rezeptID");
      for (var rezept in lRawRezepte) {
        final String sRezeptId = rezept['rezeptID'].toString();
        final int iRezeptID = int.parse(sRezeptId);
        final Rezept? lRezept =
            await RezepteTable().fetchRezeptByID(id: iRezeptID);
        print(sRezeptId);
        if (lRezept != null) {
          lMeineRezepte.add(lRezept);
        }
      }
      print('----------------------------------------------------------------');
      return lMeineRezepte;
    }
  }
}
