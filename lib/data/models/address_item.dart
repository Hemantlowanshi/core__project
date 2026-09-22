class AddressItem {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  bool isSelected;

  AddressItem({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isSelected = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'isSelected': isSelected,
      };

  factory AddressItem.fromJson(Map<String, dynamic> json) => AddressItem(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        latitude: json['latitude'] ?? 0.0,
        longitude: json['longitude'] ?? 0.0,
        isSelected: json['isSelected'] ?? false,
      );
}
