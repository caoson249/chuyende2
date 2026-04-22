import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../models/room.dart';
import 'room_detail_screen.dart';

class FavoriteRoomsScreen extends StatelessWidget {
  static const routeName = '/favorites';
  const FavoriteRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    // Ép kiểu tường minh về List<Room> để tránh lỗi Object?
    final List<Room> favoriteRooms = roomProvider.rooms.where((r) => r.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phòng trọ yêu thích', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: favoriteRooms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Bạn chưa lưu phòng trọ nào.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteRooms.length,
              itemBuilder: (ctx, i) {
                final room = favoriteRooms[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        room.images[0],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(Icons.image, size: 80),
                      ),
                    ),
                    title: Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${room.price.toStringAsFixed(0)} VNĐ/tháng', style: const TextStyle(color: Colors.blue)),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        roomProvider.toggleFavorite(room.id);
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => RoomDetailScreen(room: room)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
