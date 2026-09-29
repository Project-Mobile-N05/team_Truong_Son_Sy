import 'package:flutter/material.dart';
import 'account_screen.dart';
import 'reminder_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    AccountScreen(),     // Index 0: Tab Tài khoản
    ReminderScreen(),    // Index 1: Tab Nhắc nhở
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Nhắc nhở'),
        ],
      ),
    );
  }
}