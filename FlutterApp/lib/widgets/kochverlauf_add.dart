import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../DatenDb/datendb.dart';

class KochVerlaufAdd extends StatefulWidget {
  KochVerlaufAdd({Key? key, required this.rezeptID}) : super(key: key);
  final int rezeptID;

  @override
  _KochVerlaufAddState createState() => _KochVerlaufAddState();
}

class _KochVerlaufAddState extends State<KochVerlaufAdd> {
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  double gRating = 3.0;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
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
                        },
                        child: const Text('Ja'),
                      ),
                    ],
                  );
                },
              );
            }),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Verzehrdatum',
                    hintText: 'Wählen Sie ein Datum',
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Bewertung',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RatingBar.builder(
              initialRating: gRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  gRating = rating;
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
            datendb.addToKochverlauf(
                rezeptID: widget.rezeptID, datetime: DateTime.now());
            print('Saving Data...');
            if (_selectedDate != null) {
              print('Datum: ${DateFormat('dd.MM.yyyy').format(_selectedDate!)}');
            }
            print('Bewertung: $gRating');
            datendb.updateRezept(id: widget.rezeptID, bewertung: gRating);
            Navigator.of(context).pop();
        },
        label: Text('Speichern'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.purple[80],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  // _saveData(DatenDb datendb) {
  //   // Placeholder for your save logic
  //   // For demonstration, printing the values to the console
  //   datendb.addToKochverlauf(
  //       rezeptID: widget.rezeptID, datetime: DateTime.now());
  //   datendb.updateRezept(id: widget.rezeptID, bewertung: _rating);
  //   print('Saving Data...');
  //   if (_selectedDate != null) {
  //     print('Datum: ${DateFormat('dd.MM.yyyy').format(_selectedDate!)}');
  //   }
  //   print('Bewertung: $_rating');
  //   // Here, you would add your logic to save these values to a database or other storage
  // }
}