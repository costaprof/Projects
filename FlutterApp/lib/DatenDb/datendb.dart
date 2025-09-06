import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:was_essen/DatenDb/kochverlauf_table.dart';
import 'package:was_essen/DatenDb/list_zutaten_table.dart';
import 'package:was_essen/DatenDb/meine_rezepte_table.dart';

import '../models/date_rezept.dart';
import '../models/list_zutat.dart';
import '../models/rezept.dart';
import '../models/rezept_zutat.dart';
import '../models/suchbegriff.dart';
import '../models/zutat.dart';
import '../services/my_food_db.dart';
import 'rezept_zutaten_table.dart';
import 'rezepte_table.dart';
import 'stichwortsuchverlauf_table.dart';
import 'zutaten_table.dart';
import 'database_service.dart';

// typedef RezepteListChangeCallback = void Function(List<Rezept> rezepte);

class DatenDb extends ChangeNotifier {
  List<Rezept> rezepte = [];
  List<Zutat> zutaten = [];
  List<String> zutatNamen = [];
  List<String> einheiten = [];
  List<Rezept> meineRezepte = [];
  List<ListZutat> einkaufsliste = [];
  List<ListZutat> inventar = [];
  List<RezeptZutat> rezeptZutaten = [];
  List<Suchbegriff> stichwortsuchverlauf = [];
  List<DateRezept> kochverlauf = [];
  Uint8List uNoImageAvailable = Uint8List(0);

  Rezept rezeptById = Rezept(
      id: -1,
      name: "name",
      bewertung: -1,
      zubereitung: "zubereitung",
      notizen: "notizen",
      zutaten: [],
      image: Image.asset('assets/no-image-available.jpg'));
  RezepteTable rezepteTable = RezepteTable();
  RezeptZutatenTable rezeptZutatenTable = RezeptZutatenTable();
  StichwortsuchverlaufTable stichwortsuchverlaufTable =
      StichwortsuchverlaufTable();
  ZutatenTable zutatenTable = ZutatenTable();
  MeineRezepteTable meineRezepteTable = MeineRezepteTable();
  MealApiService mealApiService = MealApiService();
  KochverlaufTable kochverlaufTable = KochverlaufTable();
  ListZutatenTable listZutatenTable = ListZutatenTable();

  initialData() async {
    // print('DatenDB().initialData');
    //https://www.chefkoch.de/rezepte/452791137770019/All-American-Burger.html
    // final ByteData data1 =
    //     await rootBundle.load('assets/all-american-burger.png');
    // Uint8List bytes1 = data1.buffer.asUint8List();
    //
    // rezepteTable.addRezept(
    //     id: 1,
    //     name: 'All American Burger',
    //     zubereitung:
    //         "Die Zwiebel schälen, fein würfeln und mit dem Hackfleisch vermischen.\nDas Rinderhack mit Worcestersauce, Salz und Pfeffer kräftig würzen und daraus 4 flache Burger formen. Das Öl in einer Pfanne erhitzen und die Burger darin kräftig anbraten, anschließend auf kleiner Flamme 6 Minuten durchbraten, einmal wenden. Kurz bevor die Burger gar sind, auf jeden 1 Scheibe Käse legen und schmelzen lassen.\nIn der Zwischenzeit den Salat waschen und trocken schleudern. Die Tomaten waschen, trocknen, den grünen Stielansatz entfernen und die Tomaten in Scheiben schneiden.\nDie Hamburgerbrötchen halbieren und jeweils mit der Schnittfläche nach oben unter dem Backofengrill knusprig toasten.\nAnschließend alle unteren Hälften mit Salat belegen, darauf je 1 Burger mit geschmolzener Käsescheibe geben und mit der oberen Hälfte der Hamburgerbrötchen bedecken. Sofort servieren.\nTipp: Die All-American Burger können je nach Geschmack zusätzlich mit Gurken- und Zwiebelscheiben belegt und mit Senf oder Mayonnaise bestrichen werden. ",
    //     notizen: "",
    //     image: bytes1);
    //
    // //1 Zwiebel
    // await addZutat(name: "Zwiebel", id: 1, einheit: '');
    // await deleteZutat(id: 1);
    // await rezeptZutatenTable.addZutatZuRezept(
    //     rezeptID: 1, zutatID: 1, anzahl: 1);
    // await rezepteTable.updateRezept(
    //     id: 1,
    //     name: "Hungarian Burger",
    //     bewertung: 1.5,
    //     zubereitung: "bla",
    //     notizen: "noted");

    ByteData bNoImageAvailable =
        await rootBundle.load('assets/no-image-available.jpg');
    uNoImageAvailable = bNoImageAvailable.buffer.asUint8List();
    // await rezepteTable.updateRezeptImage(id: 1, image: bytes2);

    await fetchMeineRezepte();
    await fetchKochverlauf();
    await fetchSuchverlauf();
    await fetchInventar();
    await fetchEinkaufsliste();
    //await addRezeptFromMfdId(id: 52932);
    // await fetchRezepte();
    // await fetchZutaten();
  }

