import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:was_essen/pages/einkaufsliste/markt_suche.dart';
import '../DatenDb/datendb.dart';

class ZutatHinzufuegenBottomSheet extends StatefulWidget {
  final Function(String, double, String) onAddItem;

  const ZutatHinzufuegenBottomSheet({super.key, required this.onAddItem});

  @override
  ZutatHinzufuegenBottomSheetState createState() =>
      ZutatHinzufuegenBottomSheetState();
}

class ZutatHinzufuegenBottomSheetState
    extends State<ZutatHinzufuegenBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  String newItemTitle = '';
  double newItemValue = 0;
  String einheit = '';
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateButtonState);
    _titleController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = _titleController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    var datendb = context.watch<DatenDb>();
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          top: 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Zutat hinzufügen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Zutat',
              ),
              onChanged: (value) {
                newItemTitle = value;
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Anzahl',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      newItemValue = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_up),
                      onPressed: () {
                        setState(() {
                          newItemValue++;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: () {
                        setState(() {
                          if (newItemValue > 0) newItemValue--;
                        });
                      },
                    ),
                  ],
                ),
                Expanded(
                  flex: 3,
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
                        einheit = newValue!;
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
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                    widget.onAddItem(newItemTitle, newItemValue, einheit);
                    Navigator.pop(context);
                  }
                      : null,
                  child: const Text('Speichern'),
                ),
              ],
            ),
          ],
        ),
      ),
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