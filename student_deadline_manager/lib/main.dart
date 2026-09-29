import 'package:flutter/material.dart';

class AccountManager {
  String username = "sinhvien_phenikaa";
  String email = "241077xx@st.phenikaa-uni.edu.vn";
  String role = "Sinh viên";

  void setAccountInfo(String username, String email, String role) {
    this.username = username;
    this.email = email;
    this.role = role;
  }

  String getAccountInfo() {
    return "Tài khoản: $username ($email) - $role";
  }
}

class ReminderManager {
  String title = "Nộp Bài tập thực hành Flutter";
  String dueDate = "16/09/2026";
  String status = "Đang thực hiện";

  void setReminder(String title, String dueDate, String status) {
    this.title = title;
    this.dueDate = dueDate;
    this.status = status;
  }

  String getReminderInfo() {
    return "Nhắc nhở: $title - Hạn: $dueDate [$status]";
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Bài Tập',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final AccountManager accountManager = AccountManager();
  final ReminderManager reminderManager = ReminderManager();

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      AccountScreen(accountManager: accountManager),
      ReminderScreen(reminderManager: reminderManager),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Nhắc nhở',
          ),
        ],
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  final AccountManager accountManager;

  const AccountScreen({super.key, required this.accountManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Gọi StatelessWidget tự định nghĩa cho Câu 4
            AccountHeaderCard(
              username: accountManager.username,
              email: accountManager.email,
              role: accountManager.role,
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.school_outlined, color: Colors.deepPurple),
                    title: Text('Trường'),
                    subtitle: Text('Đại học Phenikaa'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.work_outline, color: Colors.deepPurple),
                    title: Text('Chuyên ngành'),
                    subtitle: Text('Công nghệ Thông tin'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.lock_outline, color: Colors.deepPurple),
                    title: Text('Đổi mật khẩu'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountHeaderCard extends StatelessWidget {
  final String username;
  final String email;
  final String role;

  const AccountHeaderCard({
    super.key,
    required this.username,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Text(
              'SV',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            username,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderScreen extends StatelessWidget {
  final ReminderManager reminderManager;

  const ReminderScreen({super.key, required this.reminderManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nhắc nhở', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.notifications_active, color: Colors.deepPurple),
                  SizedBox(width: 10),
                  Text(
                    '1 nhắc nhở đang bật',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nhắc nhở của bạn',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.assignment, color: Colors.deepPurple),
                title: Text(
                  reminderManager.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Hạn: ${reminderManager.dueDate}\nTrạng thái: ${reminderManager.status}'),
                isThreeLine: true,
                trailing: Switch(
                  value: true,
                  onChanged: (val) {},
                  activeColor: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}