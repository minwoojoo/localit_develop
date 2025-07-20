import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 여백
            const Expanded(
              flex: 2,
              child: SizedBox(),
            ),
            // 메인 콘텐츠 (로고 + 태그라인)
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LocalIt 로고
                    Image.asset(
                      'assets/logo.png',
                      height: 80,
                    ),
                    const SizedBox(height: 16),
                    // 태그라인
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '신뢰',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.pink[400],
                              height: 1.4,
                            ),
                          ),
                          TextSpan(
                            text: '할 수 있는 ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              height: 1.4,
                            ),
                          ),
                          TextSpan(
                            text: '현지인',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.pink[400],
                              height: 1.4,
                            ),
                          ),
                          TextSpan(
                            text: '들의 실제 여행 정보',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 하단 여백
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            // 시작하기 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // 시작하기 버튼 클릭 시 처리
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
