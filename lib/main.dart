import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/translator_screen.dart';
import 'screens/more_screen.dart';
import 'screens/ai_medical_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Firebase 앱이 이미 초기화되어 있는지 확인
    if (Firebase.apps.isEmpty) {
      await dotenv.load(fileName: ".env");
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
          appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
          messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
          projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
          storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
        ),
      );
      print('Firebase 초기화 성공!');
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '병원 관리 앱',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreenWithHome(),
    );
  }
}

class MainScreenWithHome extends StatelessWidget {
  const MainScreenWithHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScreen(
      key: UniqueKey(), // 항상 새로 생성되도록
      initialIndex: 0,  // HomeScreen으로 이동
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const TranslatorScreen(),
    const MoreScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) { // More 화면
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final isLoggedIn = snapshot.hasData;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.home, 'Home', 0),
                    _buildNavItem(Icons.translate, 'Translator', 1),
                    _buildNavItem(
                      Icons.more_horiz,
                      'More',
                      2,
                      disabled: !isLoggedIn,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {bool disabled = false}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (disabled && index == 2) {
          // 비로그인 상태에서 More 버튼 클릭 시 로그인 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else if (!disabled) {
          _onItemTapped(index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: disabled ? Colors.grey.shade300 : (isSelected ? Colors.black : Colors.grey),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: disabled ? Colors.grey.shade300 : (isSelected ? Colors.black : Colors.grey),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
