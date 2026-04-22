import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoadingData = false;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      if (_user?.uid == user?.uid && _userData != null) return;
      _user = user;
      notifyListeners(); 
      if (user != null) {
        await _fetchUserData();
      } else {
        _userData = null;
        _isLoadingData = false;
        notifyListeners();
      }
    });
  }

  bool get isLoggedIn => _user != null;
  bool get isLoadingData => _isLoadingData;
  String? get userId => _user?.uid;
  String? get userName => _userData?['name'];
  String? get userEmail => _user?.email;
  String? get userPhone => _userData?['phone'];
  String? get userBirthday => _userData?['birthday'];

  Future<void> _fetchUserData() async {
    if (_user == null) return;
    _isLoadingData = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userData = doc.data();
      }
    } catch (e) {
      debugPrint("Lỗi lấy dữ liệu người dùng: $e");
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  Future<void> updateUserData({
    required String name,
    required String phone,
    required String birthday,
  }) async {
    if (_user == null) return;
    try {
      final data = {
        'name': name,
        'phone': phone,
        'birthday': birthday,
        'email': _user?.email, // Lưu luôn email cho chắc chắn
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // SỬA TẠI ĐÂY: Dùng set với SetOptions(merge: true) để:
      // - Nếu chưa có document: Nó sẽ TẠO MỚI.
      // - Nếu đã có document: Nó sẽ GHI ĐÈ (cập nhật).
      await _firestore.collection('users').doc(_user!.uid).set(data, SetOptions(merge: true));
      
      // Cập nhật dữ liệu hiển thị trên màn hình ngay lập tức
      if (_userData == null) {
        _userData = data;
      } else {
        _userData?['name'] = name;
        _userData?['phone'] = phone;
        _userData?['birthday'] = birthday;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi cập nhật dữ liệu: $e");
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential res = await _auth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: password.trim()
      );
      _user = res.user;
      notifyListeners(); 
      await _fetchUserData();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String birthday,
    required String password,
  }) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final userData = {
        'name': name,
        'email': email,
        'phone': phone,
        'birthday': birthday,
        'createdAt': DateTime.now(),
      };
      await _firestore.collection('users').doc(res.user!.uid).set(userData);
      _user = res.user;
      _userData = userData;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _userData = null;
    notifyListeners();
  }
}
