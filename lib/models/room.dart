import 'package:latlong2/latlong.dart';

enum RoomType { room, miniApartment, dormitory }

class Room {
  final String id;
  final String title;
  final String address;
  final double price;
  final double area;
  final RoomType type;
  final List<String> amenities;
  final String description;
  final String contactNumber;
  final List<String> images;
  final LatLng location;
  bool isFavorite;
  final String hostId;

  Room({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.area,
    required this.type,
    required this.amenities,
    required this.description,
    required this.contactNumber,
    required this.images,
    required this.location,
    this.isFavorite = false,
    required this.hostId,
  });
}
