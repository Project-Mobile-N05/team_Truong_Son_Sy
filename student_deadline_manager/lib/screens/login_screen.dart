import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/app_loading_screen.dart';

const _purple = Color(0xFF5B43C2);
const _ink = Color(0xFF211B36);
const _muted = Color(0xFF777286);
const _field = Color(0xFFF8F7FB);

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
    if (_loading || !_formKey.currentState!.validate()) return;
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _loading
          ? AppLoadingScreen(
              key: const ValueKey('login-loading'),
              message: _isRegister
                  ? 'Đang tạo và thiết lập tài khoản…'
                  : 'Đang xác thực tài khoản…',
            )
          : _loginForm(key: const ValueKey('login-form')),
    );
  }

  Widget _loginForm({required Key key}) {
    return Scaffold(
      key: key,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 30, 28, 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: const Color(0xFFEAE7F2)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x120F0A24),
                        blurRadius: 34,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1EDFF),
                                borderRadius: BorderRadius.circular(21),
                              ),
                              child: const Icon(
                                Icons.event_available_rounded,
                                size: 36,
                                color: _purple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isRegister ? 'Tạo tài khoản' : 'Chào mừng trở lại',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            _isRegister
                                ? 'Bắt đầu quản lý môn học và deadline của bạn'
                                : 'Đăng nhập để tiếp tục quản lý deadline',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 26),
                          if (_isRegister) ...[
                            TextFormField(
                              controller: _codeCtrl,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.username],
                              decoration: _decoration(
                                label: 'Mã sinh viên',
                                icon: Icons.badge_outlined,
                              ),
                              validator: (v) => AuthService.validateRequired(
                                v,
                                'mã sinh viên',
                              ),
                            ),
                            const SizedBox(height: 13),
                            TextFormField(
                              controller: _nameCtrl,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                              decoration: _decoration(
                                label: 'Họ và tên',
                                icon: Icons.person_outline,
                              ),
                              validator: (v) =>
                                  AuthService.validateRequired(v, 'họ tên'),
                            ),
                            const SizedBox(height: 13),
                          ],
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: _decoration(
                              label: 'Email',
                              icon: Icons.email_outlined,
                            ),
                            validator: AuthService.validateEmail,
                          ),
                          const SizedBox(height: 13),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _hidePass,
                            textInputAction: TextInputAction.done,
                            autofillHints: [
                              _isRegister
                                  ? AutofillHints.newPassword
                                  : AutofillHints.password,
                            ],
                            onFieldSubmitted: (_) => _submit(),
                            decoration:
                                _decoration(
                                  label: 'Mật khẩu',
                                  icon: Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    tooltip: _hidePass
                                        ? 'Hiện mật khẩu'
                                        : 'Ẩn mật khẩu',
                                    icon: Icon(
                                      _hidePass
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: _muted,
                                    ),
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
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFB42318),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: _loading ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: _purple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: Text(
                                _isRegister ? 'Tạo tài khoản' : 'Đăng nhập',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => setState(() {
                                    _isRegister = !_isRegister;
                                    _error = null;
                                  }),
                            style: TextButton.styleFrom(
                              foregroundColor: _purple,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(
                              _isRegister
                                  ? 'Đã có tài khoản?  Đăng nhập'
                                  : 'Chưa có tài khoản?  Đăng ký',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
  }) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: _muted, size: 20),
    filled: true,
    fillColor: _field,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE8E5EF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE8E5EF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _purple, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD92D20)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD92D20), width: 1.5),
    ),
  );
}
