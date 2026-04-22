import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../models/room.dart';
import 'room_detail_screen.dart';

class RoomListScreen extends StatefulWidget {
  static const routeName = '/room-list';
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  String _searchQuery = '';
  double? _minPrice;
  double? _maxPrice;
  final List<String> _selectedAmenities = [];

  final List<String> _allAmenities = ['Wifi', 'Điều hòa', 'WC riêng', 'Thang máy', 'Chỗ để xe', 'Tủ lạnh', 'Máy giặt'];

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    
    // Gọi hàm lọc từ Provider
    final filteredRooms = roomProvider.filterRooms(
      query: _searchQuery,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      requiredAmenities: _selectedAmenities,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Tìm kiếm phòng', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Nhập địa chỉ, tên phòng...',
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _showFilterDialog,
                  icon: Icon(Icons.tune, color: (_minPrice != null || _selectedAmenities.isNotEmpty) ? Colors.blue : Colors.grey),
                  style: IconButton.styleFrom(backgroundColor: Colors.grey.shade200, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                )
              ],
            ),
          ),
        ),
      ),
      body: filteredRooms.isEmpty
          ? Center(child: Text('Không tìm thấy phòng phù hợp.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredRooms.length,
              itemBuilder: (ctx, i) {
                final room = filteredRooms[i];
                return _buildRoomCard(context, room);
              },
            ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bộ lọc nâng cao', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _minPrice = null;
                        _maxPrice = null;
                        _selectedAmenities.clear();
                      });
                    },
                    child: const Text('Xóa tất cả'),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Text('Khoảng giá (VNĐ)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  _priceChip(setModalState, 'Dưới 2tr', null, 2000000),
                  _priceChip(setModalState, '2tr - 5tr', 2000000, 5000000),
                  _priceChip(setModalState, 'Trên 5tr', 5000000, null),
                ],
              ),
              const SizedBox(height: 25),
              const Text('Tiện ích', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _allAmenities.map((amenity) {
                  final isSelected = _selectedAmenities.contains(amenity);
                  return FilterChip(
                    label: Text(amenity),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        if (selected) _selectedAmenities.add(amenity);
                        else _selectedAmenities.remove(amenity);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: () {
                    setState(() {}); // Update main UI
                    Navigator.pop(context);
                  },
                  child: const Text('ÁP DỤNG'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceChip(StateSetter setModalState, String label, double? min, double? max) {
    final isSelected = _minPrice == min && _maxPrice == max;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          _minPrice = selected ? min : null;
          _maxPrice = selected ? max : null;
        });
      },
    );
  }

  Widget _buildRoomCard(BuildContext context, Room room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => RoomDetailScreen(room: room))),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(room.images[0], height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (ctx,e,s) => Container(height: 180, color: Colors.grey)),
            ),
            ListTile(
              title: Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(room.address, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Text('${room.price.toStringAsFixed(0)}đ', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
