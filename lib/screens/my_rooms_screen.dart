import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../providers/auth_provider.dart';
import '../models/room.dart';
import 'room_detail_screen.dart';
import 'edit_room_screen.dart';

class MyRoomsScreen extends StatelessWidget {
  static const routeName = '/my-rooms';
  const MyRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    
    // SỬA TẠI ĐÂY: Lấy phòng theo userId (UID) thay vì email
    final myRooms = roomProvider.getMyRooms(authProvider.userId ?? "");

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Phòng trọ của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: myRooms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Bạn chưa đăng phòng trọ nào.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Hãy ra bản đồ và đăng tin ngay!', style: TextStyle(color: Colors.blue)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myRooms.length,
              itemBuilder: (ctx, i) {
                final room = myRooms[i];
                return _buildMyRoomCard(context, room, roomProvider);
              },
            ),
    );
  }

  Widget _buildMyRoomCard(BuildContext context, Room room, RoomProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                room.images[0],
                width: 70, height: 70, fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.image, size: 70),
              ),
            ),
            title: Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${room.price.toStringAsFixed(0)} VNĐ - ${room.address}', maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => RoomDetailScreen(room: room)));
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => EditRoomScreen(room: room)));
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Sửa'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, room, provider),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Room room, RoomProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa?'),
        content: Text('Bạn có chắc chắn muốn xóa bài đăng "${room.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HỦY')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await provider.deleteRoom(room.id);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa bài đăng!')));
              }
            },
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
  }
}