  Future createTable(Database database) async {
    // print('DatenDB.createTable()');
    await database.execute("""CREATE TABLE IF NOT EXISTS Rezepte(
    "id" INTEGER, 
    "name" TEXT, 
    "bewertung" DOUBLE, 
    "zubereitung" TEXT, 
    "notizen" TEXT,
    "image" JSON , 
    PRIMARY KEY("id" AUTOINCREMENT)
    );""");

    await database.execute("""CREATE TABLE IF NOT EXISTS Zutaten(
    "id" INTEGER, 
    "name" TEXT,
    "einheit" TEXT,
    PRIMARY KEY("id" AUTOINCREMENT)
    );""");

    await database.execute("""CREATE TABLE IF NOT EXISTS MeineRezepte(
    "rezeptID" INTEGER,
    PRIMARY KEY("rezeptID"),
    FOREIGN KEY (rezeptID) REFERENCES Rezepte(id)
    );""");

    await database.execute("""CREATE TABLE IF NOT EXISTS Einkaufsliste(
    "zutatID" INTEGER,
    "anzahl" INTEGER,
    "erledigt" INTEGER,
    PRIMARY KEY("zutatID"),
    FOREIGN KEY (zutatID) REFERENCES Zutaten(id)
    );""");

    await database.execute("""CREATE TABLE IF NOT EXISTS Inventar(
    "zutatID" INTEGER,
    "anzahl" INTEGER,
    "erledigt" INTEGER,
    PRIMARY KEY("zutatID"),
    FOREIGN KEY (zutatID) REFERENCES Zutaten(id)
    );""");

    await database.execute("""CREATE TABLE IF NOT EXISTS Stichwortsuchverlauf(
    "id" INTEGER,
    "datetime" INTEGER,
    "suchbegriff" TEXT,
    PRIMARY KEY("id" AUTOINCREMENT)
    );""");

    await database.execute("""CREATE TABLE IF NOT EXISTS Kochverlauf(
    "rezeptID" INTEGER,
    "datetime" INTEGER,
    PRIMARY KEY("rezeptID" AUTOINCREMENT),
    FOREIGN KEY (rezeptID) REFERENCES Rezepte(id)
    );""");

    await database.execute("""CREATE TABLE IF NOT EXISTS RezeptZutaten(
    "rezeptID" INTEGER,
    "zutatID" INTEGER,
    "anzahl" DOUBLE,
    PRIMARY KEY(rezeptID,zutatID),
    FOREIGN KEY (rezeptID) REFERENCES Rezepte(id),
    FOREIGN KEY (zutatID) REFERENCES Zutaten(id)
    );""");
  }

  Future addRezeptFromMfdId({required int id}) async {
    await rezepteTable.addRezeptFromMfdId(id: id);
    await fetchRezepte();
    await fetchZutaten();
    await fetchRezeptZutaten();
    notifyListeners();
  }

  Future addRezeptFromMfdIdDebug({required int id}) async {
    // print('DatenDb().addRezeptFromMfdId(id: id)');
    final response = await mealApiService.lookupMealById(id.toString());
    if (response != null && response['meals'] != null) {
      final map = response['meals'][0];
      final int idMeal = int.parse(map['idMeal']);
      final String strMeal = map['strMeal'];
      final String strInstructions = map['strInstructions'];
      final String imageUrl = map['strMealThumb'];

      try {
        final ByteData imageByteData =
            await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
        final Uint8List imageUint8List = imageByteData.buffer.asUint8List();
        await addToRezepte(
            id: idMeal,
            name: strMeal,
            zubereitung: strInstructions,
            notizen: "",
            image: imageUint8List);

        for (int i = 1; i <= 20; i++) {
          final ingredient = map['strIngredient$i'];
          final measureRaw = map['strMeasure$i'];
          if (ingredient != null && ingredient.isNotEmpty) {
            var (anzahl, measure) =
                rezepteTable.splitApiMeasure(measureRaw: measureRaw);

            int zutatID = await zutatenTable.getZutatId(
                name: ingredient, einheit: measure);
            if (zutatID == -1) {
              zutatID = idMeal * 100 + i;
              await addZutat(id: zutatID, name: ingredient, einheit: measure);
              await addZutatZuRezept(
                  rezeptID: idMeal, zutatID: zutatID, anzahl: anzahl);
            }
          }
        }
      } catch (error) {
        print('Error fetching NetworkAssetBundle: $error');
      }
    }
  }

  Future<void> addToKochverlauf(
      {required int rezeptID, required DateTime datetime}) async {
    await kochverlaufTable.addToKochverlauf(
        rezeptID: rezeptID, datetime: datetime);
    await fetchKochverlauf();
  }

