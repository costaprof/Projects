import 'dart:async';
import 'package:dio/dio.dart';
import 'package:queue/queue.dart';
import 'api_key.dart';

class MealApiService {
  static const String _baseUrl =
      'https://www.themealdb.com/api/json/v2/$MEALDB_API_KEY';
  final Dio _dio = Dio();

  // limits to 50 requests per 10 seconds
  final Queue _queue = Queue(parallel: 1, delay: const Duration(milliseconds: 200));

  Future<Map<String, dynamic>?> _performRequest(
      Future<Response> Function() request) async {
    return _queue.add(() async {
      try {
        final response = await request();
        if (response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Failed to load data');
        }
      } catch (error) {
        print('Error fetching request: $error');
      }
      return null;
    });
  }

  // Search meal by name
  Future<Map<String, dynamic>?> searchMealByName(String name) async {
    return await _performRequest(() {
      return _dio.get('$_baseUrl/search.php', queryParameters: {'s': name});
    });
  }

  // List all meals by first letter
  Future<Map<String, dynamic>?> listMealsByFirstLetter(String letter) async {
    return await _performRequest(() {
      return _dio.get('$_baseUrl/search.php', queryParameters: {'f': letter});
    });
  }

  // Filter by ingredients
  Future<Map<String, dynamic>?> filterByIngredients(
      List<String> ingredients) async {
    String formattedIngredients = ingredients.map((e) => e.trim()).join(',');

    String fullUrl = '$_baseUrl/filter.php?i=$formattedIngredients';
    try {
      var response = await _dio.get(fullUrl);

      if (response.statusCode == 200) {
        print('Response data: ${response.data}');
        return response.data;
      } else {
        print('Error: Received status code ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error making request: $e');
      return null;
    }
  }

  // Lookup full meal details by id
  Future<Map<String, dynamic>?> lookupMealById(String id) async {
    return await _performRequest(() {
      return _dio.get('$_baseUrl/lookup.php', queryParameters: {'i': id});
    });
  }

  // Lookup a single random meal
  Future<Map<String, dynamic>?> lookupRandomMeal() async {
    return await _performRequest(() {
      return _dio.get('$_baseUrl/random.php');
    });
  }

  // List all meal categories
  Future<Map<String, dynamic>?> listMealCategories() async {
    return await _performRequest(() {
      return _dio.get('$_baseUrl/categories.php');
    });
  }

  // List all Categories, Area, Ingredients
  Future<Map<String, dynamic>?> listAll(String type) async {
    return await _performRequest(() {
      return _dio.get('$_baseUrl/list.php', queryParameters: {type: 'list'});
    });
  }

  // Filter by main ingredient
  Future<Map<String, dynamic>?> filterByMainIngredient(
      String ingredient) async {
    return await _performRequest(() {
      return _dio
          .get('$_baseUrl/filter.php', queryParameters: {'i': ingredient});
    });
  }

  // Filter by Category
  Future<Map<String, dynamic>?> filterByCategory(String category) async {
    return await _performRequest(() {
      return _dio.get('$_baseUrl/filter.php', queryParameters: {'c': category});
    });
  }

  // Filter by Area
  Future<Map<String, dynamic>?> filterByArea(String area) async {
    return await _performRequest(() {
      return _dio.get('$_baseUrl/filter.php', queryParameters: {'a': area});
    });
  }
}
