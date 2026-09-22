import 'package:get_it/get_it.dart';
import '../../view_model/home_view_model/home_viewmodel.dart';
import '../network/api_client.dart';
import '../repositories/product_repository.dart';
import '../repositories/product_repository_impl.dart';
import '../services/product_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register ApiClient
  locator.registerLazySingleton<ApiClient>(() => ApiClient());

  // Register ProductService
  locator.registerLazySingleton<ProductService>(
    () => ProductService(locator<ApiClient>()),
  );

  // Register ProductRepository
  locator.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(locator<ProductService>()),
  );

  // Register HomeViewModel
  locator.registerLazySingleton<HomeViewModel>(
    () => HomeViewModel(locator<ProductRepository>()),
  );
}
