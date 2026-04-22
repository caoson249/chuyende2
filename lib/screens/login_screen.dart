import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      if (_isLogin) {
        await auth.login(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        await auth.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          birthday: _birthdayController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      String errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại!';
      if (e.toString().contains('user-not-found')) errorMessage = 'Email này chưa được đăng ký!';
      if (e.toString().contains('wrong-password')) errorMessage = 'Sai mật khẩu!';
      if (e.toString().contains('email-already-in-use')) errorMessage = 'Email này đã được sử dụng!';
      if (e.toString().contains('invalid-email')) errorMessage = 'Email không đúng định dạng!';
      if (e.toString().contains('weak-password')) errorMessage = 'Mật khẩu quá yếu (tối thiểu 6 ký tự)!';
      if (e.toString().contains('requires-recent-login')) errorMessage = 'Vui lòng đăng nhập lại trước khi thực hiện!';
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, foregroundColor: Colors.black),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLogin ? 'Chào mừng trở lại!' : 'Tạo tài khoản mới',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Đăng nhập để tiếp tục' : 'Điền thông tin bên dưới để bắt đầu',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('Họ và tên', Icons.person_outline),
                      validator: (val) => val!.isEmpty ? 'Vui lòng nhập tên' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: _buildInputDecoration('Số điện thoại', Icons.phone_android_outlined),
                      keyboardType: TextInputType.phone,
                      validator: (val) => val!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _birthdayController,
                      decoration: _buildInputDecoration('Ngày sinh (DD/MM/YYYY)', Icons.cake_outlined),
                      validator: (val) => val!.isEmpty ? 'Vui lòng nhập ngày sinh' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _emailController,
                    decoration: _buildInputDecoration('Email', Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => !val!.contains('@') ? 'Email không hợp lệ' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: _buildInputDecoration('Mật khẩu', Icons.lock_outline),
                    obscureText: true,
                    validator: (val) => val!.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_isLogin ? 'ĐĂNG NHẬP' : 'ĐĂNG KÝ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_isLogin ? 'Chưa có tài khoản?' : 'Đã có tài khoản?'),
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: Text(_isLogin ? 'Đăng ký ngay' : 'Đăng nhập'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
