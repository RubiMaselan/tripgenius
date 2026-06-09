import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/trip_builder_screen.dart';
import 'screens/saved_trips_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/wishlist_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  final isLoggedIn = await AuthService.isLoggedIn();
  runApp(TripGeniusApp(isLoggedIn: isLoggedIn));
}

class TripGeniusApp extends StatelessWidget {
  final bool isLoggedIn;
  const TripGeniusApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripGenius',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFD4AF37),
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home':  (_) => const MainShell(),
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    TripBuilderScreen(),
    SearchScreen(),
    WishlistScreen(),
    SavedTripsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F1422),
          border: Border(top: BorderSide(color: Color(0xFF1E2540), width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore,
                    label: 'Plan', isActive: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0)),
                _NavItem(icon: Icons.search_outlined, activeIcon: Icons.search,
                    label: 'Search', isActive: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1)),
                _NavItem(icon: Icons.favorite_outline, activeIcon: Icons.favorite,
                    label: 'Wishlist', isActive: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2)),
                _NavItem(icon: Icons.bookmark_outline, activeIcon: Icons.bookmark,
                    label: 'Trips', isActive: _currentIndex == 3,
                    onTap: () => setState(() => _currentIndex = 3)),
                _NavItem(icon: Icons.person_outline, activeIcon: Icons.person,
                    label: 'Profile', isActive: _currentIndex == 4,
                    onTap: () => setState(() => _currentIndex = 4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.activeIcon,
      required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD4AF37).withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFFD4AF37) : const Color(0xFF4A5270),
              size: 22),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 10,
                  color: isActive ? const Color(0xFFD4AF37) : const Color(0xFF4A5270),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }
}