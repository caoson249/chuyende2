import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room.dart';
import '../providers/room_provider.dart';

class RoomDetailScreen extends StatelessWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  void _confirmDelete(BuildContext context, RoomProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa?'),
        content: const Text('Bạn có chắc chắn muốn xóa phòng trọ này khỏi bản đồ không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HỦY')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await provider.deleteRoom(room.id);
              if (context.mounted) {
                Navigator.pop(ctx); // Đóng dialog
                Navigator.pop(context); // Quay lại bản đồ
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa phòng trọ thành công!')),
                );
              }
            },
            child: const Text('XÓA VĨNH VIỄN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final isFavorite = roomProvider.rooms.any((r) => r.id == room.id && r.isFavorite);
    
    // Kiểm tra xem người dùng hiện tại có phải là chủ phòng không
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser != null && currentUser.uid == room.hostId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết phòng trọ'),
        actions: [
          // Nếu là chủ phòng, hiện nút Xóa
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () => _confirmDelete(context, roomProvider),
            ),
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? Colors.red : Colors.white,
            onPressed: () {
              roomProvider.toggleFavorite(room.id);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              room.images[0],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (ctx,e,s) => Container(height: 250, color: Colors.grey, child: const Icon(Icons.image_not_supported, size: 50)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${room.price.toStringAsFixed(0)} VNĐ/tháng',
                    style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: const Text('Địa chỉ'),
                    subtitle: Text(room.address),
                  ),
                  ListTile(
                    leading: const Icon(Icons.aspect_ratio, color: Colors.blue),
                    title: const Text('Diện tích'),
                    subtitle: Text('${room.area} m²'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.orange),
                    title: const Text('Loại phòng'),
                    subtitle: Text(room.type == RoomType.room ? 'Phòng trọ' : 'Chung cư mini'),
                  ),
                  const Divider(),
                  const Text(
                    'Tiện nghi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (room.amenities.isEmpty)
                    const Text('Không có thông tin tiện ích', style: TextStyle(color: Colors.grey)),
                  Wrap(
                    spacing: 8,
                    children: room.amenities.map((amenity) => Chip(
                      label: Text(amenity),
                      backgroundColor: Colors.blue.shade50,
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mô tả',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(room.description.isEmpty ? 'Không có mô tả' : room.description),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(room.contactNumber),
                      icon: const Icon(Icons.phone),
                      label: const Text('GỌI CHỦ TRỌ NGAY', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
