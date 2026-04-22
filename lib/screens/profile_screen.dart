import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Thông tin cá nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (authProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.edit_note, size: 30, color: Colors.blue),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const EditProfileScreen()),
                );
              },
            ),
        ],
      ),
      body: authProvider.isLoadingData 
          ? const Center(child: CircularProgressIndicator()) 
          : authProvider.isLoggedIn
              ? _buildProfileContent(context, authProvider)
              : _buildGuestContent(context),
    );
  }

  Widget _buildProfileContent(BuildContext context, AuthProvider auth) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            width: double.infinity,
            child: Column(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  auth.userName ?? 'Người dùng',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  auth.userEmail ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoSection(context, 'Thông tin chi tiết (Nhấn để sửa)', [
            _buildInfoItem(context, Icons.badge_outlined, 'Họ và tên', auth.userName ?? 'Chưa cập nhật'),
            _buildInfoItem(context, Icons.phone_android_outlined, 'Số điện thoại', auth.userPhone ?? 'Chưa cập nhật'),
            _buildInfoItem(context, Icons.email_outlined, 'Email', auth.userEmail ?? 'Chưa cập nhật', isEmail: true),
            _buildInfoItem(context, Icons.cake_outlined, 'Ngày sinh', auth.userBirthday ?? 'Chưa cập nhật'),
          ]),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => auth.logout(),
                icon: const Icon(Icons.logout),
                label: const Text('ĐĂNG XUẤT', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGuestContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.person_add_alt_1, size: 80, color: Colors.blue),
            ),
            const SizedBox(height: 24),
            const Text('Bạn chưa đăng nhập', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Hãy đăng nhập ngay để lưu tin, xem lại lịch sử và quản lý thông tin cá nhân của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('ĐĂNG NHẬP / ĐĂNG KÝ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> items) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value, {bool isEmail = false}) {
    return InkWell(
      onTap: isEmail ? null : () {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const EditProfileScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: value == 'Chưa cập nhật' ? Colors.orange : Colors.grey.shade600),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  Text(
                    value, 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w500,
                      color: value == 'Chưa cập nhật' ? Colors.orange : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            if (!isEmail) const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
