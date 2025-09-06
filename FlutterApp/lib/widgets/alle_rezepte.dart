import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../DatenDb/datendb.dart';
import '../models/rezept.dart';
import '../widgets/rezepte_add.dart';
import '../widgets/rezept_list.dart';

class AlleRezepte extends StatefulWidget {
  const AlleRezepte({super.key});

  @override
  State<AlleRezepte> createState() => _AlleRezepteState();
}

class _AlleRezepteState extends State<AlleRezepte> {
  List<Rezept> _foundRezepte = [];
  List<Rezept> rezepte = [];
  String suchbegriff = "";

  @override
  void initState() {
    super.initState();
  }

  void _runFilter(String enteredKeyword, DatenDb datendb) {
    List<Rezept> results = [];
    List<Rezept> dbRezept = datendb.rezepte;
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Alle Rezepte'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
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
            ),
          ),
          rezeptListView(rezepte: _foundRezepte, datendb: datendb, table: 0)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRezeptScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
