import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/color/app_color.dart';
import '../../../core/theme/style/theme_style.dart';
import '../../../data/models/address_item.dart';
import '../../../view_model/map_view_model/map_viewmodel.dart';

class MapScreen extends StatefulWidget {
  final AddressItem? existingAddress;

  const MapScreen({
    super.key,
    this.existingAddress,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapViewModel _viewModel;
  GoogleMapController? _mapController;
  final TextEditingController _locationNameController =
      TextEditingController();

  bool get _isEditing => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();
    _viewModel = locator<MapViewModel>();

    if (_isEditing) {
      _viewModel.loadExistingAddress(widget.existingAddress!);
      _locationNameController.text = widget.existingAddress!.name;
    } else {
      _initCurrentLocation();
    }
  }

  Future<void> _initCurrentLocation() async {
    final location = await _viewModel.determinePosition();
    if (location != null && mounted) {
      await _moveCamera(location);
    }
  }

  Future<void> _moveCamera(LatLng location) async {
    if (_mapController == null) return;
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15),
    );
  }

  Future<void> _goToCurrentLocation() async {
    final location = await _viewModel.determinePosition();
    if (location != null && mounted) {
      await _moveCamera(location);
    }
  }

  void _saveSelectedLocation() {
    final address = _viewModel.validateAndPrepareAddress(
      existingId: widget.existingAddress?.id,
      rawLocationName: _locationNameController.text,
      isEditing: _isEditing,
    );

    if (address != null) {
      Navigator.of(context).pop(address);
    }
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
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
          _isEditing ? 'Edit Address' : 'Add Address',
          style: AppTextStyle.ppMoriSemiBold(
            textSize: 18,
            textColor: AppColors.black,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _viewModel.centerLatLng,
                        zoom: 14,
                      ),
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      onCameraMove: _viewModel.onCameraMove,
                      onCameraIdle: _viewModel.onCameraIdle,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(
                        Icons.location_pin,
                        color: AppColors.red,
                        size: 48,
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: FloatingActionButton.small(
                        heroTag: 'my_loc',
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.black,
                        onPressed: _goToCurrentLocation,
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                bottom: true,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address',
                        style: AppTextStyle.interRegular(
                          textSize: 13,
                          textColor: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _viewModel.selectedAddress.isNotEmpty
                            ? _viewModel.selectedAddress
                            : 'Move map to select your address',
                        style: AppTextStyle.interSemiBold(
                          textSize: 15,
                          textColor: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Location Name',
                        style: AppTextStyle.interRegular(
                          textSize: 13,
                          textColor: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _locationNameController,
                        onChanged: _viewModel.onLocationNameChanged,
                        style: AppTextStyle.interRegular(
                          textSize: 14,
                          textColor: AppColors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter Location Name (e.g. Home, Office)',
                          hintStyle: AppTextStyle.interRegular(
                            textSize: 14,
                            textColor: AppColors.grey,
                          ),
                          errorText: _viewModel.locationNameError,
                          errorStyle: AppTextStyle.interRegular(
                            textSize: 12,
                            textColor: AppColors.red,
                          ),
                          filled: true,
                          fillColor: AppColors.ultraLightGrey
                              .withValues(alpha: 0.6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.red,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.red,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _saveSelectedLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Text(
                            _isEditing ? 'Update Address' : 'Save Address',
                            style: AppTextStyle.interBold(
                              textSize: 16,
                              textColor: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
