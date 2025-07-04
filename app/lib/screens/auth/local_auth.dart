import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'local_registration.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
// 웹에서만 dart:html import
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class LocalAuthScreen extends StatefulWidget {
  const LocalAuthScreen({super.key});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  String? _verificationId;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  String formatToE164(String input) {
    String digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('010')) {
      return '+82' + digits.substring(1);
    }
    if (digits.startsWith('82')) {
      return '+$digits';
    }
    return input;
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: (!kIsWeb || _isLoading)
          ? null
          : () async {
              if (!_formKey.currentState!.validate()) return;
              setState(() => _isLoading = true);
              final auth = FirebaseAuth.instance;
              final phone = formatToE164(_phoneController.text);
              await auth.verifyPhoneNumber(
                phoneNumber: phone,
                verificationCompleted: (PhoneAuthCredential credential) async {
                  await auth.signInWithCredential(credential);
                  setState(() => _isLoading = false);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LocalRegistrationScreen()),
                  );
                },
                verificationFailed: (FirebaseAuthException e) {
                  setState(() => _isLoading = false);
                  String msg = e.code == 'invalid-phone-number'
                      ? '유효하지 않은 전화번호입니다.'
                      : '인증 실패: ${e.message}';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg), backgroundColor: Colors.red),
                  );
                },
                codeSent: (String verificationId, int? resendToken) {
                  setState(() {
                    _verificationId = verificationId;
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('인증코드가 전송되었습니다.'),
                        backgroundColor: Colors.green),
                  );
                },
                codeAutoRetrievalTimeout: (String verificationId) {
                  _verificationId = verificationId;
                },
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : const Text('인증코드 전송', style: TextStyle(color: Colors.white)),
    );
  }

  Widget verifyButton() {
    return ElevatedButton(
      onPressed: (!kIsWeb || _isLoading || _verificationId == null)
          ? null
          : () async {
              setState(() => _isLoading = true);
              try {
                final credential = PhoneAuthProvider.credential(
                  verificationId: _verificationId!,
                  smsCode: _smsCodeController.text,
                );
                await FirebaseAuth.instance.signInWithCredential(credential);
                setState(() => _isLoading = false);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LocalRegistrationScreen()),
                );
              } catch (e) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('인증 실패: $e'), backgroundColor: Colors.red),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : const Text('인증하기', style: TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로컬인 전화번호 인증'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: kIsWeb
            ? Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('전화번호 인증',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: '전화번호',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        hintText: '01012345678 형식으로 입력해주세요',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '전화번호를 입력하세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    submitButton(),
                    if (_verificationId != null) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _smsCodeController,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          labelText: '인증코드',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      verifyButton(),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      width: 300,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('reCAPTCHA가 여기에 표시됩니다'),
                      ),
                    ),
                  ],
                ),
              )
            : const Center(
                child: Text(
                  '앱(모바일)에서는 전화번호 인증이 지원되지 않습니다.',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }
}
