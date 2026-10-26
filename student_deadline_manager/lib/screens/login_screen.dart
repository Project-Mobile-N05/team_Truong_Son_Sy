import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  bool _isRegister = false;
  bool _loading = false;
  bool _hidePass = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isRegister) {
        await _auth.register(
          studentCode: _codeCtrl.text,
          fullName: _nameCtrl.text,
          email: _emailCtrl.text,
          password: _passCtrl.text,
        );
      } else {
        await _auth.login(_emailCtrl.text, _passCtrl.text);
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Có lỗi không xác định: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.assignment_turned_in,
                      size: 64, color: Colors.deepPurple),
                  const SizedBox(height: 8),
                  Text(
                    _isRegister ? 'Đăng ký tài khoản' : 'Đăng nhập',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 24),
                  if (_isRegister) ...[
                    TextFormField(
                      controller: _codeCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Mã sinh viên',
                          border: OutlineInputBorder()),
                      validator: (v) =>
                          AuthService.validateRequired(v, 'mã sinh viên'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          border: OutlineInputBorder()),
                      validator: (v) =>
                          AuthService.validateRequired(v, 'họ tên'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                    validator: AuthService.validateEmail,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _hidePass,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _hidePass ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                        icon: Icon(_hidePass
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => _hidePass = !_hidePass),
                      ),
                    ),
                    validator: _isRegister
                        ? AuthService.validatePassword
                        : (v) => (v == null || v.isEmpty)
                            ? 'Vui lòng nhập mật khẩu'
                            : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isRegister ? 'Đăng ký' : 'Đăng nhập'),
                    ),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() {
                              _isRegister = !_isRegister;
                              _error = null;
                            }),
                    child: Text(_isRegister
                        ? 'Đã có tài khoản? Đăng nhập'
                        : 'Chưa có tài khoản? Đăng ký'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
