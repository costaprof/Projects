import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './DatenDb/datendb.dart';
import 'my_homepage.dart';

main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DatenDb(),
      child: WasSollIchEssen(),
    ),
  );
}

class WasSollIchEssen extends StatelessWidget {
  WasSollIchEssen({super.key});

  int initialisiert = 0;

  hinzufugen(DatenDb datendb) async {
    datendb.initialData();
  }

  @override
  Widget build(BuildContext context) {
    var datendb = context.watch<DatenDb>();
    if (initialisiert == 0) {
      hinzufugen(datendb);
      initialisiert = 1;
    }
    //insertInitialData(datendb);
    // datendb.fetchAll();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Was soll ich essen?',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 65, 108, 10)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
