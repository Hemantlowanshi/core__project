import 'product_repository.dart';
import '../../data/models/product_model.dart';
import '../../core/services/product_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductService _productService;

  ProductRepositoryImpl(this._productService);

  @override
  Future<List<Product>> getProducts() => _productService.fetchProducts();

  @override
  Future<List<Product>> searchProducts(String query) =>
      _productService.searchProducts(query);

  @override
  Future<List<Product>> getProductsByCategory(String category) =>
      _productService.fetchProductsByCategory(category);

  @override
  Future<List<String>> getCategories() => _productService.fetchCategories();
}
