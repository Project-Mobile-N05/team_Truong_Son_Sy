import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';
import '../screens/account_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/home_screen.dart';
import '../screens/reminder_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/subject_screen.dart';
import '../screens/task_form_screen.dart';
import '../services/subject_options.dart';
import '../services/subject_service.dart';
import '../services/notification_scheduler.dart';

/// Một tab của thanh điều hướng dưới.
class AppTab {
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

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final Set<int> _visitedTabs = {0};
  final NotificationScheduler _scheduler = NotificationScheduler();

  @override
  void initState() {
    super.initState();
    _scheduler.start(); // quét mỗi 1 giờ, gửi mỗi 5 phút khi đã đăng nhập
  }

  @override
  void dispose() {
    _scheduler.stop();
    super.dispose();
  }

  late final List<AppTab> _tabs = [
    AppTab(
      key: 'home',
      label: 'Trang chủ',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      screen: HomeScreen(onOpen: _open),
    ),
    const AppTab(
      key: 'subject',
      label: 'Môn học',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      screen: SubjectScreen(),
    ),
    const AppTab(
      key: 'calendar',
      label: 'Lịch',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      screen: CalendarScreen(),
    ),
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

  late final Map<String, Future<void> Function()> _pushes = {
    'stats': _openStatistics,
    'task': _openTaskForm,
  };

  void _open(String key) {
    final i = _tabs.indexWhere((t) => t.key == key);
    if (i >= 0) {
      _selectTab(i);
      return;
    }
    final push = _pushes[key];
    if (push != null) {
      push();
    } else {
      _toast('Chức năng này đang được phát triển');
    }
  }

  void _selectTab(int index) {
    if (index == _selectedIndex && _visitedTabs.contains(index)) return;
    setState(() {
      _visitedTabs.add(index);
      _selectedIndex = index;
    });
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _openStatistics() async {
    try {
      final list = await SubjectService().layDanhSach();
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => StatisticsScreen(danhSachMonHoc: list),
      ));
    } catch (e) {
      if (mounted) _toast('Không tải được môn học: $e');
    }
  }

  Future<void> _openTaskForm() async {
    final controller = TaskController(subjectLoader: loadSubjectOptions);
    await controller.load();
    if (!mounted) {
      controller.dispose();
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TaskFormScreen(
        controller: controller,
        initialDate: DateTime.now(),
      ),
    ));
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          for (var i = 0; i < _tabs.length; i++)
            _visitedTabs.contains(i)
                ? _tabs[i].screen
                : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
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
