import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/color/app_color.dart';
import '../../../core/theme/style/theme_style.dart';
import '../../../data/models/address_item.dart';

class MapScreen extends StatefulWidget {
  // Existing address is used for Edit mode.
  // Null means Add mode.
  final AddressItem? existingAddress;

  const MapScreen({
    super.key,
    this.existingAddress,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Google Map controller.
  GoogleMapController? _mapController;

  // Used to delay reverse geocoding.
  Timer? _geocodingTimer;

  // ---------------------------------------------------------
  // FALLBACK LOCATION
  // ---------------------------------------------------------
  //
  // This location is used ONLY as a final fallback when all
  // location methods fail or permissions are denied.
  //
  static const LatLng _defaultLocation = LatLng(
    37.4219999,
    -122.0840575,
  );

  // Device's current location.
  LatLng _currentPosition = _defaultLocation;

  // Location currently under the fixed red pin.
  LatLng _centerLatLng = _defaultLocation;

  // Address displayed on screen.
  String _selectedAddress = '';

  // Controls Location Name TextField.
  final TextEditingController _locationNameController =
      TextEditingController();

  // True when editing an existing address.
  bool get _isEditing => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      // EDIT MODE: Open map using saved address coordinates.
      _loadExistingAddress();
    } else {
      // ADD MODE: Instamart/Swiggy style progressive location detection.
      _determinePosition();
    }
  }

  @override
  void dispose() {
    _geocodingTimer?.cancel();
    _locationNameController.dispose();

    super.dispose();
  }

  // =========================================================
  // LOAD EXISTING ADDRESS
  // =========================================================

  void _loadExistingAddress() {
    final AddressItem address = widget.existingAddress!;

    _centerLatLng = LatLng(
      address.latitude,
      address.longitude,
    );

    _currentPosition = _centerLatLng;

    _selectedAddress = address.address;

    _locationNameController.text = address.name;
  }

  // =========================================================
  // GET CURRENT / NEARBY LOCATION (INSTAMART / SWIGGY STYLE)
  // =========================================================

