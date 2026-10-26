import 'package:flutter/material.dart';
import '../models/account_data.dart';
import '../services/auth_service.dart';
import '../widgets/pastel_tile.dart';
import '../widgets/screen_header.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _auth = AuthService();
  late Future<AccountData> _future;

  @override
  void initState() {
    super.initState();
    _future = _auth.getProfile();
  }

  void _reload() => setState(() => _future = _auth.getProfile());

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _editName(AccountData current) async {
    final ctrl = TextEditingController(text: current.fullName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa họ tên'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Họ và tên'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Lưu')),
        ],
      ),
    );
    ctrl.dispose();
    if (name == null) return;
    try {
      await _auth.updateProfile(name);
      if (!mounted) return;
      _reload();
      _toast('Đã cập nhật họ tên');
    } on AuthException catch (e) {
      if (mounted) _toast(e.message);
    }
  }

  Future<void> _changePassword() async {
    final cur = TextEditingController();
    final next = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cur,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Mật khẩu hiện tại'),
            ),
            TextField(
              controller: next,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Đổi')),
        ],
      ),
    );
    final curText = cur.text, nextText = next.text;
    cur.dispose();
    next.dispose();
    if (ok != true) return;
    try {
      await _auth.changePassword(curText, nextText);
      if (mounted) _toast('Đã đổi mật khẩu');
    } on AuthException catch (e) {
      if (mounted) _toast(e.message);
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.logout();
    } catch (e) {
      if (mounted) _toast('Đăng xuất thất bại: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<AccountData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError || snap.data == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${snap.error ?? 'Không tải được hồ sơ'}'),
                    const SizedBox(height: 12),
                    FilledButton(
                        onPressed: _reload, child: const Text('Thử lại')),
                    TextButton(
                        onPressed: _logout, child: const Text('Đăng xuất')),
                  ],
                ),
              );
            }
            final acc = snap.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                const ScreenHeader('Tài khoản'),
                PastelTile(
                  title: acc.fullName,
                  subtitle: '${acc.email} · MSSV ${acc.studentCode}',
                  color: const Color(0xFFF0E6FF),
                  height: 130,
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                      child: PastelTile(
                        title: 'Trường',
                        subtitle: 'Đại học Phenikaa',
                        color: Color(0xFFFFE0E3),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: PastelTile(
                        title: 'Chuyên ngành',
                        subtitle: 'Công nghệ Thông tin',
                        color: Color(0xFFDDF3FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SoftCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _row(Icons.edit_outlined, 'Sửa họ tên', acc.fullName,
                          () => _editName(acc)),
                      const Divider(height: 1),
                      _row(Icons.lock_outline, 'Đổi mật khẩu',
                          'Cập nhật mật khẩu đăng nhập', _changePassword),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      side: const BorderSide(
                          color: Colors.deepPurple, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Đăng xuất',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(IconData icon, String title, String sub, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
