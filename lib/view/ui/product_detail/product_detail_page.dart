import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_project/core/services/recently_viewed_service.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/color/app_color.dart';
import '../../../core/theme/style/theme_style.dart';
import '../../../data/models/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() =>
      _ProductDetailPageState();
}

class _ProductDetailPageState
    extends State<ProductDetailPage> {
  Product get product => widget.product;

  @override
  void initState() {
    super.initState();

    RecentlyViewedService.addProduct(product);
  }

  // =========================================================
  // APP BAR
  // =========================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.favorite_border,
            color: AppColors.black,
          ),
          onPressed: _onFavoritePressed,
        ),
        IconButton(
          icon: const Icon(
            Icons.share_outlined,
            color: AppColors.black,
          ),
          onPressed: _onSharePressed,
        ),
      ],
    );
  }

  // =========================================================
  // PRODUCT IMAGE
  // =========================================================

  Widget _buildProductImage() {
    return Center(
      child: Hero(
        tag: 'product_${product.id}',
        child: CachedNetworkImage(
          imageUrl: product.thumbnail,
          height: 260,
          fit: BoxFit.contain,
          placeholder: (context, url) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          },
          errorWidget: (context, url, error) {
            return const Icon(
              Icons.error,
              size: 50,
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // PRODUCT TITLE + RATING
  // =========================================================

  Widget _buildTitleAndRating() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            product.title,
            style: AppTextStyle.ppMoriSemiBold(
              textSize: 22,
              textColor: AppColors.black,
            ),
          ),
        ),

        const SizedBox(width: 12),

        _buildRating(),
      ],
    );
  }

  // =========================================================
  // RATING
  // =========================================================

  Widget _buildRating() {
    return Row(
      children: [
        const Icon(
          Icons.star,
          color: Colors.amber,
          size: 18,
        ),

        const SizedBox(width: 4),

        Text(
          '4.8',
          style: AppTextStyle.interBold(
            textSize: 14,
            textColor: AppColors.black,
          ),
        ),

        Text(
          ' (231)',
          style: AppTextStyle.interRegular(
            textSize: 12,
            textColor: AppColors.grey,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // PRICE
  // =========================================================

  Widget _buildPrice() {
    return Text(
      '\$ ${product.price.toStringAsFixed(2)}',
      style: AppTextStyle.interBold(
        textSize: 24,
        textColor: AppColors.orange,
      ),
    );
  }

  // =========================================================
  // DESCRIPTION
  // =========================================================

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTextStyle.interBold(
            textSize: 16,
            textColor: AppColors.black,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          product.description,
          style: AppTextStyle.interRegular(
            textSize: 14,
            textColor: AppColors.textSecondary,
          ).copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ADD TO CART
  // =========================================================

  void _addToCart() {
    _showMessage(
      'Added to cart successfully!',
    );
  }

  // =========================================================
  // BUY NOW
  // =========================================================

  void _buyNow() {
    _showMessage(
      'Proceeding to checkout...',
    );
  }

  // =========================================================
  // FAVORITE
  // =========================================================

  void _onFavoritePressed() {
    // TODO: Add favorite functionality.
  }

  // =========================================================
  // SHARE
  // =========================================================

  void _onSharePressed() {
    // TODO: Add share functionality.
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  // =========================================================
  // BOTTOM ACTION BAR
  // =========================================================

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color:
            AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: 'Add to cart',
                backgroundColor:
                AppColors.black,
                onPressed: _addToCart,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _buildActionButton(
                title: 'Buy Now',
                backgroundColor:
                AppColors.orange,
                onPressed: _buyNow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ACTION BUTTON
  // =========================================================

  Widget _buildActionButton({
    required String title,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(26),
          ),
        ),
        child: Text(
          title,
          style: AppTextStyle.interBold(
            textSize: 16,
            textColor: AppColors.white,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // PRODUCT CONTENT
  // =========================================================

  Widget _buildProductContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildProductImage(),

          const SizedBox(height: 20),

          _buildTitleAndRating(),

          const SizedBox(height: 10),

          _buildPrice(),

          const SizedBox(height: 20),

          _buildDescription(),
        ],
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      appBar: _buildAppBar(),

      body: Column(
        children: [
          Expanded(
            child: _buildProductContent(),
          ),

          _buildBottomActions(),
        ],
      ),
    );
  }
}