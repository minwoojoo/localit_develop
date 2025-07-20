import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localit/screens/matching/explore_screen.dart';
import 'package:localit/screens/auth/profile_screen.dart';
import 'package:localit/screens/matching/match_requests_screen.dart';
import 'package:localit/screens/commerce/purchase_agency_screen.dart';
import 'package:localit/screens/community/community_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasShownPopup = false;

  @override
  void initState() {
    super.initState();
    // 화면이 로드된 후 매칭 요청 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMatchRequests();
    });
  }

  Future<void> _checkMatchRequests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 먼저 사용자가 로컬인인지 확인
      final localQuery = await FirebaseFirestore.instance
          .collection('locals')
          .where('user_id', isEqualTo: user.uid)
          .get();

      if (localQuery.docs.isEmpty) return; // 로컬인이 아니면 종료

      final localDocId = localQuery.docs.first.id;

      // 해당 로컬인에게 온 pending 상태의 매칭 요청 확인
      final matchRequestsQuery = await FirebaseFirestore.instance
          .collection('match_requests')
          .where('receiver_id', isEqualTo: localDocId)
          .where('status', isEqualTo: 'pending')
          .get();

      // pending 상태의 요청이 있고 아직 팝업을 보여주지 않았다면
      if (matchRequestsQuery.docs.isNotEmpty && !_hasShownPopup && mounted) {
        setState(() {
          _hasShownPopup = true;
        });

        _showMatchRequestDialog();
      }
    } catch (e) {
      print('매칭 요청 확인 중 오류: $e');
    }
  }

  void _showMatchRequestDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('매칭 요청 알림'),
          content: const Text('매칭 요청이 왔습니다!\n요청을 확인하러 갈까요?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('아니오'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MatchRequestsScreen(),
                  ),
                );
              },
              child: const Text('네'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LocalIt 로고
              Image.asset(
                'assets/logo.png',
                height: 24,
              ),
              const SizedBox(height: 2),
              // 태그라인
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '신뢰',
                      style: TextStyle(
                        fontSize: 7,
                        color: Colors.pink[400],
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text: '할 수 있는 ',
                      style: TextStyle(
                        fontSize: 7,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text: '현지인',
                      style: TextStyle(
                        fontSize: 7,
                        color: Colors.pink[400],
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text: '들의 실제 여행정보',
                      style: TextStyle(
                        fontSize: 7,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: user == null
          ? const Center(child: Text('로그인이 필요합니다.'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String nickname = '회원';
                if (snapshot.hasData && snapshot.data!.data() != null) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  nickname = data['nickname'] ?? '회원';
                }
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 메인 배너 (이미지 배경)
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage('assets/home_image.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '$nickname님,\nLocalit과 함께 여행을 계획해 보세요',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 2단 그리드
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ExploreScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 80,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('로컬 매칭 찾기',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.blue)),
                                    SizedBox(height: 4),
                                    Text('현지 로컬 메이트와 여행 계획을 함께하세요',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PurchaseAgencyScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 80,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('예약 구매 대행',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.green)),
                                    SizedBox(height: 4),
                                    Text('여행 예약, 상품 구매를 도와드려요',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('단양을 여행 중입니다',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.orange)),
                                  SizedBox(height: 4),
                                  Text('05.13', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CommunityHomeScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 80,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('LocalIT 커뮤니티',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.lightBlue)),
                                    SizedBox(height: 4),
                                    Text('로컬인과 여행자의 연결을 가장 쉽고 따뜻하게',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
