import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_project/core/di/locator.dart';
import 'package:core_project/core/services/recently_viewed_service.dart';
import 'package:core_project/view_model/home_view_model/home_viewmodel.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/color/app_color.dart';
import '../../../core/theme/style/theme_style.dart';
import '../../../data/models/product_model.dart';
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

  final TextEditingController _searchController =
  TextEditingController();

  final ScrollController _hotSalesScrollController =
  ScrollController();

  int _selectedCategoryIndex = 0;
  int _hotSalesCurrentIndex = 0;

  HomeViewModel get _homeViewModel => locator<HomeViewModel>();

  @override
  void initState() {
    super.initState();

    _loadInitialData();

    _hotSalesScrollController.addListener(
      _onHotSalesScroll,
    );
  }

  // =========================================================
  // INITIAL DATA
  // =========================================================

  void _loadInitialData() {
    _productsFuture = _homeViewModel.fetchProducts();
    _categoriesFuture = _homeViewModel.fetchCategories();
    _recentlyViewedFuture =
        RecentlyViewedService.getRecentlyViewed();
  }

  // =========================================================
  // HOT SALES SCROLL
  // =========================================================

  void _onHotSalesScroll() {
    final double offset =
        _hotSalesScrollController.offset;

    final int index =
    (offset / 176).round().clamp(0, 2);

    if (index == _hotSalesCurrentIndex) {
      return;
    }

    setState(() {
      _hotSalesCurrentIndex = index;
    });
  }

  // =========================================================
  // SEARCH
  // =========================================================

  void _onSearch(String query) {
    final String searchQuery = query.trim();

    setState(() {
      _productsFuture = searchQuery.isEmpty
          ? _homeViewModel.fetchProducts()
          : _homeViewModel.searchProducts(searchQuery);
    });
  }

  // =========================================================
  // CATEGORY
  // =========================================================

  void _onCategorySelected(
      int index,
      String category,
      ) {
    setState(() {
      _selectedCategoryIndex = index;

      if (index == 0 ||
          category.toLowerCase() == 'all') {
        _productsFuture =
            _homeViewModel.fetchProducts();
      } else {
        _productsFuture =
            _homeViewModel.fetchProductsByCategory(
              category,
            );
      }
    });
  }

  // =========================================================
  // RECENTLY VIEWED
  // =========================================================

  void _refreshRecentlyViewed() {
    setState(() {
      _recentlyViewedFuture =
          RecentlyViewedService.getRecentlyViewed();
    });
  }

  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> _onRefresh() async {
    setState(() {
      _selectedCategoryIndex = 0;
      _searchController.clear();

      _productsFuture =
          _homeViewModel.fetchProducts();

      _categoriesFuture =
          _homeViewModel.fetchCategories();

      _recentlyViewedFuture =
          RecentlyViewedService.getRecentlyViewed();
    });

    await Future.wait([
      _productsFuture,
      _categoriesFuture,
      _recentlyViewedFuture,
    ]);
  }

  // =========================================================
  // SEARCH BAR
  // =========================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
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
                  hintText:
                  'Search products (e.g. phone)...',
                  hintStyle:
                  AppTextStyle.interRegular(
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
                    icon: const Icon(
                      Icons.clear,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          _buildNotificationButton(),
        ],
      ),
    );
  }

  // =========================================================
  // NOTIFICATION
  // =========================================================

  Widget _buildNotificationButton() {
    return Container(
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
    );
  }

  // =========================================================
  // PROMOTIONAL BANNER
  // =========================================================

  Widget _buildPromotionalBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
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
              child: _buildBannerText(),
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
    );
  }

  Widget _buildBannerText() {
    return Column(
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
          textBaseline:
          TextBaseline.alphabetic,
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
    );
  }

  // =========================================================
  // CATEGORY SECTION
  // =========================================================

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
      ),
      child: SizedBox(
        height: 40,
        child: FutureBuilder<List<String>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final categories = [
              'All',
              ...(snapshot.data ?? []),
            ];

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) =>
              const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category =
                categories[index];

                final isSelected =
                    _selectedCategoryIndex == index;

                return GestureDetector(
                  onTap: () =>
                      _onCategorySelected(
                        index,
                        category,
                      ),
                  child: CategoryChip(
                    label: _formatCategory(
                      category,
                    ),
                    isSelected: isSelected,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatCategory(String category) {
    if (category.isEmpty) {
      return category;
    }

    return category[0].toUpperCase() +
        category.substring(1);
  }

  // =========================================================
  // HOT SALES HEADER
  // =========================================================

  Widget _buildHotSalesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hot sales',
            style: AppTextStyle.ppMoriSemiBold(
              textSize: 18,
              textColor: AppColors.black,
            ),
          ),

          Row(
            children: List.generate(
              3,
                  (index) {
                final isActive =
                    _hotSalesCurrentIndex == index;

                return AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 200),
                  margin:
                  const EdgeInsets.only(left: 4),
                  width: isActive ? 16 : 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.orange
                        : AppColors.grey,
                    borderRadius:
                    BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HOT SALES
  // =========================================================

  Widget _buildHotSales() {
    return SizedBox(
      height: 220,
      child: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.orange,
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorMessage(
              'Failed to load products: ${snapshot.error}',
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return _buildEmptyMessage(
              'No products found',
            );
          }

          return ListView.separated(
            controller: _hotSalesScrollController,
            scrollDirection: Axis.horizontal,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            itemCount: products.length,
            separatorBuilder: (_, __) =>
            const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                backgroundColor:
                AppColors.ultraLightGrey
                    .withOpacity(0.5),
                onProductTapped:
                _refreshRecentlyViewed,
              );
            },
          );
        },
      ),
    );
  }

  // =========================================================
  // RECENTLY VIEWED HEADER
  // =========================================================

  Widget _buildRecentlyViewedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Text(
        'Recently viewed',
        style: AppTextStyle.ppMoriSemiBold(
          textColor: AppColors.black,
          textSize: 18,
        ),
      ),
    );
  }

  // =========================================================
  // RECENTLY VIEWED
  // =========================================================

  Widget _buildRecentlyViewed() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: FutureBuilder<List<Product>>(
        future: _recentlyViewedFuture,
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Padding(
              padding:
              const EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: Text(
                'No recently viewed products yet. '
                    'Tap any product to view details!',
                style: AppTextStyle.interRegular(
                  textColor: AppColors.grey,
                  textSize: 12,
                ),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                backgroundColor: index.isEven
                    ? const Color(0xFFFFF6E0)
                    : const Color(0xFFFFEEEE),
                onProductTapped:
                _refreshRecentlyViewed,
              );
            },
          );
        },
      ),
    );
  }

  // =========================================================
  // COMMON ERROR
  // =========================================================

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyle.interRegular(
            textColor: AppColors.red,
            textSize: 12,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // COMMON EMPTY MESSAGE
  // =========================================================

  Widget _buildEmptyMessage(String message) {
    return Center(
      child: Text(
        message,
        style: AppTextStyle.interRegular(
          textColor: AppColors.grey,
          textSize: 14,
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.orange,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.symmetric(
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // Search
              _buildSearchBar(),

              const SizedBox(height: 20),

              // Banner
              _buildPromotionalBanner(),

              const SizedBox(height: 7),

              // Banner information
              Center(
                child: Text(
                  '*Valid from 27/03 to 01/04 2022. '
                      'Min stock: 1 unit',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.interRegular(
                    textColor: AppColors.black,
                    textSize: 10,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Categories
              _buildCategories(),

              const SizedBox(height: 24),

              // Hot sales header
              _buildHotSalesHeader(),

              const SizedBox(height: 16),

              // Hot sales
              _buildHotSales(),

              const SizedBox(height: 24),

              // Recently viewed header
              _buildRecentlyViewedHeader(),

              const SizedBox(height: 16),

              // Recently viewed
              _buildRecentlyViewed(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hotSalesScrollController.removeListener(
      _onHotSalesScroll,
    );
    _hotSalesScrollController.dispose();
    _searchController.dispose();

    super.dispose();
  }
}

// =============================================================
// CATEGORY CHIP
// =============================================================

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
  });

  static const Color _primaryColor =
  Color(0xFF6B4EE6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.orange
            : AppColors.white,
        border: Border.all(
          color: isSelected
              ? AppColors.orange
              : AppColors.white,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyle.interSemiBold(
          textSize: 13,
          textColor: isSelected
              ? AppColors.white
              : AppColors.black,
        ),
      ),
    );
  }
}

// =============================================================
// PRODUCT CARD
// =============================================================

class ProductCard extends StatelessWidget {
  final Product product;
  final Color backgroundColor;
  final VoidCallback? onProductTapped;

  const ProductCard({
    super.key,
    required this.product,
    required this.backgroundColor,
    this.onProductTapped,
  });

  Future<void> _openProductDetails(
      BuildContext context,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailPage(
              product: product,
            ),
      ),
    );

    onProductTapped?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          _openProductDetails(context),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius:
          BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildProductImage(),
            ),

            const SizedBox(height: 8),

            _buildProductTitle(),

            const SizedBox(height: 4),

            _buildProductPrice(),

            const SizedBox(height: 8),

            _buildShippingLabel(),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PRODUCT IMAGE
  // =========================================================

  Widget _buildProductImage() {
    return Center(
      child: CachedNetworkImage(
        imageUrl: product.thumbnail,
        height: 100,
        width: 130,
        fit: BoxFit.contain,
        placeholder: (_, __) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorWidget: (_, __, ___) {
          return const Icon(
            Icons.error,
          );
        },
      ),
    );
  }

  // =========================================================
  // PRODUCT TITLE
  // =========================================================

  Widget _buildProductTitle() {
    return Text(
      product.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyle.interSemiBold(
        textSize: 13,
        textColor: AppColors.black,
      ),
    );
  }

  // =========================================================
  // PRODUCT PRICE
  // =========================================================

  Widget _buildProductPrice() {
    return Text(
      '\$ ${product.price.toStringAsFixed(2)}',
      style: AppTextStyle.interBold(
        textSize: 15,
        textColor: AppColors.black,
      ),
    );
  }

  // =========================================================
  // SHIPPING LABEL
  // =========================================================

  Widget _buildShippingLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Text(
        'Free shipping',
        style: AppTextStyle.interSemiBold(
          textSize: 10,
          textColor: AppColors.green,
        ),
      ),
    );
  }
}