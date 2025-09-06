import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:was_essen/DatenDb/datendb.dart';

class ScanResultsPage extends StatefulWidget {
  final String scanResults;
  final String imagePath; // Assume you pass the path to the image

  const ScanResultsPage(
      {super.key, required this.scanResults, required this.imagePath});

  @override
  ScanResultsPageState createState() => ScanResultsPageState();
}

class ScanResultsPageState extends State<ScanResultsPage> {
  late List<Map<String, dynamic>> items;
  late List<TextEditingController> nameControllers;
  late List<TextEditingController> mengeControllers;
  late List<TextEditingController> einheitControllers;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    try {
      final decodedJson = jsonDecode(widget.scanResults);
      if (decodedJson is List) {
        items = List<Map<String, dynamic>>.from(decodedJson);
      } else {
        throw const FormatException("Expected a JSON array");
      }
    } catch (e) {
      items = [];
      print('Error parsing JSON: $e');
    }

    nameControllers =
        items.map((item) => TextEditingController(text: item['name'])).toList();
    mengeControllers = items
        .map((item) => TextEditingController(text: item['menge'].toString()))
        .toList();
    einheitControllers = items
        .map((item) => TextEditingController(text: item['einheit']))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in nameControllers) {
      controller.dispose();
    }
    for (var controller in mengeControllers) {
      controller.dispose();
    }
    for (var controller in einheitControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final datenDb = Provider.of<DatenDb>(context, listen: false);

      // Process the data
      for (int i = 0; i < items.length; i++) {
        items[i]['name'] = nameControllers[i].text;
        items[i]['menge'] = double.tryParse(mengeControllers[i].text) ?? 0.0;
        items[i]['einheit'] = einheitControllers[i].text;

        await datenDb.addInventarZutat(
          name: items[i]['name'],
          anzahl: items[i]['menge'],
          einheit: items[i]['einheit'],
        );
      }
      print(jsonEncode(items));

      // Ensure the page is popped after all operations are complete
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I see...'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              Expanded(
                child: items.isNotEmpty
                    ? ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: nameControllers[index],
                                    decoration: const InputDecoration(
                                        labelText: 'Name'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: mengeControllers[index],
                                          decoration: const InputDecoration(
                                              labelText: 'Menge'),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a quantity';
                                            }
                                            if (double.tryParse(value) ==
                                                null) {
                                              return 'Please enter a valid number';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          controller: einheitControllers[index],
                                          decoration: const InputDecoration(
                                              labelText: 'Einheit'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(child: Text('No scan results available')),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () => _submitForm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
