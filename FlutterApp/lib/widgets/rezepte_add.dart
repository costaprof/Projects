import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:was_essen/models/rezept.dart';
import 'package:was_essen/models/rezept_zutat.dart';

import '../DatenDb/datendb.dart';
import '../models/rezept.dart';

class AddRezeptScreen extends StatefulWidget {
  final Rezept? rezept;

  const AddRezeptScreen({super.key, this.rezept});

  @override
  AddRezeptScreenState createState() => AddRezeptScreenState();
}

class AddRezeptScreenState extends State<AddRezeptScreen> {
  File? _imageFile;
  final List<RezeptZutat> _zutaten = [];
  final _zutatFormKey = GlobalKey<FormState>();
  final _rezeptFormKey = GlobalKey<FormState>();
  String _rezeptName = '';
  String _zutatName = '';
  String _einheit = '';
  double _menge = 0;
  String _zubereitung = '';
  String _notizen = '';
  bool saved = false;
  final List<Map<String, dynamic>> _allrezepte = [];
  final TextEditingController _rezeptNameController = TextEditingController();
  final TextEditingController _zutatNameController = TextEditingController();
  final TextEditingController _mengeController = TextEditingController();
  final TextEditingController _einheitController = TextEditingController();
  final TextEditingController _zubereitungController = TextEditingController();
  final TextEditingController _notizenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.rezept != null) {
      final rezept = widget.rezept!;
      _rezeptName = rezept.name;
      _zubereitung = rezept.zubereitung;
      _notizen = rezept.notizen;
      _zutaten.addAll(rezept.zutaten);
      _rezeptNameController.text = rezept.name;
      _zubereitungController.text = rezept.zubereitung;
      _notizenController.text = rezept.notizen;
    }
  }

  Future pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
    }
  }

  void addZutat() {
    if (_zutatFormKey.currentState!.validate()) {
      _zutatFormKey.currentState!.save();

      // Retrieve and convert the value from _mengeController
      double parsedMenge = double.tryParse(_mengeController.text) ?? 0;
      _zutatName = _zutatNameController.text;

      List<int> treffer = [];
      for (int i = 0; i < _zutaten.length; i++) {
        RezeptZutat zutat = _zutaten.elementAt(i);
        if (zutat.name == _zutatName) {
          if (zutat.einheit == _einheit) {
            treffer.add(i);
          }
        }
      }

      if (treffer.isEmpty) {
        setState(() {
          _zutaten.add(RezeptZutat(
              zutatID: -1,
              name: _zutatName,
              anzahl: parsedMenge,
              einheit: _einheit));
        });
      } else {
        setState(() {
          _zutaten.add(RezeptZutat(
              zutatID: -1, name: _zutatName, anzahl: _menge, einheit: _einheit));
          _zutaten.elementAt(treffer.first).anzahl += _menge;
        });
      }
      if (treffer.length > 1) {
        print('Es sind mehrere gleiche Rezeptzutaten in der Liste.');
      }

      // Clear the input fields after adding a Zutat
      _zutatNameController.clear();
      _mengeController.clear();
      _einheitController.clear();
    }
  }

  Image? getImage() {
    if (_imageFile != null) {
      return Image.file(_imageFile!);
    } else if (_imageFile == null && widget.rezept != null) {
      Rezept rezept1 = widget.rezept!;
      return rezept1.image;
    }
    return null;
  }

  //Rezept in sqlite db speichern
  Future<void> saveRezept(
      {required DatenDb datendb, required BuildContext context}) async {
    if (_rezeptFormKey.currentState!.validate()) {
      _rezeptFormKey.currentState!.save();
      saved = true;
      if (widget.rezept != null) {
        // Update the recipe
        final rezept = widget.rezept!;
        final rezeptID = rezept.id;
        if (rezept.name != _rezeptName ||
            rezept.zubereitung != _zubereitung ||
            rezept.notizen != _notizen) {
          await datendb.updateRezept(
              id: rezeptID,
              name: _rezeptName,
              zubereitung: _zubereitung,
              notizen: _notizen);
        }
        if (_imageFile != null) {
          Uint8List data = _imageFile!.readAsBytesSync();
          await datendb.updateRezeptImage(id: rezeptID, image: data);
        }
        if (!listEquals(rezept.zutaten, _zutaten)) {
          await datendb.deleteRezeptZutaten(rezeptID: rezeptID);
          await addZutaten(datendb: datendb, rezeptID: rezeptID);
        }
        await datendb.fetchRezeptByID(id: rezept.id);
      } else {
        // Add a new recipe
        int rezeptID = await datendb.rezepteTable.getIdCounter();
        await addRezept(datendb: datendb, rezeptID: rezeptID);
        await addZutaten(datendb: datendb, rezeptID: rezeptID);
      }
      clearTheForms();
    }
  }

  Future<void> addRezept(
      {required DatenDb datendb, required int rezeptID}) async {
    if (_imageFile != null) {
      Uint8List data = _imageFile!.readAsBytesSync();
      await datendb.addToRezepte(
          id: rezeptID,
          name: _rezeptName,
          zubereitung: _zubereitung,
          notizen: _notizen,
          image: data);
    } else {
      await datendb.addToRezepte(
          id: rezeptID,
          name: _rezeptName,
          zubereitung: _zubereitung,
          notizen: _notizen);
    }
  }

  Future<void> addZutaten(
      {required DatenDb datendb, required int rezeptID}) async {
    for (var zutat in _zutaten) {
      int zutatID = await datendb.getIdCounter(table: "Zutaten");
      zutatID = await datendb.addZutat(
          name: zutat.name, id: zutatID, einheit: zutat.einheit);
      await datendb.addZutatZuRezept(
          rezeptID: rezeptID, zutatID: zutatID, anzahl: zutat.anzahl);
      await datendb.fetchRezepte();
      // await datendb.fetchRezeptZutaten();
    }
  }

  void clearTheForms() {
    _rezeptNameController.clear();
    _mengeController.clear();
    _einheitController.clear();
    _zubereitungController.clear();
    _notizenController.clear();
    _zutatNameController.clear();
    _zutaten.clear();
    _imageFile = null;
  }

  @override
  Widget build(BuildContext context) {
    var datendb = context.watch<DatenDb>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezept erstellen'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Ohne speichern verlassen?',
                      style: TextStyle(fontSize: 20),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text('Abbrechen'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.of(context)
                              .pop(); // Go back to previous screen
                          clearTheForms();
                        },
                        child: const Text('Ja'),
                      ),
                    ],
                  );
                },
              );
            }),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Form(
                key: _rezeptFormKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                        onPressed: pickImage,
                        child: const Text('Upload Image'),
                      ),
                    ),
                    if (getImage() != null) getImage()!,
                    const SizedBox(height: 30),
                    Container(
                      width: 450.0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5),
                      child: TextFormField(
                        controller: _rezeptNameController,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          labelText: 'Rezept Name',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _rezeptName = value!;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      width: 450.0,
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _zubereitungController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: 'Zubereitung',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _zubereitung = value!;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a Zubereitung';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      width: 450.0,
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _notizenController,
                        decoration: const InputDecoration(
                          labelText: 'Notizen',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _notizen = value!;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Form(
                key: _zutatFormKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10),
                      child: TextFormField(
                        controller: _zutatNameController,
                        decoration: const InputDecoration(
                          labelText: 'Zutat',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _zutatNameController.text = value!;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Bitte geben Sie eine Bezeichnung ein';
                          }
                          if (RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Bitte geben Sie einen Buchstaben an';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _mengeController,
                        decoration: const InputDecoration(
                          labelText: 'Menge',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          double? parsedValue = double.tryParse(value!);
                          if (parsedValue != null) {
                            _menge = parsedValue;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Ungültige Eingabe: Bitte geben Sie eine korrekte Zahl an'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Bitte geben Sie eine Menge an';
                          }
                          if (!RegExp(r'^\d+(\.\d+)?([eE][+]?\d+)?$')
                              .hasMatch(value)) {
                            return 'Bitte geben Sie eine korrekte Zahl an';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Einheit',
                          border: OutlineInputBorder(),
                        ),
                        items: _units.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _einheit = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte wählen Sie eine Einheit aus';
                          }
                          return null;
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: addZutat,
                      child: const Text('Add Zutat'),
                    ),
                  ],
                ),
              ),
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
                          DataColumn(
                            label: Text(''),
                          ),
                        ],
                        rows: _zutaten
                            .map((zutat) => DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text(zutat.name)),
                                    DataCell(Center(
                                        child: Text(zutat.anzahl.toString()))),
                                    DataCell(Text(zutat.einheit)),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            _zutaten.remove(zutat);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await saveRezept(datendb: datendb, context: context);
          if (saved) {
            Navigator.of(context).pop();
            // Remove this line: sleep(Duration(seconds: 1));
          }
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Text('Save'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

List<String> _units = [
  'teaspoon',
  'tablespoon',
  'cup',
  'ounce',
  'pound',
  'piece',
  'pinch',
  'dash',
  'milliliter',
  'liter',
  'gram',
  'kilogram'
];
