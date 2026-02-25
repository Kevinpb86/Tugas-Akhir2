import 'package:flutter/material.dart';
import 'beranda.dart';
import 'cuaca.dart';
import 'gempa.dart';
import 'edukasi.dart';
import 'utils/localization.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const BerandaPage(),
      CuacaPage(onBack: () {
        setState(() {
          _selectedIndex = 0;
        });
      }),
      const Scaffold(body: Center(child: Text('Map Placeholder'))), // Index 2 is the floating map button
      const GempaPage(),
      const EdukasiPage(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Map button tapped - perhaps do nothing or show map modal/page
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildFloatingBottomNavigationBar(),
    );
  }

  Widget _buildFloatingBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              _buildNavItem(Icons.home_rounded, Localization.of(context).get('nav_home'), 0),
              _buildNavItem(Icons.cloud_outlined, Localization.of(context).get('nav_weather'), 1),
              Transform.translate(
                offset: const Offset(0, -16),
                child: InkWell(
                  onTap: () => _onItemTapped(2),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0088CC),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0088CC).withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.location_on, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
              _buildNavItem(Icons.public, Localization.of(context).get('nav_quake'), 3),
              _buildNavItem(Icons.school_outlined, Localization.of(context).get('nav_education'), 4),
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
    if (index == 0) displayIcon = isActive ? Icons.home_rounded : Icons.home_rounded; 
    if (index == 1) displayIcon = isActive ? Icons.cloud_outlined : Icons.cloud_outlined;
    
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
              color: isActive ? const Color(0xFF00BCD4) : const Color(0xFFBDBDBD),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFF00BCD4) : const Color(0xFFBDBDBD),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