  Future<void> addListZutat(
      {required String table,
      required String name,
      String einheit = "",
      required double anzahl,
      int erledigt = -1}) async {
    int zutatID = await zutatenTable.getZutatId(name: name, einheit: einheit);
    if (zutatID == -1) {
      zutatID = await zutatenTable.getIdCounter();
      addZutat(id: zutatID, name: name, einheit: einheit);
    }
    await listZutatenTable.addListZutatByID(
        zutatID: zutatID, table: table, anzahl: anzahl, erledigt: erledigt);
  }

  Future<void> addEinkaufZutat(
      {required String name,
      String einheit = "",
      double anzahl = -1,
      int erledigt = -1}) async {
    await addListZutat(
        table: "Einkaufsliste", name: name, anzahl: anzahl, erledigt: erledigt, einheit: einheit);
    await fetchEinkaufsliste();
  }

  Future<void> addEinkaufZutatByID(
      {required int zutatID,
        double anzahl = -1,
        int erledigt = -1}) async {
    await listZutatenTable.addListZutatByID(
        zutatID: zutatID, table: "Einkaufsliste", anzahl: anzahl, erledigt: erledigt);
    await fetchEinkaufsliste();
  }

  Future<void> addInventarZutat(
      {required String name,
      String einheit = "",
      double anzahl = -1,
      int erledigt = -1}) async {
    await addListZutat(
        table: "Inventar", name: name, anzahl: anzahl, erledigt: erledigt);
    await fetchInventar();
  }

  Future addToMeineRezepte(
      {required int rezeptID, double bewertung = -1}) async {
    // print('DatenDb().addToMeineRezepte(rezeptID: rezeptID)');
    await meineRezepteTable.addToMeineRezepte(rezeptID: rezeptID);
    if (bewertung != -1) {
      await rezepteTable.updateRezept(id: rezeptID, bewertung: bewertung);
    }
    await fetchMeineRezepte();
  }

  Future addToRezepte(
      {required String name,
      int id = -1,
      String zubereitung = "",
      String notizen = "",
      image}) async {
    // print('DatenDb().addRezept(name: name)');
    if (image == null || image == Image.memory(Uint8List(0))) {
      image = uNoImageAvailable;
    }
    await rezepteTable.addRezept(
        name: name,
        id: id != -1 ? id : -1,
        zubereitung: zubereitung,
        notizen: notizen,
        image: image);
    await fetchRezepte();
  }

  Future<void> addSuchbegriff({required String suchbegriff}) async {
    int id = await stichwortsuchverlaufTable.getIdBySuchbegriff(
        suchbegriff: suchbegriff);
    if (id == -1) {
      stichwortsuchverlaufTable.addSuchbegriff(
          id: id, suchbegriff: suchbegriff);
    } else {
      stichwortsuchverlaufTable.updateSuchbegriffDate(id: id);
    }
    await fetchSuchverlauf();
  }

  Future<void> addZutatZuRezept(
      {required int rezeptID,
      required int zutatID,
      required double anzahl}) async {
    //print('DatenDb().addZutatZuRezept(rezeptID: rezeptID, zutatID: zutatID, anzahl: anzahl)');
    await rezeptZutatenTable.addZutatZuRezept(
        rezeptID: rezeptID, zutatID: zutatID, anzahl: anzahl);
    await fetchRezeptZutaten();
  }

  Future<int> addZutat(
      {required String name, int id = -1, String einheit = ""}) async {
    // print('DatenDb().addZutat(name: name)');
    int zutatId =
        await zutatenTable.addZutat(name: name, id: id, einheit: einheit);
    if (zutatId == -1) {
      await fetchZutaten();
      await fetchEinheiten();
      return id;
    } else {
      return zutatId;
    }
  }

  Future<void> deleteFromRezepte({required int id}) async {
    await rezepteTable.deleteRezept(id: id);
    await fetchRezepte();
  }
  
  Future<void> deleteFromKochverlauf({required int id}) async {
    await kochverlaufTable.deleteFromKochverlauf(rezeptID: id);
    await fetchKochverlauf();
  }

  Future<void> deleteFromMeineRezepte({required int rezeptID}) async {
    await meineRezepteTable.deleteFromMeineRezepte(rezeptID: rezeptID);
    await fetchMeineRezepte();
  }

  Future<void> deleteRezeptZutaten({required int rezeptID}) async {
    await rezeptZutatenTable.deleteRezeptZutaten(rezeptID: rezeptID);
    await fetchRezeptZutaten();
  }

  Future<void> deleteEinkaufZutat({required int zutatID}) async {
    listZutatenTable.deleteListZutat(table: "Einkaufsliste", zutatID: zutatID);
    fetchEinkaufsliste();
  }

