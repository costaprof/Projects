import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../../DatenDb/datendb.dart';
import '../../models/date_rezept.dart';
import '../../widgets/rezept_list.dart';
import '../widgets/alle_rezepte.dart';

class KochVerlauf extends StatefulWidget {
  const KochVerlauf({super.key});

  @override
  State<KochVerlauf> createState() => _KochVerlaufState();
}

class _KochVerlaufState extends State<KochVerlauf> {
  List<DateRezept> _foundRezepte = [];
  List<DateRezept> rezepte = [];
  String suchbegriff = "";

  @override
  void initState() {
    super.initState();
  }

  void _runFilter(String enteredKeyword, DatenDb datendb) {
    List<DateRezept> results = [];
    if (!listEquals(rezepte, datendb.kochverlauf)) {
      rezepte = datendb.kochverlauf;
    }
    if (enteredKeyword.isEmpty) {
      results = rezepte;
    } else {
      results = rezepte
          .where((rezept) =>
              rezept.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundRezepte = results;
    });
  }

  void _handleAlleRezepte() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AlleRezepte()),
    );
  }

  void _handleOpenScanner() {
    // Define another action here
    print('todo');
  }

  void deleteRezept(int index, DatenDb datendb, BuildContext context) {
    int recipeId = _foundRezepte.elementAt(index).id;
    datendb.deleteFromRezepte(id: recipeId);
    datendb.deleteRezeptZutaten(rezeptID: recipeId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    var datendb = context.watch<DatenDb>();
    _runFilter(suchbegriff, datendb);
    return Scaffold(
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 5),
              child: TextField(
                onChanged: (value) {
                  suchbegriff = value;
                  _runFilter(value, datendb);
                },
                decoration: const InputDecoration(
                    labelText: 'Search', suffixIcon: Icon(Icons.search)),
              )),
          rezeptListView(rezepte: _foundRezepte, datendb: datendb, table: 1)
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: _foundRezepte.length,
          //     itemBuilder: (context, index) => Card(
          //       key: ValueKey(_foundRezepte.elementAt(index).id),
          //       color: Colors.blue[600],
          //       elevation: 4,
          //       margin: const EdgeInsets.symmetric(vertical: 10),
          //       child: ListTile(
          //         leading: _foundRezepte.elementAt(index).image,
          //         title: Text(
          //           _foundRezepte.elementAt(index).name,
          //           style:
          //               const TextStyle(fontSize: 24, color: Colors.white),
          //         ),
          //         subtitle: _foundRezepte
          //             .elementAt(index)
          //             .getBewertungSterne(
          //                 textColor: Colors.white,
          //                 text1: "",
          //                 text2: "",
          //                 iconColor: Colors.yellow,
          //                 iconSize: 20),
          //         trailing: IconButton(
          //           icon: const Icon(Icons.delete),
          //           onPressed: () {
          //             deleteRezept(index, datendb, context);
          //           },
          //         ),
          //         onTap: () {
          //           _onItemClicked(context, _foundRezepte.elementAt(index));
          //         },
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.list),
            label: 'Alle Rezepte',
            onTap: _handleAlleRezepte,
          ),
        ],
      ),
    );
  }
}
