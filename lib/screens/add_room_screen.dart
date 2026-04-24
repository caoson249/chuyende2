import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:http/http.dart' as http;
import '../models/room.dart';
import '../providers/room_provider.dart';
import '../providers/auth_provider.dart';
//sua loi
class AddRoomScreen extends StatefulWidget {
  static const routeName = '/add-room';
  final LatLng? initialLocation;

  const AddRoomScreen({super.key, this.initialLocation});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isLoadingAddress = false;
  bool _isUploading = false;
  XFile? _pickedFile;
  RoomType _selectedType = RoomType.room;
  
  final List<String> _selectedAmenities = [];
  final List<Map<String, dynamic>> _allAmenities = [
    {'name': 'Wifi', 'icon': Icons.wifi},
    {'name': 'Điều hòa', 'icon': Icons.ac_unit},
    {'name': 'WC riêng', 'icon': Icons.wc},
    {'name': 'Thang máy', 'icon': Icons.elevator},
    {'name': 'An ninh', 'icon': Icons.security},
    {'name': 'Chỗ để xe', 'icon': Icons.directions_car},
    {'name': 'Tủ lạnh', 'icon': Icons.kitchen},
    {'name': 'Máy giặt', 'icon': Icons.local_laundry_service},
    {'name': 'Tự do', 'icon': Icons.access_time},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _getAddressFromLatLng();
    }
  }

  Future<void> _getAddressFromLatLng() async {
    if (kIsWeb) return;
    setState(() => _isLoadingAddress = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _addressController.text = '${place.street}, ${place.subAdministrativeArea}, ${place.administrativeArea}';
          _titleController.text = 'Phòng trọ tại ${place.subAdministrativeArea}';
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (pickedFile != null) setState(() => _pickedFile = pickedFile);
  }

  Future<String?> _uploadToImgBB(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      String base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        body: {
          'key': '7169a9de4870830dacb9557d1eda2e1c',
          'image': base64Image,
        },
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        return jsonData['data']['url'];
      } else {
        throw Exception(jsonData['error']['message'] ?? "Lỗi máy chủ ảnh");
      }
    } catch (e) {
      debugPrint("Lỗi upload: $e");
      rethrow;
    }
  }

  void _submitData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập!')));
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ảnh trọ!')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? downloadUrl = await _uploadToImgBB(_pickedFile!);

      if (downloadUrl == null) {
        throw Exception('Không nhận được liên kết ảnh.');
      }

      final newRoom = Room(
        id: '', 
        title: _titleController.text,
        address: _addressController.text,
        price: double.parse(_priceController.text),
        area: double.parse(_areaController.text),
        type: _selectedType,
        amenities: _selectedAmenities,
        description: _descriptionController.text,
        contactNumber: _contactController.text,
        images: [downloadUrl], 
        location: widget.initialLocation ?? LatLng(10.7769, 106.7009),
        hostId: FirebaseAuth.instance.currentUser!.uid,
      );

      await Provider.of<RoomProvider>(context, listen: false).addRoom(newRoom);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng tin thành công!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $msg'), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đăng tin phòng trọ'), 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Nút Hủy: Hỏi user trước khi thoát
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Hủy đăng tin?'),
                content: const Text('Mọi thông tin bạn đã nhập sẽ bị mất. Bạn có chắc chắn muốn thoát?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('TIẾP TỤC ĐĂNG')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    }, 
                    child: const Text('HỦY BỎ', style: TextStyle(color: Colors.red))
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: (_isLoadingAddress || _isUploading)
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 15),
                Text(_isUploading ? 'Đang gửi ảnh lên hệ thống...' : 'Đang lấy địa chỉ...'),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePreview(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Thông tin cơ bản'),
                  TextFormField(controller: _titleController, decoration: _buildInput('Tiêu đề', Icons.edit)),
                  const SizedBox(height: 12),
                  TextFormField(controller: _addressController, decoration: _buildInput('Địa chỉ', Icons.map)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _priceController, decoration: _buildInput('Giá (VNĐ)', Icons.money), keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: TextFormField(controller: _areaController, decoration: _buildInput('Diện tích (m²)', Icons.aspect_ratio), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<RoomType>(
                    value: _selectedType,
                    decoration: _buildInput('Loại phòng', Icons.category),
                    items: RoomType.values.map((type) => DropdownMenuItem(value: type, child: Text(type == RoomType.room ? 'Phòng trọ' : 'Chung cư mini'))).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _contactController, decoration: _buildInput('Số điện thoại', Icons.phone), keyboardType: TextInputType.phone),
                  
                  const SizedBox(height: 25),
                  _buildSectionTitle('Tiện ích'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _allAmenities.map((amenity) {
                      final isSelected = _selectedAmenities.contains(amenity['name']);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) _selectedAmenities.remove(amenity['name']);
                            else _selectedAmenities.add(amenity['name']);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(amenity['icon'], size: 18, color: isSelected ? Colors.white : Colors.grey[600]),
                              const SizedBox(width: 5),
                              Text(amenity['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 25),
                  _buildSectionTitle('Mô tả chi tiết'),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Nhập mô tả về phòng...',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                    ),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('XÁC NHẬN ĐĂNG TIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180, width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue.withOpacity(0.2))),
        child: _pickedFile != null
            ? ClipRRect(borderRadius: BorderRadius.circular(15), child: kIsWeb ? Image.network(_pickedFile!.path, fit: BoxFit.cover) : Image.file(File(_pickedFile!.path), fit: BoxFit.cover))
            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.blue), SizedBox(height: 8), Text('Thêm hình ảnh', style: TextStyle(color: Colors.blue))]),
      ),
    );
  }

  InputDecoration _buildInput(String label, IconData icon) => InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.blue, size: 20), filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)));
}
