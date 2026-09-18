import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_project/core/services/recently_viewed_service.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/color/app_color.dart';
import '../../../core/theme/style/theme_style.dart';
import '../../../data/models/product_model.dart';
import '../../../core/services/product_service.dart';
import '../product_detail/product_detail_page.dart';

class ECommerceHomePage extends StatefulWidget {
  const ECommerceHomePage({super.key});

  @override
  State<ECommerceHomePage> createState() => _ECommerceHomePageState();
}

class _ECommerceHomePageState extends State<ECommerceHomePage> {
  late Future<List<Product>> _productsFuture;
  late Future<List<String>> _categoriesFuture;
  late Future<List<Product>> _recentlyViewedFuture;
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _hotSalesScrollController = ScrollController();
  int _hotSalesCurrentIndex = 0;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService().fetchProducts();
    _categoriesFuture = ProductService().fetchCategories();
    _recentlyViewedFuture = RecentlyViewedService.getRecentlyViewed();
    _hotSalesScrollController.addListener(() {
      final offset = _hotSalesScrollController.offset;
      final index = (offset / 176).round().clamp(0, 2);
      if (index != _hotSalesCurrentIndex) {
        setState(() {
          _hotSalesCurrentIndex = index;
        });
      }
    });
  }

  void _onSearch(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _productsFuture = ProductService().fetchProducts();
      } else {
        _productsFuture = ProductService().searchProducts(query.trim());
      }
    });
  }

  void _onCategorySelected(int index, String category) {
    setState(() {
      _selectedCategoryIndex = index;
      if (index == 0 || category.toLowerCase() == 'all') {
        _productsFuture = ProductService().fetchProducts();
      } else {
        _productsFuture = ProductService().fetchProductsByCategory(category);
      }
    });
  }

  void _refreshRecentlyViewed() {
    setState(() {
      _recentlyViewedFuture = RecentlyViewedService.getRecentlyViewed();
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _selectedCategoryIndex = 0;
      _searchController.clear();
      _productsFuture = ProductService().fetchProducts();
      _categoriesFuture = ProductService().fetchCategories();
      _recentlyViewedFuture = RecentlyViewedService.getRecentlyViewed();
    });
    await Future.wait([_productsFuture, _categoriesFuture, _recentlyViewedFuture]);
  }

  @override
  void dispose() {
    _hotSalesScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.orange,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SEARCH AND NOTIFICATION BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _onSearch,
                          decoration: InputDecoration(
                            hintText: 'Search products (e.g. phone)...',
                            hintStyle: AppTextStyle.interRegular(
                              textSize: 14,
                              textColor: AppColors.grey,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Image.asset(
                                'assets/images/search.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none,
                            color: AppColors.black,
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PROMOTIONAL BANNER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  height: 190,
                  padding: const EdgeInsets.only(
                    left: 29,
                    right: 16,
                    top: 12,
                    bottom: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.purple,
                        AppColors.pink,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CYBER\nLINIO',
                              style: AppTextStyle.interBold(
                                textColor: AppColors.yellow,
                                textSize: 26,
                              ).copyWith(
                                height: 0.95,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '40%',
                                  style: AppTextStyle.interSemiBold(
                                    textSize: 22,
                                    textColor: AppColors.white,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'DSCNT',
                                  style: AppTextStyle.interRegular(
                                    textSize: 9,
                                    textColor: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'in technology',
                              style: AppTextStyle.interSemiBold(
                                textSize: 13,
                                textColor: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'FREE SHIPPING',
                                style: AppTextStyle.interBold(
                                  textSize: 8,
                                  textColor: AppColors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Image.asset(
                            'assets/images/com.png',
                            height: 200,
                            width: 290,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 7),

              Center(
                child: Text(
                  '*Valid from 27/03 to 01/04 2022. Min stock: 1 unit',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.interRegular(
                    textColor: AppColors.black,
                    textSize: 10,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CATEGORY FILTER (DYNAMIC FROM API)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SizedBox(
                  height: 40,
                  child: FutureBuilder<List<String>>(
                    future: _categoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      final categories = ['All', ...(snapshot.data ?? [])];

                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = _selectedCategoryIndex == index;
                          return GestureDetector(
                            onTap: () => _onCategorySelected(index, category),
                            child: CategoryChip(
                              label: category[0].toUpperCase() +
                                  category.substring(1),
                              isSelected: isSelected,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // HOT SALES HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hot sales',
                      style: AppTextStyle.ppMoriSemiBold(
                        textSize: 18,
                        textColor: AppColors.black,
                      ),
                    ),
                    Row(
                      children: List.generate(3, (index) {
                        final isActive = _hotSalesCurrentIndex == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(left: 4),
                          width: isActive ? 16 : 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.orange : AppColors.grey,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // HOT SALES (DYNAMIC FROM API)
              SizedBox(
                height: 220,
                child: FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.orange,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Failed to load products: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.interRegular(
                              textColor: AppColors.red,
                              textSize: 12,
                            ),
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No products found',
                          style: AppTextStyle.interRegular(
                            textColor: AppColors.grey,
                            textSize: 14,
                          ),
                        ),
                      );
                    }

                    final products = snapshot.data!;

                    return ListView.separated(
                      controller: _hotSalesScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onProductTapped: _refreshRecentlyViewed,
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // RECENTLY VIEWED HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Recently viewed',
                  style: AppTextStyle.ppMoriSemiBold(
                    textColor: AppColors.black,
                    textSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // RECENTLY VIEWED (GRID FORM - 2 COLUMNS)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FutureBuilder<List<Product>>(
                  future: _recentlyViewedFuture,
                  builder: (context, snapshot) {
                    final recentProducts = snapshot.data ?? [];
                    if (recentProducts.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No recently viewed products yet. Tap any product to view details!',
                          style: AppTextStyle.interRegular(
                            textColor: AppColors.grey,
                            textSize: 12,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentProducts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final product = recentProducts[index];
                        return RecentCard(
                          backgroundColor: index % 2 == 0
                              ? const Color(0xFFFFF6E0)
                              : const Color(0xFFFFEEEE),
                          product: product,
                          onProductTapped: _refreshRecentlyViewed,
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// CATEGORY CHIP
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.orange : AppColors.white,
        border: Border.all(
          color: isSelected ? AppColors.orange : AppColors.white,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyle.interSemiBold(
          textSize: 13,
          textColor: isSelected ? AppColors.white : AppColors.black,
        ),
      ),
    );
  }
}

// PRODUCT CARD
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onProductTapped;

  const ProductCard({
    super.key,
    required this.product,
    this.onProductTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
        onProductTapped?.call();
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.ultraLightGrey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: product.thumbnail,
                  height: 100,
                  width: 130,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.interSemiBold(
                textSize: 13,
                textColor: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$ ${product.price.toStringAsFixed(2)}',
              style: AppTextStyle.interBold(
                textSize: 15,
                textColor: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Free shipping',
                style: AppTextStyle.interSemiBold(
                  textSize: 10,
                  textColor: AppColors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// RECENT CARD
class RecentCard extends StatelessWidget {
  final Color backgroundColor;
  final Product product;
  final VoidCallback? onProductTapped;

  const RecentCard({
    super.key,
    required this.backgroundColor,
    required this.product,
    this.onProductTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
        onProductTapped?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: product.thumbnail,
                  height: 100,
                  width: 130,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.interSemiBold(
                textSize: 13,
                textColor: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$ ${product.price.toStringAsFixed(2)}',
              style: AppTextStyle.interBold(
                textSize: 15,
                textColor: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Free shipping',
                style: AppTextStyle.interSemiBold(
                  textSize: 10,
                  textColor: AppColors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