  Future<void> _determinePosition() async {
    try {
      // -------------------------------------------------------
      // CHECK LOCATION SERVICES & PERMISSIONS
      // -------------------------------------------------------

      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint('Location service is disabled.');
        await _useDefaultLocation();
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied.');
          await _useDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied.');
        await _useDefaultLocation();
        return;
      }

      // -------------------------------------------------------
      // STEP 1: GET NEARBY / LAST-KNOWN LOCATION IMMEDIATELY
      // -------------------------------------------------------

      Position? lastKnownPosition;
      try {
        lastKnownPosition = await Geolocator.getLastKnownPosition();
      } catch (e) {
        debugPrint('Error getting last known position: $e');
      }

      if (lastKnownPosition != null && mounted) {
        final LatLng nearbyLocation = LatLng(
          lastKnownPosition.latitude,
          lastKnownPosition.longitude,
        );

        setState(() {
          _currentPosition = nearbyLocation;
          _centerLatLng = nearbyLocation;
          _selectedAddress = 'Getting address...';
        });

        // Set map instantly to nearby location if map is ready
        if (_mapController != null) {
          _mapController!.moveCamera(
            CameraUpdate.newLatLngZoom(nearbyLocation, 15),
          );
        }

        // Reverse geocode nearby location
        _getLocationAddress(nearbyLocation);
      }

      // -------------------------------------------------------
      // STEP 2: FETCH FRESH ACCURATE GPS LOCATION IN BACKGROUND
      // -------------------------------------------------------

      final Position freshPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final LatLng freshLocation = LatLng(
        freshPosition.latitude,
        freshPosition.longitude,
      );

      setState(() {
        _currentPosition = freshLocation;
        _centerLatLng = freshLocation;
        _selectedAddress = 'Getting address...';
      });

      // Smoothly animate camera to accurate fresh location
      await _moveCamera(freshLocation);

      // Get readable address for accurate position
      await _getLocationAddress(freshLocation);
    } catch (e) {
      debugPrint('Location error: $e');

      // Only fallback to _defaultLocation if both last-known & GPS failed
      if (_centerLatLng == _defaultLocation) {
        await _useDefaultLocation();
      }
    }
  }

  // =========================================================
  // USE DEFAULT LOCATION (FINAL FALLBACK ONLY)
  // =========================================================

  Future<void> _useDefaultLocation() async {
    if (!mounted) return;

    setState(() {
      _currentPosition = _defaultLocation;
      _centerLatLng = _defaultLocation;
      _selectedAddress = 'Getting address...';
    });

    await _moveCamera(_defaultLocation);
    await _getLocationAddress(_defaultLocation);
  }

  // =========================================================
  // MOVE MAP (SMOOTH CAMERA ANIMATION)
  // =========================================================

  Future<void> _moveCamera(LatLng location) async {
    if (_mapController == null) return;

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        location,
        15,
      ),
    );
  }

  // =========================================================
  // GET ADDRESS
  // =========================================================

  Future<void> _getLocationAddress(
    LatLng position,
  ) async {
    try {
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isEmpty) {
        _setAddress('Address not available');
        return;
      }

      final Placemark place = placemarks.first;

      final String address = _buildAddress(place);

      _setAddress(
        address.isNotEmpty
            ? address
            : 'Address not available',
      );
    } catch (e) {
      debugPrint(
        'Reverse geocoding error: $e',
      );

      if (!mounted) return;

      _setAddress('Address not available');
    }
  }

  // =========================================================
  // BUILD ADDRESS
  // =========================================================

  String _buildAddress(Placemark place) {
    final List<String> parts = [];

    _addIfNotEmpty(
      parts,
      place.street,
    );

    _addIfNotEmpty(
      parts,
      place.subLocality,
    );

    _addIfNotEmpty(
      parts,
      place.locality,
    );

    _addIfNotEmpty(
      parts,
      place.administrativeArea,
    );

    _addIfNotEmpty(
      parts,
      place.country,
    );

    return parts.join(', ');
  }

  // =========================================================
  // ADD ADDRESS PART
  // =========================================================

  void _addIfNotEmpty(
    List<String> parts,
    String? value,
  ) {
    if (value != null &&
        value.trim().isNotEmpty) {
      parts.add(value.trim());
    }
  }

  // =========================================================
  // SET ADDRESS
  // =========================================================

  void _setAddress(String address) {
    if (!mounted) return;

    setState(() {
      _selectedAddress = address;
    });
  }

  // =========================================================
  // MAP MOVEMENT
  // =========================================================

  void _onCameraMove(
    CameraPosition position,
  ) {
    _centerLatLng = position.target;

    if (_selectedAddress !=
        'Getting address...') {
      setState(() {
        _selectedAddress =
            'Getting address...';
      });
    }
  }

  // =========================================================
  // MAP STOPPED MOVING
  // =========================================================

  void _onCameraIdle() {
    _geocodingTimer?.cancel();

    _geocodingTimer = Timer(
      const Duration(milliseconds: 300),
      () {
        _getLocationAddress(
          _centerLatLng,
        );
      },
    );
  }

  // =========================================================
  // CURRENT LOCATION BUTTON
  // =========================================================

  Future<void> _goToCurrentLocation() async {
    await _determinePosition();

    if (!mounted) return;

    await _moveCamera(
      _currentPosition,
    );
  }

  // =========================================================
  // SAVE / UPDATE
  // =========================================================

  void _saveSelectedLocation() {
    final String locationName =
        _locationNameController.text.trim();

    final String finalLocationName =
        locationName.isNotEmpty
            ? locationName
            : 'Saved Location';

    final AddressItem address =
        AddressItem(
      id: _isEditing
          ? widget.existingAddress!.id
          : DateTime.now()
              .millisecondsSinceEpoch
              .toString(),

      name: finalLocationName,

      address: _selectedAddress.isNotEmpty
          ? _selectedAddress
          : 'Selected Location',

      latitude:
          _centerLatLng.latitude,

      longitude:
          _centerLatLng.longitude,

      isSelected: true,
    );

    Navigator.of(context).pop(address);
  }

  // =========================================================
  // BUILD UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,

        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor:
                AppColors.ultraLightGrey,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.black,
                size: 16,
              ),
              onPressed: () =>
                  Navigator.pop(context),
            ),
          ),
        ),

        title: Text(
          _isEditing
              ? 'Edit Address'
              : 'Add Address',
          style:
              AppTextStyle.ppMoriSemiBold(
            textSize: 18,
            textColor:
                AppColors.black,
          ),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // =================================================
                // GOOGLE MAP
                // =================================================

                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(
                    target: _centerLatLng,
                    zoom: 14,
                  ),

                  myLocationEnabled: false,

                  myLocationButtonEnabled: false,

                  zoomControlsEnabled: false,

                  mapToolbarEnabled: false,

                  onCameraMove:
                      _onCameraMove,

                  onCameraIdle:
                      _onCameraIdle,

                  onMapCreated:
                      (
                    GoogleMapController
                        controller,
                  ) {
                    _mapController =
                        controller;

                    // If a location was already resolved (e.g. last-known),
                    // move map to it immediately without jumping to default location.
                    if (!_isEditing && _currentPosition != _defaultLocation) {
                      _mapController!.moveCamera(
                        CameraUpdate.newLatLngZoom(_currentPosition, 15),
                      );
                    }
                  },
                ),

                // =================================================
                // FIXED RED CENTER PIN
                // =================================================

                const Padding(
                  padding:
                      EdgeInsets.only(
                    bottom: 40,
                  ),
                  child: Icon(
                    Icons.location_pin,
                    color: AppColors.red,
                    size: 48,
                  ),
                ),

                // =================================================
                // CURRENT LOCATION BUTTON
                // =================================================

                Positioned(
                  right: 16,
                  top: 16,
                  child:
                      FloatingActionButton
                          .small(
                    heroTag: 'my_loc',
                    backgroundColor:
                        AppColors.white,
                    foregroundColor:
                        AppColors.black,
                    onPressed:
                        _goToCurrentLocation,
                    child: const Icon(
                      Icons.my_location,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =====================================================
          // BOTTOM ADDRESS PANEL
          // =====================================================

          SafeArea(
            bottom: true,
            child: Container(
              padding:
                  const EdgeInsets.all(20),
              decoration:
                  BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black
                        .withValues(
                      alpha: 0.05,
                    ),
                    blurRadius: 10,
                    offset:
                        const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // ADDRESS
                  // =================================================

                  Text(
                    'Address',
                    style:
                        AppTextStyle
                            .interRegular(
                      textSize: 13,
                      textColor:
                          AppColors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  _selectedAddress ==
                          'Getting address...'
                      ? Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 2,
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color: AppColors
                                      .primaryPurple,
                                ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Text(
                                'Getting address...',
                                style:
                                    AppTextStyle
                                        .interMedium(
                                  textSize: 15,
                                  textColor:
                                      AppColors
                                          .grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          _selectedAddress
                                  .isNotEmpty
                              ? _selectedAddress
                              : 'Move map to select your address',
                          style:
                              AppTextStyle
                                  .interSemiBold(
                            textSize: 15,
                            textColor:
                                AppColors
                                    .black,
                          ),
                        ),

                  const SizedBox(
                    height: 16,
                  ),

                  // =================================================
                  // LOCATION NAME
                  // =================================================

                  Text(
                    'Location Name',
                    style:
                        AppTextStyle
                            .interRegular(
                      textSize: 13,
                      textColor:
                          AppColors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                        _locationNameController,
                    style:
                        AppTextStyle
                            .interRegular(
                      textSize: 14,
                      textColor:
                          AppColors.black,
                    ),
                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter Location Name',
                      hintStyle:
                          AppTextStyle
                              .interRegular(
                        textSize: 14,
                        textColor:
                            AppColors.grey,
                      ),
                      filled: true,
                      fillColor: AppColors
                          .ultraLightGrey
                          .withValues(
                        alpha: 0.6,
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // =================================================
                  // SAVE / UPDATE BUTTON
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child:
                        ElevatedButton(
                      onPressed:
                          _saveSelectedLocation,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            AppColors
                                .primaryPurple,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                26,
                              ),
                        ),
                      ),
                      child: Text(
                        _isEditing
                            ? 'Update Address'
                            : 'Save Address',
                        style:
                            AppTextStyle
                                .interBold(
                          textSize: 16,
                          textColor:
                              AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
