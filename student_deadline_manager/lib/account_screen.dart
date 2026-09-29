import 'package:flutter/material.dart';
import 'account_manager.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  final AccountManager accountManager = AccountManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AccountProfileCard(
              username: accountManager.username,
              email: accountManager.email,
              role: accountManager.role,
            ),
            const SizedBox(height: 30),
            
            _buildSettingItem(Icons.school_outlined, 'Trường', 'Đại học Phenikaa'),
            _buildSettingItem(Icons.work_outline, 'Chuyên ngành', 'Công nghệ Thông tin'),
            const Divider(),
            _buildSettingItem(Icons.lock_outline, 'Đổi mật khẩu', 'Cập nhật mật khẩu đăng nhập'),
            _buildSettingItem(Icons.notifications_none, 'Thông báo', 'Nhắc hẹn nộp bài và lịch học'),
            const Divider(),
            _buildSettingItem(Icons.logout, 'Đăng xuất', '', isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.deepPurple),
      title: Text(
        title, 
        style: TextStyle(fontWeight: FontWeight.bold, color: isDestructive ? Colors.red : Colors.black)
      ),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: isDestructive ? null : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}

class AccountProfileCard extends StatelessWidget {
  final String username;
  final String email;
  final String role;

  const AccountProfileCard({
    super.key, required this.username, required this.email, required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text("SV", style: TextStyle(fontSize: 24, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Text(username, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(role, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          )
        ],
      ),
    );
  }
}