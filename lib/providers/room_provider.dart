import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/room.dart';

class RoomProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Room> _rooms = [];
  bool _isLoading = false;

  List<Room> get rooms => [..._rooms];
  bool get isLoading => _isLoading;

  List<Room> get favoriteRooms => _rooms.where((room) => room.isFavorite).toList();

  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('rooms').orderBy('createdAt', descending: true).get();
      _rooms = snapshot.docs.map((doc) {
        final data = doc.data();
        return Room(
          id: doc.id,
          title: data['title'] ?? "",
          address: data['address'] ?? "",
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          area: (data['area'] as num?)?.toDouble() ?? 0.0,
          type: RoomType.values.firstWhere((e) => e.toString() == data['type'], orElse: () => RoomType.room),
          amenities: List<String>.from(data['amenities'] ?? []),
          description: data['description'] ?? "",
          contactNumber: data['contactNumber'] ?? "",
          images: List<String>.from(data['images'] ?? []),
          location: LatLng(data['lat'] ?? 0, data['lng'] ?? 0),
          hostId: data['hostId'] ?? "",
        );
      }).toList();
    } catch (e) {
      debugPrint("Lỗi tải danh sách phòng: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // HÀM LỌC NÂNG CAO
  List<Room> filterRooms({
    String query = '',
    double? minPrice,
    double? maxPrice,
    List<String> requiredAmenities = const [],
  }) {
    return _rooms.where((room) {
      final matchesQuery = room.title.toLowerCase().contains(query.toLowerCase()) ||
          room.address.toLowerCase().contains(query.toLowerCase());
      
      final matchesPrice = (minPrice == null || room.price >= minPrice) &&
          (maxPrice == null || room.price <= maxPrice);
      
      final matchesAmenities = requiredAmenities.every((amenity) => room.amenities.contains(amenity));

      return matchesQuery && matchesPrice && matchesAmenities;
    }).toList();
  }

  Future<void> addRoom(Room room) async {
    try {
      await _firestore.collection('rooms').add({
        'title': room.title,
        'address': room.address,
        'price': room.price,
        'area': room.area,
        'type': room.type.toString(),
        'amenities': room.amenities,
        'description': room.description,
        'contactNumber': room.contactNumber,
        'images': room.images,
        'lat': room.location.latitude,
        'lng': room.location.longitude,
        'hostId': room.hostId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchRooms();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRoom(String roomId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        ...updatedData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await fetchRooms();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      await _firestore.collection('rooms').doc(roomId).delete();
      _rooms.removeWhere((r) => r.id == roomId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void toggleFavorite(String roomId) {
    final index = _rooms.indexWhere((room) => room.id == roomId);
    if (index >= 0) {
      _rooms[index].isFavorite = !_rooms[index].isFavorite;
      notifyListeners();
    }
  }

  List<Room> getMyRooms(String userId) {
    return _rooms.where((room) => room.hostId == userId).toList();
  }
  
  List<Room> searchRooms(String query) {
    if (query.isEmpty) return _rooms;
    return _rooms.where((room) =>
      room.title.toLowerCase().contains(query.toLowerCase()) ||
      room.address.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
