import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import 'package:new_application_api/config.dart';

class CategoryService {
  List<Category>? _cachedCategories;

  final String baseUrl = '${AppConfig.baseUrl}/categories';

  Future<List<Category>> getCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }

    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      _cachedCategories =
          jsonResponse.map((category) => Category.fromJson(category)).toList();

      return _cachedCategories!;
    } else {
      throw Exception('Ocurrio un error');
    }
  }

  Future<Category> getCategory(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ocurrio un error');
    }
  }
}
