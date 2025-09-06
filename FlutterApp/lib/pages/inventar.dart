import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:was_essen/models/rezept.dart';
import 'package:was_essen/services/my_food_db.dart';
import 'package:was_essen/utils.dart';
import 'package:was_essen/widgets/empty_page_placeholder.dart';
import 'package:was_essen/widgets/item_carousel.dart';
import 'package:was_essen/pages/refrigerator_scanner/scanner.dart';
import 'package:was_essen/widgets/list.dart';
import 'package:was_essen/widgets/zutaten_hinzufuegen_bottom_sheet.dart';
import '../../models/list_zutat.dart';
import '../../DatenDb/datendb.dart';
import '../utils.dart';

class Inventar extends StatelessWidget {
  const Inventar({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DatenDb(),
      child: const InventarList(),
    );
  }
}

class InventarList extends StatefulWidget {
  const InventarList({super.key});

  @override
  State<InventarList> createState() => InventarState();
}

class InventarState extends State<InventarList> {
  List<Rezept> rezepte = [];
  List<ListZutat> inventar = [];
  Map<int, bool> selectedItems = {};
  bool showCarousel = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeSelectedItems();
  }

  void _initializeSelectedItems() {
    selectedItems = {
      for (var item in inventar) item.id: false,
    };
  }

  void _fetchAndLogRecipes() async {
    bool hasSelectedItems =
        selectedItems.values.any((isSelected) => isSelected);

    if (!hasSelectedItems) {
      setState(() {
        showCarousel = false;
        rezepte = [];
      });
      return;
    }
    List<String> selectedIngredientNames = inventar
        .where((item) => selectedItems[item.id] == true)
        .map((item) => item.name)
        .toList();
    MealApiService apiService = MealApiService();
    print('Fetching recipes. ingredients selected: $selectedIngredientNames');

    isLoading = true;
    try {
      final response =
          await apiService.filterByIngredients(selectedIngredientNames);
      if (response != null && response['meals'] != null) {
        rezepte = await getRezepteFromResponse(response: response);
        setState(() {
          showCarousel = true;
        });
      } else {
        setState(() {
          showCarousel = false;
          isLoading = false;
          rezepte = [];
        });
      }
    } catch (e) {
      setState(() {
        showCarousel = false;
        isLoading = false;
        rezepte = [];
      });
      print('Error fetching recipes: $e');
    }
    isLoading = false;
  }

  void _removeItem(ListZutat item) {
    final datenDb = Provider.of<DatenDb>(context, listen: false);
    datenDb.deleteInventarZutat(zutatID: item.id);
    _fetchAndLogRecipes();
  }

  // toggles the local state of selected items for recipe recommendation
  void _updateItem(ListZutat updatedItem, bool? selected) {
    setState(() {
      selectedItems[updatedItem.id] = selected ?? false;
    });
    _fetchAndLogRecipes();
  }

  void _handleAddItem(DatenDb datendb) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ZutatHinzufuegenBottomSheet(
            onAddItem: (String name, double anzahl, einheit) {
              datendb.addInventarZutat(
                  name: name, anzahl: anzahl, einheit: einheit);
              _fetchAndLogRecipes();
            },
          ),
        );
      },
    );
  }

  void _handleOpenScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RefrigeratorScannerPage(),
      ),
    );
  }

  void _updateItemName(ListZutat updatedItem, String newName) {
    //final datenDb = Provider.of<DatenDb>(context, listen: false);
    int index = inventar.indexWhere((item) => item.name == updatedItem.name);
    if (index != -1) {
      inventar[index].name = newName;
      _fetchAndLogRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final datenDb = Provider.of<DatenDb>(context);
    inventar = datenDb.inventar;

    return Scaffold(
      body: inventar.isEmpty
          ? const Center(
              child: EmptyPagePlaceholder(
                title: "Your inventory is empty!",
                message:
                    "Add items manually, or scan your pantry with your camera.",
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ItemList(
                    items: inventar,
                    toggleValueProvider: (item) =>
                        selectedItems[item.id] ?? false,
                    onItemChanged: _updateItem,
                    onItemNameChanged: _updateItemName,
                    onItemDeleted: _removeItem,
                    listKey: GlobalKey<AnimatedListState>(),
                  ),
                  // Conditionally render the carousel based on showCarousel flag
                  Text('Rezepte mit ausgewählten Zutaten', style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.6)),
                  if (isLoading && !showCarousel)
                    const CircularProgressIndicator(),
                  if (showCarousel)
                    ItemCarousel(
                      title: '',
                      items: rezepte,
                      onItemClicked: (int id) {
                        final openRezept =
                            rezepte.firstWhere((rezept) => rezept.id == id);
                        handleRecipeClicked(context, openRezept);
                      },
                    ),
                ],
              ),
            ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Zutaten hinzufügen',
            onTap: () => _handleAddItem(datenDb),
            shape: const CircleBorder(),
          ),
          SpeedDialChild(
            child: const Icon(Icons.camera_alt_outlined),
            label: 'Kühlschrankscanner',
            onTap: _handleOpenScanner,
            shape: const CircleBorder(),
          ),
        ],
      ),
    );
  }
}
