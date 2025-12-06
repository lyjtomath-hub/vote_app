import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/main_tab_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _pwCtrl = TextEditingController();
  bool _rememberEmail = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
    _checkAutoLogin();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    if (savedEmail != null) {
      setState(() {
        _emailCtrl.text = savedEmail;
        _rememberEmail = true;
      });
    }
  }

  Future<void> _checkAutoLogin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    }
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _pwCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력하세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 아이디 저장
      final prefs = await SharedPreferences.getInstance();
      if (_rememberEmail) {
        await prefs.setString('saved_email', email);
      } else {
        await prefs.remove('saved_email');
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: ${e.message}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSignupDialog() {
    // 회원가입용 별도 컨트롤러 생성
    final signupEmailCtrl = TextEditingController();
    final signupPwCtrl = TextEditingController();
    final signupPwConfirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원가입'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: signupEmailCtrl,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: signupPwCtrl,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: signupPwConfirmCtrl,
              decoration: const InputDecoration(labelText: '비밀번호 확인'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              signupEmailCtrl.dispose();
              signupPwCtrl.dispose();
              signupPwConfirmCtrl.dispose();
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = signupEmailCtrl.text.trim();
              final password = signupPwCtrl.text.trim();
              final confirmPassword = signupPwConfirmCtrl.text.trim();

              if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('모든 필드를 입력하세요')),
                );
                return;
              }

              if (password != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
                );
                return;
              }

              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('회원가입 성공! 로그인해주세요')),
                  );
                  // 이메일 필드에 자동 입력
                  _emailCtrl.text = email;
                  _pwCtrl.clear();
                }
              } on FirebaseAuthException catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('회원가입 실패: ${e.message}')),
                  );
                }
              } finally {
                signupEmailCtrl.dispose();
                signupPwCtrl.dispose();
                signupPwConfirmCtrl.dispose();
              }
            },
            child: const Text('회원가입'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('투표 앱'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: '이메일'),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwCtrl,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _rememberEmail,
                  onChanged: (value) {
                    setState(() => _rememberEmail = value ?? false);
                  },
                ),
                const Text('아이디 저장', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('로그인', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _isLoading ? null : _showSignupDialog,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('회원가입', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }
}
