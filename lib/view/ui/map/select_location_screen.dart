import 'package:flutter/material.dart';

import '../../../core/theme/color/app_color.dart';
import '../../../core/theme/style/theme_style.dart';
import '../../../data/models/address_item.dart';
import 'map_screen.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final List<AddressItem> _addresses = [];

  void _selectAddress(int index) {
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i].isSelected = (i == index);
      }
    });
  }

  void _deleteAddress(int index) {
    setState(() {
      _addresses.removeAt(index);
      if (_addresses.isNotEmpty && !_addresses.any((e) => e.isSelected)) {
        _addresses[0].isSelected = true;
      }
    });
  }

  Future<void> _addNewAddress() async {
    final AddressItem? newAddress = await Navigator.push<AddressItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
      ),
    );

    if (!mounted || newAddress == null) return;

    setState(() {
      for (var item in _addresses) {
        item.isSelected = false;
      }
      _addresses.add(newAddress);
    });
  }

  Future<void> _editAddress(int index) async {
    final AddressItem addressToEdit = _addresses[index];
    final AddressItem? updatedAddress = await Navigator.push<AddressItem>(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(existingAddress: addressToEdit),
      ),
    );

    if (!mounted || updatedAddress == null) return;

    setState(() {
      _addresses[index] = updatedAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: AppColors.ultraLightGrey,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 16),
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
            icon: const Icon(Icons.add, color: Color(0xFF6B4EE6), size: 18),
            label: Text(
              'Add New',
              style: AppTextStyle.interSemiBold(
                textSize: 14,
                textColor: const Color(0xFF6B4EE6),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_outlined, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No saved addresses yet',
                    style: AppTextStyle.interSemiBold(textSize: 16, textColor: AppColors.grey),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
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
                            ? const Color(0xFF6B4EE6)
                            : AppColors.border,
                        width: address.isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              address.name,
                              style: AppTextStyle.interBold(
                                textSize: 16,
                                textColor: AppColors.black,
                              ),
                            ),
                            Radio<bool>(
                              value: true,
                              groupValue: address.isSelected,
                              activeColor: const Color(0xFF6B4EE6),
                              onChanged: (val) => _selectAddress(index),
                            ),
                          ],
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _editAddress(index),
                              icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF6B4EE6)),
                              label: Text(
                                'Edit',
                                style: AppTextStyle.interSemiBold(
                                  textSize: 13,
                                  textColor: const Color(0xFF6B4EE6),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _deleteAddress(index),
                              icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.red),
                              label: Text(
                                'Delete',
                                style: AppTextStyle.interSemiBold(
                                  textSize: 13,
                                  textColor: AppColors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
