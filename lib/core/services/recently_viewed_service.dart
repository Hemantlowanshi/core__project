import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/product_model.dart';

class RecentlyViewedService {
  static const String _key = 'recently_viewed_products';

  static Future<void> addProduct(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_key) ?? [];

    // Remove if already exists to avoid duplicates, put at the beginning
    list.removeWhere((item) {
      final map = jsonDecode(item);
      return map['id'] == product.id;
    });

    final productJson = jsonEncode({
      'id': product.id,
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'thumbnail': product.thumbnail,
    });

    list.insert(0, productJson);

    if (list.length > 10) {
      list = list.sublist(0, 10);
    }

    await prefs.setStringList(_key, list);
  }

  static Future<List<Product>> getRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_key) ?? [];
    return list.map((item) {
      final map = jsonDecode(item);
      return Product.fromJson(map);
    }).toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
