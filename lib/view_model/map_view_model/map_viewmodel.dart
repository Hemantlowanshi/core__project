import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/address_item.dart';

class MapViewModel extends ChangeNotifier {
  static const LatLng defaultLocation = LatLng(
    37.4219999,
    -122.0840575,
  );

  LatLng currentPosition = defaultLocation;
  LatLng centerLatLng = defaultLocation;
  String selectedAddress = '';
  bool isLoadingAddress = false;
  String? locationNameError;

  Timer? _geocodingTimer;

  // Regex for Location Name validation:
  // - Must start with alphanumeric character
  // - Can contain letters, numbers, spaces, hyphens, commas, dots, #
  // - Length: 2 to 50 characters
  static final RegExp locationNameRegex =
      RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9\s\-,.#]{1,49}$');

  // =========================================================
  // LOCATION NAME VALIDATION
  // =========================================================

  String? validateLocationName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Location name is required';
    }

    final trimmed = name.trim();

    if (trimmed.length < 2) {
      return 'Location name must be at least 2 characters';
    }

    if (trimmed.length > 50) {
      return 'Location name cannot exceed 50 characters';
    }

    if (!locationNameRegex.hasMatch(trimmed)) {
      return 'Only letters, numbers, spaces & standard symbols (- , . #) allowed';
    }

    return null; // Valid
  }

  void onLocationNameChanged(String name) {
    // Only update error if user has already attempted validation or typed
    if (locationNameError != null) {
      locationNameError = validateLocationName(name);
      notifyListeners();
    }
  }

  // =========================================================
  // LOAD EXISTING ADDRESS
  // =========================================================

  void loadExistingAddress(AddressItem address) {
    centerLatLng = LatLng(
      address.latitude,
      address.longitude,
    );
    currentPosition = centerLatLng;
    selectedAddress = address.address;
    notifyListeners();
  }

  // =========================================================
  // GET CURRENT LOCATION
  // =========================================================

  Future<LatLng?> determinePosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final LatLng location = LatLng(
        position.latitude,
        position.longitude,
      );

      currentPosition = location;
      centerLatLng = location;
      selectedAddress = 'Getting address...';
      isLoadingAddress = true;
      notifyListeners();

      await getLocationAddress(location);
      return location;
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  // =========================================================
  // GET ADDRESS FROM COORDINATES
  // =========================================================

  Future<void> getLocationAddress(LatLng position) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        setAddress('Address not available');
        return;
      }

      final Placemark place = placemarks.first;
      final String address = _buildAddress(place);
      setAddress(address.isNotEmpty ? address : 'Address not available');
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
      setAddress('Address not available');
    }
  }

  String _buildAddress(Placemark place) {
    final List<String> parts = [];
    _addIfNotEmpty(parts, place.street);
    _addIfNotEmpty(parts, place.subLocality);
    _addIfNotEmpty(parts, place.locality);
    _addIfNotEmpty(parts, place.administrativeArea);
    _addIfNotEmpty(parts, place.country);
    return parts.join(', ');
  }

  void _addIfNotEmpty(List<String> parts, String? value) {
    if (value != null && value.trim().isNotEmpty) {
      parts.add(value.trim());
    }
  }

  void setAddress(String address) {
    selectedAddress = address;
    isLoadingAddress = false;
    notifyListeners();
  }

  // =========================================================
  // MAP CAMERA MOVEMENT
  // =========================================================

  void onCameraMove(CameraPosition position) {
    centerLatLng = position.target;
  }

  void onCameraIdle() {
    _geocodingTimer?.cancel();
    _geocodingTimer = Timer(
      const Duration(milliseconds: 300),
      () {
        getLocationAddress(centerLatLng);
      },
    );
  }

  // =========================================================
  // PREPARE & VALIDATE ADDRESS ITEM FOR SAVING
  // =========================================================

  AddressItem? validateAndPrepareAddress({
    required String? existingId,
    required String rawLocationName,
    required bool isEditing,
  }) {
    final error = validateLocationName(rawLocationName);
    locationNameError = error;
    notifyListeners();

    if (error != null) {
      return null; // Validation failed
    }

    return AddressItem(
      id: isEditing && existingId != null
          ? existingId
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: rawLocationName.trim(),
      address: selectedAddress.isNotEmpty
          ? selectedAddress
          : 'Selected Location',
      latitude: centerLatLng.latitude,
      longitude: centerLatLng.longitude,
      isSelected: true,
    );
  }

  @override
  void dispose() {
    _geocodingTimer?.cancel();
    super.dispose();
  }
}
