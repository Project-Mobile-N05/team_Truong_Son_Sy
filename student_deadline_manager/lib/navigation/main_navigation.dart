import 'package:flutter/material.dart';
import '../screens/account_screen.dart';
import '../screens/home_screen.dart';
import '../screens/reminder_screen.dart';

/// Một tab của thanh điều hướng dưới.
class AppTab {
  /// Khóa để chức năng khác (vd: Trang chủ) mở tab này.
  final String key;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;

  const AppTab({
    required this.key,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });
}

/// File dùng chung. CÁCH THÊM MODULE MỚI: chỉ thêm 1 AppTab vào _tabs
/// (đúng thứ tự muốn hiển thị). Trang chủ tự mở được tab đó nhờ `key`.
/// Thứ tự theo wireframe: Trang chủ, Môn học, Lịch, Nhắc nhở, Tài khoản.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<AppTab> _tabs = [
    AppTab(
      key: 'home',
      label: 'Trang chủ',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      screen: HomeScreen(onOpen: _open),
    ),
    // Sơn: AppTab(key: 'subject', ...), AppTab(key: 'stats', ...)
    // Sỹ:  AppTab(key: 'calendar', ...), AppTab(key: 'task', ...)
    const AppTab(
      key: 'reminder',
      label: 'Nhắc nhở',
      icon: Icons.notifications_none,
      selectedIcon: Icons.notifications,
      screen: ReminderScreen(),
    ),
    const AppTab(
      key: 'account',
      label: 'Tài khoản',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      screen: AccountScreen(),
    ),
  ];

  /// Mở tab theo khóa; chưa có tab đó thì báo "đang phát triển".
  void _open(String key) {
    final i = _tabs.indexWhere((t) => t.key == key);
    if (i >= 0) {
      setState(() => _selectedIndex = i);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chức năng này đang được phát triển')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [for (final t in _tabs) t.screen],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE6E0F5),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.label,
            ),
        ],
      ),
    );
  }
}