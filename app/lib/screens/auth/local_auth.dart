import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'local_registration.dart';
// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:cloud_firestore/cloud_firestore.dart';

class LocalAuthScreen extends StatefulWidget {
  const LocalAuthScreen({super.key});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  // String? _verificationId;
  bool _isLoading = false;
  bool _codeSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  // String formatToE164(String input) {
  //   String digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  //   if (digits.startsWith('010')) {
  //     return '+82' + digits.substring(1);
  //   }
  //   if (digits.startsWith('82')) {
  //     return '+$digits';
  //   }
  //   return input;
  // }

  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final phone = _phoneController.text.trim();

      // 모의 전화번호 인증: "01012345678"만 허용
      if (phone == "01012345678") {
        setState(() {
          _codeSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('인증코드가 전송되었습니다. (654321)'),
              backgroundColor: Colors.green),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('올바른 전화번호를 입력해주세요. (01012345678)'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('인증코드 전송 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // // 사용자의 전화번호 인증 상태를 업데이트하는 함수
  // Future<void> _updateUserPhoneVerification(
  //     String userId, String phoneNumber) async {
  //   try {
  //     // 사용자 문서가 존재하는지 확인
  //     final userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .get();

  //     if (userDoc.exists) {
  //       // 기존 사용자 문서 업데이트
  //       await FirebaseFirestore.instance.collection('users').doc(userId).update({
  //         'phone_number': phoneNumber,
  //         'phone_verified': true,
  //         'phone_verification_date': FieldValue.serverTimestamp(),
  //         'updated_at': FieldValue.serverTimestamp(),
  //       });
  //     } else {
  //       // 사용자 문서가 없는 경우 새로 생성 (전화번호 인증 사용자용)
  //       final currentUser = FirebaseAuth.instance.currentUser;
  //       if (currentUser != null) {
  //         await FirebaseFirestore.instance.collection('users').doc(userId).set({
  //           'user_id': userId,
  //           'email': currentUser.email,
  //           'phone_number': phoneNumber,
  //           'phone_verified': true,
  //           'phone_verification_date': FieldValue.serverTimestamp(),
  //           'created_at': FieldValue.serverTimestamp(),
  //           'updated_at': FieldValue.serverTimestamp(),
  //           'nickname': currentUser.displayName ?? '사용자',
  //           'trust_score': 50.0,
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print('Error updating phone verification: $e');
  //   }
  // }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
              await _sendVerificationCode();
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
      onPressed: (_isLoading || !_codeSent)
          ? null
          : () async {
              setState(() => _isLoading = true);
              try {
                final smsCode = _smsCodeController.text.trim();

                // 모의 인증코드 확인: "654321"만 허용
                if (smsCode == "654321") {
                  setState(() => _isLoading = false);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LocalRegistrationScreen()),
                  );
                } else {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('올바른 인증코드를 입력해주세요. (654321)'),
                        backgroundColor: Colors.red),
                  );
                }
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('전화번호 인증',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              if (_codeSent) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _smsCodeController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: '인증코드',
                    border: OutlineInputBorder(),
                    hintText: '654321',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                verifyButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
