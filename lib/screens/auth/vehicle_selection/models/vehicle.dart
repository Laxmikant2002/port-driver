class Vehicle {
  final String id;
  final String name;
  final String imageAsset;
  final int minPrice;
  final int maxPrice;
  final int capacity;
  final String dimensions;
  final bool isAvailable;

  const Vehicle({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.minPrice,
    required this.maxPrice,
    required this.capacity,
    required this.dimensions,
    this.isAvailable = true,
  });

  String get priceRange => '₹$minPrice - ₹$maxPrice';
  String get capacityText => '$capacity kg';
}