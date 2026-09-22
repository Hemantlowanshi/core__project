import 'package:flutter/material.dart';

import '../../../core/theme/color/app_color.dart';
import '../../../core/theme/style/theme_style.dart';
import '../../../data/models/address_item.dart';
import 'map_screen.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() =>
      _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final List<AddressItem> _addresses = [];

  // =========================================================
  // SELECT ADDRESS
  // =========================================================

  void _selectAddress(int index) {
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i].isSelected = i == index;
      }
    });
  }

  // =========================================================
  // DELETE ADDRESS
  // =========================================================

  void _deleteAddress(int index) {
    setState(() {
      _addresses.removeAt(index);

      if (_addresses.isNotEmpty &&
          !_addresses.any((address) => address.isSelected)) {
        _addresses.first.isSelected = true;
      }
    });
  }

  // =========================================================
  // ADD NEW ADDRESS
  // =========================================================

  Future<void> _addNewAddress() async {
    final AddressItem? newAddress =
    await Navigator.push<AddressItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
      ),
    );

    if (!mounted || newAddress == null) {
      return;
    }

    setState(() {
      _unselectAll();

      newAddress.isSelected = true;
      _addresses.add(newAddress);
    });
  }

  // =========================================================
  // EDIT ADDRESS
  // =========================================================

  Future<void> _editAddress(int index) async {
    final AddressItem currentAddress = _addresses[index];

    final AddressItem? updatedAddress =
    await Navigator.push<AddressItem>(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          existingAddress: currentAddress,
        ),
      ),
    );

    if (!mounted || updatedAddress == null) {
      return;
    }

    setState(() {
      _addresses[index] = updatedAddress;

      // Keep only this address selected.
      _selectAddress(index);
    });
  }

  // =========================================================
  // UNSELECT ALL
  // =========================================================

  void _unselectAll() {
    for (final address in _addresses) {
      address.isSelected = false;
    }
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_off_outlined,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved addresses yet',
            style: AppTextStyle.interSemiBold(
              textSize: 16,
              textColor: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ADDRESS LIST
  // =========================================================

  Widget _buildAddressList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        return _buildAddressCard(
          address: _addresses[index],
          index: index,
        );
      },
    );
  }

  // =========================================================
  // ADDRESS CARD
  // =========================================================

  Widget _buildAddressCard({
    required AddressItem address,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => _selectAddress(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: address.isSelected
                ? AppColors.primaryPurple
                : AppColors.border,
            width: address.isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressHeader(
              address: address,
              index: index,
            ),

            const SizedBox(height: 6),

            Text(
              address.address,
              style: AppTextStyle.interRegular(
                textSize: 13,
                textColor: AppColors.grey,
              ),
            ),

            const SizedBox(height: 16),

            _buildAddressActions(index),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ADDRESS HEADER
  // =========================================================

  Widget _buildAddressHeader({
    required AddressItem address,
    required int index,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            address.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.interBold(
              textSize: 16,
              textColor: AppColors.black,
            ),
          ),
        ),

        Radio<bool>(
          value: true,
          groupValue: address.isSelected,
          activeColor: AppColors.primaryPurple,
          onChanged: (_) => _selectAddress(index),
        ),
      ],
    );
  }

  // =========================================================
  // EDIT / DELETE BUTTONS
  // =========================================================

  Widget _buildAddressActions(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () => _editAddress(index),
          icon: const Icon(
            Icons.edit_outlined,
            size: 16,
            color: AppColors.primaryPurple,
          ),
          label: Text(
            'Edit',
            style: AppTextStyle.interSemiBold(
              textSize: 13,
              textColor: AppColors.primaryPurple,
            ),
          ),
        ),

        const SizedBox(width: 8),

        TextButton.icon(
          onPressed: () => _deleteAddress(index),
          icon: const Icon(
            Icons.delete_outline,
            size: 16,
            color: AppColors.red,
          ),
          label: Text(
            'Delete',
            style: AppTextStyle.interSemiBold(
              textSize: 13,
              textColor: AppColors.red,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // APP BAR
  // =========================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: AppColors.ultraLightGrey,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.black,
              size: 16,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Text(
        'Select Location',
        style: AppTextStyle.ppMoriSemiBold(
          textSize: 18,
          textColor: AppColors.black,
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _addNewAddress,
          icon: const Icon(
            Icons.add,
            color: AppColors.primaryPurple,
            size: 18,
          ),
          label: Text(
            'Add New',
            style: AppTextStyle.interSemiBold(
              textSize: 14,
              textColor: AppColors.primaryPurple,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _addresses.isEmpty
          ? _buildEmptyState()
          : _buildAddressList(),
    );
  }
}