  Future<void> deleteInventarZutat({required int zutatID}) async {
    listZutatenTable.deleteListZutat(table: "Inventar", zutatID: zutatID);
    fetchInventar();
  }

  Future<void> deleteZutat({required int id}) async {
    await zutatenTable.deleteZutat(id: id);
    await fetchZutaten();
  }

  Future<void> fetchEinheiten() async {
    einheiten = await zutatenTable.fetchEinheiten();
  }

  Future<void> fetchEinkaufsliste() async {
    einkaufsliste =
        await listZutatenTable.fetchListZutaten(table: "Einkaufsliste");
    notifyListeners();
  }

  Future<void> fetchInventar() async {
    inventar = await listZutatenTable.fetchListZutaten(table: "Inventar");
    notifyListeners();
  }

  Future<void> fetchMeineRezepte() async {
    meineRezepte = await meineRezepteTable.fetchMeineRezepte();
    notifyListeners();
  }

  Future<void> fetchRezeptByID({required int id}) async {
    Rezept? lRezept = await rezepteTable.fetchRezeptByID(id: id);
    if (lRezept != null) {
      rezeptById = lRezept;
      notifyListeners();
    }
  }

  Future<void> fetchKochverlauf() async {
    kochverlauf = await kochverlaufTable.fetchKochverlauf();
    notifyListeners();
  }

  /**
   * Aktualisiert lokale Variable List<Rezept> rezepte auf den stand der DB und
   * befüllt die Zutatenliste der jeweiligen Rezept Objekte.
   */
  Future fetchRezepte() async {
    // print('DatenDb().fetchFullRezepte()');
    rezepte = await rezepteTable.fetchRezepte();
    notifyListeners();
  }

//debug method
  Future fetchRezeptZutaten() async {
    // print('DatenDb().fetchRezeptZutaten()');
    rezeptZutaten = await rezeptZutatenTable.fetchRezeptZutaten();
  }

  Future<void> fetchSuchverlauf() async {
    stichwortsuchverlauf = await stichwortsuchverlaufTable.fetchSuchverlauf();
    notifyListeners();
  }

  Future<void> fetchZutaten() async {
    // print('DatenDb().fetchZutaten()');
    zutaten = await zutatenTable.fetchZutaten();
    notifyListeners();
  }

  Future<int> getIdCounter({required String table}) async {
    final database = await DatabaseService().database;
    List<Map<String, Object?>> map = await database.query('sqlite_sequence',
        columns: ["*"], where: "name = ?", whereArgs: [table]);

    int idCounter = int.parse(map.first['seq'].toString());
    return idCounter + 1;
  }

  // Future<List<Rezept>> searchInApi({required String suchbegriff}){
  //   List<Rezept> rezepte = [];
  //   try {
  //     final response = await apiService.filterByCategory(category);
  //     if (response != null && response['meals'] != null) {
  //       final List<dynamic> meals = response['meals'];
  //       List<int> idMeals = [];
  //       for (var meal in meals) {
  //         idMeals.add(int.parse(meal['idMeal']));
  //       }
  //       RezepteTable rezepteTable = RezepteTable();
  //       for (int idMeal in idMeals) {
  //         if (await rezepteTable.checkIfRezeptIdNotExists(id: idMeal)) {
  //   await rezepteTable.addRezeptFromMfdId(id: idMeal);
  //   }
  //   }
  //   for (int idMeal in idMeals) {
  //   Rezept? sqRezept =
  //   await rezepteTable.fetchRezeptByID(id: idMeal);
  //   if (sqRezept != null) {
  //   rezepte.add(sqRezept);
  //   }
  //   }
  //   return rezepte;
  //   }
  //   } catch (error) {
  //   print('Error fetching recipes: $error');
  //   }
  //   return [];
  // }

  Future<void> updateEinkaufZutat(
      {required int zutatID, int anzahl = -1, int erledigt = -1}) async {
    listZutatenTable.updateListZutat(table: "Einkaufsliste", zutatID: zutatID, erledigt: erledigt);
    fetchEinkaufsliste();
  }

  Future<void> updateInventarZutat(
      {required int zutatID, int anzahl = -1, int erledigt = -1}) async {
    listZutatenTable.updateListZutat(table: "Inventar", zutatID: zutatID);
    fetchInventar();
  }

  Future<void> updateRezept(
      {required int id,
      String name = "",
      double bewertung = -1,
      String zubereitung = "",
      String notizen = ""}) async {
    await rezepteTable.updateRezept(
        id: id, name: name, zubereitung: zubereitung, bewertung:bewertung, notizen: notizen);
    await fetchRezepte();
  }

  Future<void> updateRezeptImage(
      {required int id, required Uint8List image}) async {
    await rezepteTable.updateRezeptImage(id: id, image: image);
    await fetchRezepte();
  }
}
