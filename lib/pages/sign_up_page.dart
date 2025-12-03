import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();

  bool _isLoading = false;
  String? _error;

  Future<bool> _isUsernameTaken(String username) async {
    final doc = await FirebaseFirestore.instance
        .collection('usernames')
        .doc(username)
        .get();
    return doc.exists;
  }

  Future<void> _register() async {
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _pwCtrl.text;

    if (username.isEmpty) {
      setState(() => _error = '아이디를 입력하세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final taken = await _isUsernameTaken(username);
      if (taken) {
        setState(() {
          _error = '이미 사용 중인 아이디입니다.';
          _isLoading = false;
        });
        return;
      }

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) throw Exception('회원가입 실패 (user null)');
      final uid = user.uid;

      // ✅ 유저 정보 저장 + 기본 질문권 3개
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'uid': uid,
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'tickets': 3,
        'answeredCount': 0,
      });

      await FirebaseFirestore.instance
          .collection('usernames')
          .doc(username)
          .set({'uid': uid});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공!')),
        );
        Navigator.pop(context); // 회원가입 후 로그인 페이지로 이동
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '예상치 못한 오류: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _pwCtrl,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _register,
                child: const Text('가입하기'),
              ),
          ],
        ),
      ),
    );
  }
}
