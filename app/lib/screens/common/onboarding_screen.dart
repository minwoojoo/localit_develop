import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 370, // 이미지의 카드 폭에 맞춤
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 로고
                  Image.asset(
                    'assets/logo.png',
                    height: 80,
                  ),
                  const SizedBox(height: 24),
                  // 안내 문구들
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. 현지인 매칭 안내
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('| ',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('👬 ', style: TextStyle(fontSize: 20)),
                          Expanded(
                            child: Text(
                              '현지인 매칭 내 관심사와 잘 맞는 현지 사람과 매칭되어 진짜 로컬 친구처럼 여행을 시작해요.',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // 2. 하루 가이드 안내
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('| ',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('🗺️ ', style: TextStyle(fontSize: 20)),
                          Expanded(
                            child: Text(
                              '하루 가이드 경험 맛집, 카페, 산책 코스를 함께 즐기며 짧은 시간에 현지인처럼 살아봐요.',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // 3. 일정 설계 안내
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('| ',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('📅 ', style: TextStyle(fontSize: 20)),
                          Expanded(
                            child: Text(
                              '간편한 여행 일정 설계 채팅으로 대화하고, 일정·예약까지 앱 하나로 간편하게 준비 끝!',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // 4. Local-it 안내
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('| ',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          // 🟩 대신 녹색 정사각형
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(right: 4, top: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Local-it',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 16),
                                  ),
                                  TextSpan(
                                    text:
                                        " 여행을 검색 대신 '사람'을 통해 시작하세요. 당신과 잘 맞는 현지인이 직접 여행을 제안해줍니다.",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  // 서비스 문의 안내 및 하단부 전체 왼쪽 정렬
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '서비스가 궁금하면 바로 클릭!',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 18),
                      // WhatsApp 안내
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          children: [
                            WidgetSpan(
                                child: Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Text('📱', style: TextStyle(fontSize: 18)),
                            )),
                            TextSpan(text: '지금은 '),
                            TextSpan(
                                text: 'WhatsApp',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ', 곧 앱에서!'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 맞춤링크
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          children: [
                            WidgetSpan(
                                child: Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Text('👉', style: TextStyle(fontSize: 18)),
                            )),
                            TextSpan(
                                text: '[왓츠앱링크]',
                                style: TextStyle(
                                    decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '서울 로컬 여행을 한 발 먼저 시작하고\n정식 서비스 알림도 놓치지 마세요✉️',
                        style: TextStyle(
                            fontSize: 14, color: Colors.black87, height: 1.5),
                      ),
                      const SizedBox(height: 18),
                      const Text('✉️ [이메일 입력]', style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 6),
                      const Text('👉 [알림받기]', style: TextStyle(fontSize: 15)),
                    ],
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
