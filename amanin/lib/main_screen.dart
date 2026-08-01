import 'package:flutter/material.dart';
import 'beranda.dart';
import 'cuaca.dart';
import 'edukasi.dart';
import 'utils/localization.dart';
import 'fitur.dart';
import 'ui/analisis_gempa_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _hideBottomNavigation = false;

  final GlobalKey _bottomNavKey = GlobalKey();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BerandaPage(
        bottomNavKey: _bottomNavKey,
        onNavigateToCuaca: () {
          _onItemTapped(1);
        },
      ),
      CuacaPage(
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      const Scaffold(
        body: Center(child: Text('Map Placeholder')),
      ), // Index 2 is the floating map button
      AnalisisGempaPage(
        onFullscreenChanged: (isFullscreen) {
          if (!mounted) return;

          setState(() {
            _hideBottomNavigation = isFullscreen;
          });
        },
      ),
      const EdukasiPage(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FiturPage()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: !_hideBottomNavigation,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _hideBottomNavigation
          ? null
          : _buildFloatingBottomNavigationBar(),
    );
  }

  Widget _buildFloatingBottomNavigationBar() {
    return Container(
      key: _bottomNavKey,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                Icons.home_rounded,
                Localization.of(context).get('nav_home'),
                0,
              ),
              _buildNavItem(
                Icons.cloud_outlined,
                Localization.of(context).get('nav_weather'),
                1,
              ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: InkWell(
                  onTap: () => _onItemTapped(2),
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0088CC),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0088CC).withValues(alpha: 0.35),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.sensors_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              _buildNavItem(
                Icons.public,
                Localization.of(context).get('nav_quake'),
                3,
              ),
              _buildNavItem(
                Icons.menu_book_rounded,
                Localization.of(context).get('nav_education'),
                4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _selectedIndex == index;

    // Choose specific icon based on active state if necessary
    IconData displayIcon = icon;
    if (index == 0) {
      displayIcon = isActive ? Icons.home_rounded : Icons.home_rounded;
    }
    if (index == 1) {
      displayIcon = isActive ? Icons.cloud_outlined : Icons.cloud_outlined;
    }

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              displayIcon,
              color: isActive
                  ? const Color(0xFF00BCD4)
                  : const Color(0xFFBDBDBD),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF00BCD4)
                    : const Color(0xFFBDBDBD),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
