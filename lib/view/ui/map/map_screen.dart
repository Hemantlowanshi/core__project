import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/color/app_color.dart';
import '../../../core/theme/style/theme_style.dart';
import '../../../data/models/address_item.dart';

class MapScreen extends StatefulWidget {
  // Existing address is passed when we are editing an address.
  // If it is null, we are adding a new address.
  final AddressItem? existingAddress;

  const MapScreen({
    super.key,
    this.existingAddress,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controller used to control the Google Map.
  // Example: move the map to current location.
  GoogleMapController? _mapController;

  // Stores the device's current GPS location.
  // This is also used as the default map location.
  LatLng _currentPosition =
  const LatLng(37.4219999, -122.0840575);

  // Stores the location currently under the fixed center pin.
  //
  // IMPORTANT:
  // The red pin does NOT move.
  // The map moves underneath the red pin.
  LatLng _centerLatLng =
  const LatLng(37.4219999, -122.0840575);

  // Stores the readable address obtained from latitude/longitude.
  String _selectedAddress = '';

  // Controls the "Location Name" TextField.
  final TextEditingController _locationNameController =
  TextEditingController();

  // Returns true when we opened MapScreen for editing.
  //
  // existingAddress != null  -> Edit mode
  // existingAddress == null  -> Add mode
  bool get _isEditing => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();

    // Check whether we are editing an existing address.
    if (_isEditing) {
      // Get the address passed from SelectLocationScreen.
      final addr = widget.existingAddress!;

      // Open the map at the saved latitude and longitude.
      _centerLatLng = LatLng(
        addr.latitude,
        addr.longitude,
      );

      // Also keep current position same as saved location.
      _currentPosition = _centerLatLng;

      // Show the saved address.
      _selectedAddress = addr.address;

      // Show the saved location name inside TextField.
      _locationNameController.text = addr.name;
    } else {
      // If this is a new address,
      // get the device's current location.
      _determinePosition();
    }
  }

  @override
  void dispose() {
    // Dispose TextEditingController when screen is removed.
    _locationNameController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------
  // GET CURRENT DEVICE LOCATION
  // ---------------------------------------------------------
  Future<void> _determinePosition() async {
    // Check whether location service/GPS is enabled.
    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    // If GPS is disabled, stop here.
    if (!serviceEnabled) return;

    // Check current location permission.
    LocationPermission permission =
    await Geolocator.checkPermission();

    // If permission is denied, ask the user for permission.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      // If user denies permission, stop.
      if (permission == LocationPermission.denied) return;
    }

    // If permission was permanently denied, stop.
    if (permission == LocationPermission.deniedForever) return;

    try {
      // Get the device's current GPS coordinates.
      final Position position =
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Check whether this widget is still on the screen.
      if (!mounted) return;

      // Convert Position into Google Maps LatLng.
      final currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      // Update our location variables.
      setState(() {
        _currentPosition = currentLocation;

        // The center pin should initially point to
        // the current device location.
        _centerLatLng = currentLocation;

        // Show temporary text while getting the address.
        _selectedAddress = 'Getting address...';
      });

      // If Google Map is already created,
      // move the camera to the current location.
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            currentLocation,
            15,
          ),
        );
      }

