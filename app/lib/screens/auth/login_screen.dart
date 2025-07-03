import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _saveLogin = false;
  bool _isLoading = false;

  Future<void> _signIn() async {
    final email = _idController.text.trim();
    final password = _pwController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('입력 오류'),
          content: const Text('이메일과 비밀번호를 입력해주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Firebase Authentication으로 로그인
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 로그인 성공 시 메인 화면으로 이동
      Navigator.pushReplacementNamed(context, '/main');
    } on FirebaseAuthException catch (e) {
      String errorMessage = '로그인 중 오류가 발생했습니다.';

      if (e.code == 'user-not-found') {
        errorMessage = '등록되지 않은 이메일입니다.';
      } else if (e.code == 'wrong-password') {
        errorMessage = '잘못된 비밀번호입니다.';
      } else if (e.code == 'invalid-email') {
        errorMessage = '유효하지 않은 이메일입니다.';
      } else if (e.code == 'user-disabled') {
        errorMessage = '비활성화된 계정입니다.';
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('로그인 실패'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('오류'),
          content: Text('로그인 중 오류가 발생했습니다: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // 로고
                Center(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: [
                        TextSpan(text: 'Lo'),
                        WidgetSpan(
                          child:
                              Icon(Icons.place, color: Colors.blue, size: 32),
                        ),
                        TextSpan(text: 'cal '),
                        TextSpan(
                            text: 'Mate', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // 계정 입력
                const Text('계정', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 6),
                TextField(
                  controller: _idController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 비밀번호 입력
                const Text('비밀번호', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 6),
                TextField(
                  controller: _pwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 로그인 정보 저장
                Row(
                  children: [
                    Checkbox(
                      value: _saveLogin,
                      onChanged: (val) {
                        setState(() {
                          _saveLogin = val ?? false;
                        });
                      },
                    ),
                    const Text('로그인 정보 저장'),
                  ],
                ),
                const SizedBox(height: 8),
                // 로그인 버튼
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('로그인',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                // 회원가입/비밀번호 찾기
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text('회원가입',
                          style: TextStyle(color: Colors.blue)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('비밀번호 찾기',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 소셜 로그인
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.g_mobiledata, size: 32),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble, size: 28), // 카카오톡 대체
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.nat, size: 28), // 네이버 대체
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.apple, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
