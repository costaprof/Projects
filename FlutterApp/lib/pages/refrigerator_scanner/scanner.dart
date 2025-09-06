import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:was_essen/widgets/shutter_button.dart';
import '../../services/api_key.dart';
import '../../constants/theme.dart';
import './scan_results.dart';
import '../../services/gpt_service.dart';

class RefrigeratorScannerPage extends StatefulWidget {
  const RefrigeratorScannerPage({super.key});

  @override
  State<RefrigeratorScannerPage> createState() =>
      _RefrigeratorScannerPageState();
}

class _RefrigeratorScannerPageState extends State<RefrigeratorScannerPage> {
  final apiService = OpenAIService(apiKey: OPENAI_API_KEY);
  File? _selectedImage;
  String scanResults = '''
      [
  {"zutatID": 101, "name": "Apples", "einheit": "pcs", "menge": 1.0, "erledigt": false},
  {"zutatID": 102, "name": "Lime", "einheit": "pcs", "menge": 1.0, "erledigt": false},
  {"zutatID": 103, "name": "Dill Pickles", "einheit": "jar", "menge": 1.0, "erledigt": false},
  {"zutatID": 104, "name": "Hotsauce", "einheit": "bottle", "menge": 1.0, "erledigt": false},
  {"zutatID": 105, "name": "Tomatoes", "einheit": "bottle", "menge": 1.0, "erledigt": false},
  {"zutatID": 106, "name": "Mustard", "einheit": "bottle", "menge": 1.0, "erledigt": false},
  {"zutatID": 107, "name": "Soy Sauce", "einheit": "bottle", "menge": 1.0, "erledigt": false},
  {"zutatID": 108, "name": "Salt", "einheit": "bottle", "menge": 1.0, "erledigt": false},
  {"zutatID": 109, "name": "Mayonnaise", "einheit": "bottle", "menge": 1.0, "erledigt": false},
  {"zutatID": 110, "name": "Greek Yogurt", "einheit": "container", "menge": 2.0, "erledigt": false},
  {"zutatID": 111, "name": "Glace Cherry", "einheit": "pcs", "menge": 2.0, "erledigt": false}
]''';
  bool scanning = false;
  bool overlayVisible = false;
  final bool useMockData = true;

  // for later use
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile =
        await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _scanFoodItem() async {
    setState(() {
      scanning = true;
      overlayVisible = true;
    });

    // simulate API call wait
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        scanning = false;
        overlayVisible = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultsPage(
            scanResults: scanResults,
            imagePath: 'assets/food_to_scan.jpg',
          ),
        ),
      );
    });
  }

  Widget _buildOverlay() {
    return Visibility(
      visible: overlayVisible,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Scanning...',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refrigerator Scanner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          // Full-screen image
          Positioned.fill(
            child: _selectedImage == null
                ? Image.asset('assets/food_to_scan.jpg', fit: BoxFit.cover)
                : Image.file(_selectedImage!, fit: BoxFit.cover),
          ),
          // shutter button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
                child: ShutterButton(
              onTap: _scanFoodItem,
            )),
          ),
          if (overlayVisible) _buildOverlay(),
        ],
      ),
    );
  }
}