      // Convert latitude/longitude into a readable address.
      await _getLocationAddress(currentLocation);
    } catch (e) {
      // Print location error in debug console.
      debugPrint('Location error: $e');
    }
  }

  // ---------------------------------------------------------
  // CONVERT LATITUDE/LONGITUDE INTO ADDRESS
  // ---------------------------------------------------------
  Future<void> _getLocationAddress(
      LatLng position,
      ) async {
    try {
      // Reverse geocoding:
      //
      // Latitude + Longitude
      //          ↓
      //      Readable Address
      //
      final List<Placemark> placemarks =
      await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Make sure the screen still exists.
      if (!mounted) return;

      // If no address was found.
      if (placemarks.isEmpty) {
        setState(() {
          _selectedAddress = 'Address not available';
        });
        return;
      }

      // Get the first matching address.
      final Placemark place = placemarks.first;

      // This list will contain different parts of the address.
      final List<String> addressParts = [];

      // Street / road name.
      if (place.street != null &&
          place.street!.trim().isNotEmpty) {
        addressParts.add(place.street!.trim());
      }

      // Area / locality.
      if (place.subLocality != null &&
          place.subLocality!.trim().isNotEmpty) {
        addressParts.add(place.subLocality!.trim());
      }

      // City.
      if (place.locality != null &&
          place.locality!.trim().isNotEmpty) {
        addressParts.add(place.locality!.trim());
      }

      // State.
      if (place.administrativeArea != null &&
          place.administrativeArea!.trim().isNotEmpty) {
        addressParts.add(
          place.administrativeArea!.trim(),
        );
      }

      // Country.
      if (place.country != null &&
          place.country!.trim().isNotEmpty) {
        addressParts.add(place.country!.trim());
      }

      // Join all address parts with commas.
      //
      // Example:
      // Street, Area, City, State, Country
      final String address = addressParts.join(', ');

      // Update the Address displayed on screen.
      setState(() {
        _selectedAddress = address.isNotEmpty
            ? address
            : 'Address not available';
      });
    } catch (e) {
      // If reverse geocoding fails.
      debugPrint('Reverse geocoding error: $e');

      if (!mounted) return;

      setState(() {
        _selectedAddress = 'Address not available';
      });
    }
  }

  // ---------------------------------------------------------
  // SAVE / UPDATE ADDRESS
  // ---------------------------------------------------------
  void _saveSelectedLocation() {
    // Get the text entered by the user.
    final String locationName =
    _locationNameController.text.trim();

    // If user did not enter a name,
    // use "Saved Location".
    final String finalLocationName =
    locationName.isNotEmpty
        ? locationName
        : 'Saved Location';

    // Create AddressItem object.
    final newAddress = AddressItem(
      // If editing:
      // keep the existing address ID.
      //
      // If adding:
      // create a new unique ID using current time.
      id: _isEditing
          ? widget.existingAddress!.id
          : DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      // Location name entered by the user.
      name: finalLocationName,

      // Address obtained from reverse geocoding.
      address: _selectedAddress.isNotEmpty
          ? _selectedAddress
          : 'Selected Location',

      // Latitude of the location under the center pin.
      latitude: _centerLatLng.latitude,

      // Longitude of the location under the center pin.
      longitude: _centerLatLng.longitude,

      // This address will be selected.
      isSelected: true,
    );

    if (!mounted) return;

    // Close MapScreen and send AddressItem back
    // to SelectLocationScreen.
    Navigator.of(context).pop(newAddress);
  }

  // ---------------------------------------------------------
  // MOVE MAP TO CURRENT LOCATION
  // ---------------------------------------------------------
  Future<void> _goToCurrentLocation() async {
    // First get the latest device location.
    await _determinePosition();

    // If Google Map controller is not ready, stop.
    if (_mapController == null) return;

    // Move Google Map camera to current location.
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        _currentPosition,
        15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      // -----------------------------------------------------
      // APP BAR
      // -----------------------------------------------------
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,

        // Back button.
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
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

        // Change title depending on Add/Edit mode.
        title: Text(
          _isEditing
              ? 'Edit Address'
              : 'Add Address',
          style: AppTextStyle.ppMoriSemiBold(
            textSize: 18,
            textColor: AppColors.black,
          ),
        ),
      ),

      // -----------------------------------------------------
      // BODY
      // -----------------------------------------------------
      body: Column(
        children: [
          // Map takes all available space.
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [

                // -------------------------------------------------
                // GOOGLE MAP
                // -------------------------------------------------
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _centerLatLng,
                    zoom: 14.0,
                  ),

                  // Do not show Google's default blue location dot.
                  myLocationEnabled: false,

                  // Do not show Google's default location button.
                  myLocationButtonEnabled: false,

                  // Hide zoom + / - buttons.
                  zoomControlsEnabled: false,

                  // Hide map toolbar.
                  mapToolbarEnabled: false,

                  // Called continuously while user moves the map.
                  onCameraMove:
                      (CameraPosition position) {

                    // position.target is the location
                    // currently at the center of the map.
                    //
                    // The red pin stays fixed,
                    // so this coordinate is the location
                    // selected by the user.
                    _centerLatLng = position.target;
                  },

                  // Called when the user stops moving the map.
                  onCameraIdle: () {

                    // Convert the center coordinates
                    // into a readable address.
                    _getLocationAddress(
                      _centerLatLng,
                    );
                  },

                  // Called when Google Map is ready.
                  onMapCreated:
                      (GoogleMapController controller) {

                    // Save controller so we can control
                    // the map later.
                    _mapController = controller;
                  },
                ),

                // -------------------------------------------------
                // FIXED RED CENTER PIN
                // -------------------------------------------------
                //
                // IMPORTANT:
                // This is NOT a Google Maps Marker.
                //
                // It is a normal Flutter Icon placed
                // on top of the Google Map.
                //
                // Therefore:
                // - Pin stays fixed.
                // - Map moves underneath it.
                //
                const Padding(
                  padding: EdgeInsets.only(
                    bottom: 40,
                  ),
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 48,
                  ),
                ),

                // -------------------------------------------------
                // CURRENT LOCATION BUTTON
                // -------------------------------------------------
                Positioned(
                  right: 16,
                  top: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'my_loc',

                    backgroundColor:
                    AppColors.white,

                    foregroundColor:
                    AppColors.black,

                    // Move map back to device location.
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

          // -----------------------------------------------------
          // BOTTOM ADDRESS PANEL
          // -----------------------------------------------------
          SafeArea(
            bottom: true,
            child: Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: AppColors.white,

                // Small shadow above bottom panel.
                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  // -------------------------------------------------
                  // ADDRESS LABEL
                  // -------------------------------------------------
                  Text(
                    'Address',
                    style:
                    AppTextStyle.interRegular(
                      textSize: 13,
                      textColor: AppColors.grey,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Actual selected address.
                  Text(
                    _selectedAddress.isNotEmpty
                        ? _selectedAddress
                        : 'Move map to select your address',

                    style:
                    AppTextStyle.interSemiBold(
                      textSize: 15,
                      textColor: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // -------------------------------------------------
                  // LOCATION NAME LABEL
                  // -------------------------------------------------
                  Text(
                    'Location Name',
                    style:
                    AppTextStyle.interRegular(
                      textSize: 13,
                      textColor: AppColors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // -------------------------------------------------
                  // LOCATION NAME TEXT FIELD
                  // -------------------------------------------------
                  TextField(
                    controller:
                    _locationNameController,

                    style:
                    AppTextStyle.interRegular(
                      textSize: 14,
                      textColor: AppColors.black,
                    ),

                    decoration: InputDecoration(
                      hintText:
                      'Enter Location Name',

                      hintStyle:
                      AppTextStyle.interRegular(
                        textSize: 14,
                        textColor: AppColors.grey,
                      ),

                      filled: true,

                      fillColor:
                      AppColors.ultraLightGrey
                          .withOpacity(0.6),

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(14),

                        borderSide:
                        BorderSide.none,
                      ),

                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // -------------------------------------------------
                  // SAVE / UPDATE BUTTON
                  // -------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(
                      // Save new address or update existing address.
                      onPressed:
                      _saveSelectedLocation,

                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF6B4EE6),

                        elevation: 0,

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(26),
                        ),
                      ),

                      // Button text changes according
                      // to Add/Edit mode.
                      child: Text(
                        _isEditing
                            ? 'Update Address'
                            : 'Save Address',

                        style:
                        AppTextStyle.interBold(
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