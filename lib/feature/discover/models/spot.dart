class Spot {
  final String name;
  final String area;
  final String image;
  final String address;
  final double? rating;
  final double? distance;

  Spot({
    required this.name,
    required this.area,
    required this.image,
    required this.address,
    required this.rating,
    required this.distance,
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      name: json['name'],
      area: json['area'],
      image: json['image'],
      address: json['address'],
      rating: (json['rating'] ?? 0).toDouble(),
      distance: (json['distance'] ?? 0).toDouble(),
    );
  }
}
