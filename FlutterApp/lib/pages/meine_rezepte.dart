import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../DatenDb/datendb.dart';
import '../models/rezept.dart';
import '../widgets/rezept_list.dart';
import '../widgets/rezepte_add.dart';

class MeineRezepte extends StatefulWidget {
  const MeineRezepte({super.key});

  @override
  State<MeineRezepte> createState() => _MeineRezepteState();
}

class _MeineRezepteState extends State<MeineRezepte> {
  List<Rezept> _foundRezepte = [];
  List<Rezept> rezepte = [];
  String suchbegriff = "";

  @override
  void initState() {
    super.initState();
  }

  void _runFilter(String enteredKeyword, DatenDb datendb) {
    List<Rezept> results = [];
    List<Rezept> dbRezept = datendb.meineRezepte;
    if (!listEquals(rezepte, dbRezept)) {
      rezepte = dbRezept;
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
          Expanded(
            child: rezeptListView(rezepte: _foundRezepte, datendb: datendb, table: 2),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRezeptScreen()),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
