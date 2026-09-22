import '../../core/repositories/product_repository.dart';
import '../../data/models/product_model.dart';

class HomeViewModel {

  final ProductRepository productRepository;

  HomeViewModel(this.productRepository);

  Future<List<Product>> fetchProducts() {
    return productRepository.getProducts();
  }

  Future<List<String>> fetchCategories() {
    return productRepository.getCategories();
  }

  Future<List<Product>> searchProducts(String query) {
    return productRepository.searchProducts(query);
  }

  Future<List<Product>> fetchProductsByCategory(String category) {
    return productRepository.getProductsByCategory(category);
  }

}
