import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/room_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/room_list_screen.dart';
import 'screens/favorite_rooms_screen.dart';
import 'screens/add_room_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCCKu-Cy__YNh4_gSaUFdmxsphGTPrHSGM",
        authDomain: "phongtro-b3764.firebaseapp.com",
        projectId: "phongtro-b3764",
        storageBucket: "phongtro-b3764.firebasestorage.app",
        messagingSenderId: "542785708443",
        appId: "1:542785708443:web:your_web_app_id", 
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phòng Trọ App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // ĐỔI NỀN APPBAR SANG MÀU XÁM TẠI ĐÂY
        appBarTheme: AppBarTheme(
          // Màu xám nhạt chuyên nghiệp
          backgroundColor: Colors.grey[200], // Màu xám nhạt chuyên nghiệp
          foregroundColor: Colors.black,    // Chữ màu đen để nổi bật trên nền xám
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        scaffoldBackgroundColor: Colors.white, // Nền thân trang vẫn để trắng cho sạch
      ),
      home: const MainNavigation(),
      routes: {
        RoomListScreen.routeName: (ctx) => const RoomListScreen(),
        FavoriteRoomsScreen.routeName: (ctx) => const FavoriteRoomsScreen(),
        AddRoomScreen.routeName: (ctx) => const AddRoomScreen(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RoomListScreen(),
    const FavoriteRoomsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Bản đồ'),
          BottomNavigationBarItem(icon: Icon(Icons.search), activeIcon: Icon(Icons.search_sharp), label: 'Tìm kiếm'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Yêu thích'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}
