
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:was_essen/models/rezept.dart';
import 'package:was_essen/utils.dart';
import 'package:provider/provider.dart';
import 'package:was_essen/widgets/empty_page_placeholder.dart';

import '../widgets/item_carousel.dart';
import '../my_homepage.dart';
import '../search_reciep.dart';
import '../services/my_food_db.dart';
import '../DatenDb/datendb.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MealApiService _mealApiService = MealApiService();
  List<Rezept> _dessertRecipes = [];
  List<Rezept> _pastaRecipes = [];
  List<Rezept> _veganRecipes = [];
  bool _isLoading = true;
  bool fetched = false;
  bool updated = false;

  @override
  void initState() {
    super.initState();
    isSearchRezeptPressed.value = false;
    fetchInitRecipes();
  }

  Future<void> fetchInitRecipes() async {
    try {
      DateTime starttime = DateTime.now();
      final dessertRecipes = await fetchRecipesByCategory(
          apiService: _mealApiService, category: 'Dessert');
      final pastaRecipes = await fetchRecipesByCategory(
          apiService: _mealApiService, category: 'Pasta');
      final veganRecipes = await fetchRecipesByCategory(
          apiService: _mealApiService, category: 'Vegan');
      print('fetchInitRecipes Starttime: ${starttime.toIso8601String()}');
      DateTime endtime = DateTime.now();
      print('fetchInitRecipes Endtime: ${endtime.toIso8601String()}');
      print(
          'Laufzeit: ${endtime.difference(starttime).inMilliseconds.toString()}ms');

      setState(() {
        _dessertRecipes = dessertRecipes;
        _pastaRecipes = pastaRecipes;
        _veganRecipes = veganRecipes;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching recipes: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (updated) {
      fetchInitRecipes();
      updated = false;
    }
    var datendb = context.watch<DatenDb>();
    return ValueListenableBuilder(
      valueListenable: isSearchRezeptPressed,
      builder: (context, value, _) {
        if (_isLoading) {
          return const EmptyPagePlaceholder(
            title: 'Daten werden geladen.',
            message:
                'Dies kann beim erstmaligen Öffnen der App etwa 80 Sekunden in Anspruch nehmen.',
            isLoading: true,
          );
        } else {
          if (!fetched) {
            datendb.fetchRezepte();
            datendb.fetchZutaten();
            datendb.fetchRezeptZutaten();
            fetched = true;
          }
        }
        return isSearchRezeptPressed.value
            ? SearchReciepe(reciepeList: _dessertRecipes)
            : _homePageRecieps(context);
      },
    );
  }

  Widget _homePageRecieps(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildItemCarousel('Pasta Party', context, _pastaRecipes),
          _buildItemCarousel('Vegane Woche', context, _veganRecipes),
          _buildItemCarousel('Nachtisch', context, _dessertRecipes),
        ],
      ),
    );
  }

  Widget _buildItemCarousel(
      String title, BuildContext context, List<Rezept> rezepte) {
    return ItemCarousel(
      title: title,
      items: rezepte,
      onItemClicked: (itemID) {
        final openRezept = rezepte.firstWhere((rezept) => rezept.id == itemID);
        handleRecipeClicked(context, openRezept);
        updated = true;
      },
    );
  }
}
