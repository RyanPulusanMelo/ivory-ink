import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'main.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final box = Hive.box("database");

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;
  String _msg = "";

  void _signUp() {
    final username = _username.text.trim();
    final password = _password.text.trim();
    final confirm = _confirm.text.trim();

    if (username.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _msg = "All fields are required.");
      return;
    }
    if (password != confirm) {
      setState(() => _msg = "Passwords do not match.");
      return;
    }
    if (password.length < 4) {
      setState(() => _msg = "Password must be at least 4 characters.");
      return;
    }

    box.put("username", username);
    box.put("password", password);
    box.put("biometrics", false);

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF000000),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 52),

              // ── OPUS Logo ──────────────────────────────
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.square_grid_2x2_fill,
                        color: Color(0xFF000000),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'OPUS',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFFFFFF),
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'MASTER YOUR TASKS',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF3A3A3C),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 48),

              // ── Heading ────────────────────────────────
              const Text(
                'Create your\naccount',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFFFFF),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your data stays on this device.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF636366),
                ),
              ),

              const SizedBox(height: 32),

              // ── Username ───────────────────────────────
              _buildField(
                controller: _username,
                placeholder: 'Username',
                icon: CupertinoIcons.person,
              ),
              const SizedBox(height: 10),

              // ── Password ───────────────────────────────
              _buildField(
                controller: _password,
                placeholder: 'Password',
                icon: CupertinoIcons.lock,
                obscure: _hidePassword,
                toggleObscure: () =>
                    setState(() => _hidePassword = !_hidePassword),
                showToggle: true,
                isHidden: _hidePassword,
              ),
              const SizedBox(height: 10),

              // ── Confirm Password ───────────────────────
              _buildField(
                controller: _confirm,
                placeholder: 'Confirm password',
                icon: CupertinoIcons.lock,
                obscure: _hideConfirm,
                toggleObscure: () =>
                    setState(() => _hideConfirm = !_hideConfirm),
                showToggle: true,
                isHidden: _hideConfirm,
              ),

              // ── Error message ──────────────────────────
              if (_msg.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_circle_fill,
                      color: CupertinoColors.destructiveRed,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _msg,
                        style: const TextStyle(
                          color: CupertinoColors.destructiveRed,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // ── Create Account Button ──────────────────
              GestureDetector(
                onTap: _signUp,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Center(
                    child: Text(
                      'CREATE ACCOUNT',
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Sign in link ───────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3A3A3C),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => const LoginPage()),
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool obscure = false,
    bool showToggle = false,
    bool isHidden = true,
    VoidCallback? toggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: obscure,
        placeholderStyle: const TextStyle(
          color: Color(0xFF48484A),
          fontSize: 15,
        ),
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 15,
        ),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(icon, color: const Color(0xFF48484A), size: 17),
        ),
        suffix: showToggle
            ? GestureDetector(
          onTap: toggleObscure,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              isHidden ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              color: const Color(0xFF3A3A3C),
              size: 17,
            ),
          ),
        )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: const BoxDecoration(),
      ),
    );
  }
}