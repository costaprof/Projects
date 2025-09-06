import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:was_essen/widgets/rezepte_add.dart';

import '../DatenDb/datendb.dart';
import '../models/rezept.dart';
import '../models/rezept_zutat.dart';
import './rezept_karte_button.dart';
import 'kochverlauf_add.dart';

Uint8List placeholderImg = Uint8List(5);

class RezeptKarte extends StatefulWidget {
  final Rezept? rezept;
  final ScrollController? scrollController;

  const RezeptKarte({super.key, this.rezept, this.scrollController});

  @override
  RezeptKarteState createState() => RezeptKarteState();
}

class RezeptKarteState extends State<RezeptKarte> {
  Rezept rezept = Rezept(
      id: -1,
      name: "name",
      bewertung: -1,
      zubereitung: "zubereitung",
      notizen: "notizen",
      zutaten: [],
      image: Image.memory(Uint8List(0)));
  bool updated = false;
  Image image1 = Image.asset('assets/no-image-available.jpg');
  List<RezeptZutat> zutaten = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // fetchRezeptByID({required int id, required DatenDb datendb}) async{
  //   await datendb.fetchRezeptByID(id: rezept.id);
  // }

  @override
  Widget build(BuildContext context) {
    var datendb = context.watch<DatenDb>();
    if (!updated) {
      setState(() {
        rezept = widget.rezept!;
      });
    } else {
      setState(() {
        //fetchRezeptByID(id: rezept.id, datendb: datendb);
        rezept = datendb.rezeptById;
      });
    }
    zutaten = rezept.zutaten;

    return Scaffold(
      appBar: AppBar(
        title: Text(rezept.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: rezept.image,
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      rezept.name,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ).padding(bottom: 8),
                  ),
                  IconButton(
                    alignment: Alignment.center,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddRezeptScreen(rezept: rezept)));
                      setState(() {
                        updated = true;
                      });
                    },
                    iconSize: 40,
                    icon: const Icon(Icons.edit_note),
                  ),
                ],
              ),
              rezept.getBewertungSterne().padding(bottom: 4),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: RezeptKartenButton(
                      initialIcon: Icons.favorite_border,
                      confirmationIcon: Icons.favorite,
                      initialLabel: 'Meine Rezepte',
                      confirmationLabel: 'Rezept gespeichert!',
                      onPressed: () =>
                          datendb.addToMeineRezepte(rezeptID: rezept.id),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: RezeptKartenButton(
                      initialLabel: 'Kochverlauf',
                      confirmationLabel: 'Mahlzeit eingetragen',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  KochVerlaufAdd(rezeptID: rezept.id)),
                        );
                        // datendb.addToKochverlauf(
                        //     rezeptID: rezept.id, datetime: DateTime.now());
                      },
                    ),
                  ),
                  // const SizedBox(height: 4),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: RezeptKartenButton(
                  //     initialLabel: 'Rezept planen',
                  //     initialIcon: Icons.calendar_month,
                  //     confirmationLabel: 'in Planung',
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => RecipePlanner(
                  //             rezept: GeplantesRezept(
                  //               name: 'Spaghetti Carbonara',
                  //               rating: 4.5,
                  //               time: 30,
                  //               difficulty: 'Mittel',
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Zutaten:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ).padding(bottom: 4, top: 8),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DataTable(
                        columnSpacing: 10,
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text('Name'),
                          ),
                          DataColumn(
                            label: Text('Menge'),
                          ),
                          DataColumn(
                            label: Text('Einheit'),
                          ),
                        ],
                        rows: zutaten
                            .map((zutat) => DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text(zutat.name)),
                                    DataCell(Center(
                                        child: Text(
                                            zutat.anzahl.toStringAsFixed(2)))),
                                    DataCell(
                                      Text(zutat.einheit),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  )),
              SizedBox(
                width: double.infinity,
                child: RezeptKartenButton(
                  initialIcon: Icons.shopping_bag,
                  initialLabel: 'Zutaten in Einkaufsliste speichern',
                  confirmationLabel: 'In Einkaufsliste',
                  onPressed: () {
                    for (var zutat in zutaten) {
                      datendb.addEinkaufZutatByID(
                          zutatID: zutat.zutatID,
                          anzahl: zutat.anzahl,
                          erledigt: 0);
                    }
                  },
                ),
              ),
              const Text(
                'Zubereitung:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ).padding(bottom: 4, top: 8),
              Text(
                rezept.zubereitung,
                style: const TextStyle(fontSize: 16),
              ).padding(bottom: 8),
              const Text(
                'Notizen:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ).padding(bottom: 8),
              Text(
                rezept.notizen,
                style: const TextStyle(fontSize: 16),
              ).padding(bottom: 8),
            ],
          ),
        ),
      ),
    );
  }
}
