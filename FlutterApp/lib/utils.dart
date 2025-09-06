
import 'package:flutter/material.dart';
import 'package:was_essen/DatenDb/rezepte_table.dart';

import '../models/rezept.dart';
import '../services/my_food_db.dart';
import '../widgets/rezept_karte.dart';

Future<List<Rezept>> fetchRecipesByCategory(
    {required MealApiService apiService, required String category}) async {
  try {
    final response = await apiService.filterByCategory(category);
    return await getRezepteFromResponse(response: response);
  } catch (error) {
    print('Error fetching recipes: $error');
  }
  return [];
}

Future<List<Rezept>> getRezepteFromResponse({required Map<String, dynamic>? response}) async{
  List<Rezept> rezepte = [];
  if (response != null && response['meals'] != null) {
    final List<dynamic> meals = response['meals'];
    List<int> idMeals = [];
    for (var meal in meals) {
      idMeals.add(int.parse(meal['idMeal']));
    }
    RezepteTable rezepteTable = RezepteTable();
    for (int idMeal in idMeals) {
      if (await rezepteTable.checkIfRezeptIdNotExists(id: idMeal)) {
        await rezepteTable.addRezeptFromMfdId(id: idMeal);
      }
    }
    for (int idMeal in idMeals) {
      Rezept? sqRezept = await rezepteTable.fetchRezeptByID(id: idMeal);
      if (sqRezept != null) {
        rezepte.add(sqRezept);
      }
    }
  }
  return rezepte;
}

Future<void> handleRecipeClicked(BuildContext context, Rezept rezept) async {
  Navigator.of(context).push(
    PageRouteBuilder(
      reverseTransitionDuration: Durations.short4,
      pageBuilder: (context, animation, secondaryAnimation) =>
          RezeptKarte(rezept: rezept),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}
