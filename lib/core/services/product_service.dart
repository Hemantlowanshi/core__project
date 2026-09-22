import '../../data/models/product_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class ProductService {
  final ApiClient _apiClient;
  ProductService(this._apiClient);
  Future<List<Product>> fetchProducts() async {
    final response = await _apiClient.get(ApiEndpoints.products);
    final data = response.data;
    final List<dynamic> productsJson = data['products'] ?? [];
    return productsJson.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await _apiClient.get(
      ApiEndpoints.searchProducts,
      queryParameters: {'q': query},
    );
    final data = response.data;
    final List<dynamic> productsJson = data['products'] ?? [];
    return productsJson.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.categoryProducts}/$category',
    );
    final data = response.data;
    final List<dynamic> productsJson = data['products'] ?? [];
    return productsJson.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<String>> fetchCategories() async {
    final response = await _apiClient.get(ApiEndpoints.categoryList);
    final data = response.data;
    if (data is List) {
      return data.map((item) {
        if (item is String) {
          return item;
        } else if (item is Map && item.containsKey('name')) {
          return item['name'].toString();
        } else if (item is Map && item.containsKey('slug')) {
          return item['slug'].toString();
        }
        return item.toString();
      }).toList();
    }
    return [];
  }
}
