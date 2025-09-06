import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './pages/einkaufsliste/einkaufsliste.dart';
import 'pages/home_page.dart';
import './pages/inventar.dart';
import './pages/kochverlauf.dart';
import 'pages/meine_rezepte.dart';
import './widgets/bottom_nav_bar.dart';
import './DatenDb/datendb.dart';
import 'search_reciep.dart';

var isSearchRezeptPressed = ValueNotifier(false);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      isSearchRezeptPressed.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var datendb = context.watch<DatenDb>();
    // datendb.initialData();
    Widget body;
    Text title;
    switch (_selectedIndex) {
      case 0:
        body = const HomePage();
        title = const Text('Was soll ich essen?');
        break;
      case 1:
        body = const Center(child: Einkaufsliste());
        title = const Text('Einkaufsliste');
        break;
      case 2:
        body = const Center(child: InventarList());
        title = const Text('Inventar');
        break;
      case 3:
        body = const Center(child: KochVerlauf());
        title = const Text('Kochverlauf');
        break;
      case 4:
        body = const Center(child: MeineRezepte());
        title = const Text('Meine Rezepte');
        break;
      default:
        body = const HomePage();
        title = const Text('Was soll ich essen?');
        break;
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: isHomePage() ? titleAndSearchBtn(title.data!) : title),
      body: Center(
        child: body,
      ),
      bottomNavigationBar: BottomNavBar(onItemSelected: _onItemSelected),
    );
  }

  //-- Widget that has title of Page  + Search Icon
  Widget titleAndSearchBtn(String title) {
    return ValueListenableBuilder(
        valueListenable: isSearchRezeptPressed,
        builder: (context, value, _) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                GestureDetector(
                    onTap: () {
                      //set search value
                      setState(() {
                        isSearchRezeptPressed.value =
                        !isSearchRezeptPressed.value;
                      });
                    },
                    child: Icon(
                        isSearchRezeptPressed.value
                            ? Icons.close
                            : Icons.search,
                        color: Colors.black))
              ]);
        });
  }

  bool isHomePage() {
    return _selectedIndex == 0;
  }
}
