import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localit/screens/matching/explore_screen.dart';
import 'package:localit/screens/auth/profile_screen.dart';
import 'package:localit/screens/matching/match_requests_screen.dart';
import 'package:localit/screens/commerce/purchase_agency_screen.dart';
import 'package:localit/screens/community/community_home_screen.dart';
import 'package:localit/screens/chat/chat_screen.dart';
import 'package:localit/screens/common/menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasShownPopup = false;
  int _selectedIndex = 0; // 홈 탭이 선택된 상태

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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: screenHeight * 0.08,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/logo.png',
              height: screenHeight * 0.035, // 화면 높이의 3.5%로 증가
            ),
            SizedBox(height: screenHeight * 0.002),
            RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '신뢰',
                    style: TextStyle(
                      fontSize: screenWidth * 0.012, // 화면 너비의 1.2%로 감소
                      color: Colors.pink[400],
                      height: 1.4,
                    ),
                  ),
                  TextSpan(
                    text: '할 수 있는 ',
                    style: TextStyle(
                      fontSize: screenWidth * 0.012, // 화면 너비의 1.2%로 감소
                      color: Colors.black,
                      height: 1.4,
                    ),
                  ),
                  TextSpan(
                    text: '현지인',
                    style: TextStyle(
                      fontSize: screenWidth * 0.012, // 화면 너비의 1.2%로 감소
                      color: Colors.pink[400],
                      height: 1.4,
                    ),
                  ),
                  TextSpan(
                    text: '들의 실제 여행정보',
                    style: TextStyle(
                      fontSize: screenWidth * 0.012, // 화면 너비의 1.2%로 감소
                      color: Colors.black,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search,
                color: Colors.black, size: screenWidth * 0.05),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person,
                color: Colors.black, size: screenWidth * 0.05),
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
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight -
                          (screenHeight * 0.08) -
                          MediaQuery.of(context).padding.top,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        children: [
                          // 메인 배너
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: const DecorationImage(
                                image: AssetImage('assets/home_image.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$nickname님',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 0.0,
                                        color: Color(0xFF1A237E), // 진한 파란색 테두리
                                      ),
                                      Shadow(
                                        offset: Offset(-1.0, -1.0),
                                        blurRadius: 0.0,
                                        color: Color(0xFF1A237E), // 진한 파란색 테두리
                                      ),
                                      Shadow(
                                        offset: Offset(1.0, -1.0),
                                        blurRadius: 0.0,
                                        color: Color(0xFF1A237E), // 진한 파란색 테두리
                                      ),
                                      Shadow(
                                        offset: Offset(-1.0, 1.0),
                                        blurRadius: 0.0,
                                        color: Color(0xFF1A237E), // 진한 파란색 테두리
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'LocalIt과 함께',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 0.0,
                                        color: Color(0xFF1A237E), // 진한 파란색 테두리
                                      ),
                                      Shadow(
                                        offset: Offset(-1.0, -1.0),
                                        blurRadius: 0.0,
                                        color: Color(0xFF1A237E), // 진한 파란색 테두리
                                      ),
                                      Shadow(
                                        offset: Offset(1.0, -1.0),
                                        blurRadius: 0.0,
                                        color: Color(0xFF1A237E), // 진한 파란색 테두리
                                      ),
                                      Shadow(
                                        offset: Offset(-1.0, 1.0),
                                        blurRadius: 0.0,
                                        color: Color(0xFF1A237E), // 진한 파란색 테두리
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '여행을 계획해 보세요',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 0.0,
                                        color: Color(0xFF1A237E), // 진한 파란색 테두리
                                      ),
                                      Shadow(
                                        offset: Offset(-1.0, -1.0),
                                        blurRadius: 0.0,
                                        color: Color(0xFF1A237E), // 진한 파란색 테두리
                                      ),
                                      Shadow(
                                        offset: Offset(1.0, -1.0),
                                        blurRadius: 0.0,
                                        color: Color(0xFF1A237E), // 진한 파란색 테두리
                                      ),
                                      Shadow(
                                        offset: Offset(-1.0, 1.0),
                                        blurRadius: 0.0,
                                        color: Color(0xFF1A237E), // 진한 파란색 테두리
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 메인 콘텐츠 영역
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 왼쪽: 로컬 매칭 찾기
                              Expanded(
                                flex: 5, // 3에서 5로 변경하여 5:4 비율 조정
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ExploreScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 300,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '로컬 매칭 찾기',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          '현지 로컬 메이트와\n여행 계획을 함께하세요',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // 오른쪽: 예약 구매 대행과 천안 여행
                              Expanded(
                                flex: 4, // 2에서 4로 변경하여 5:4 비율 조정
                                child: Column(
                                  children: [
                                    // 예약 구매 대행
                                    Container(
                                      width: double.infinity,
                                      height: 140,
                                      margin: const EdgeInsets.only(
                                          left: 8, bottom: 8),
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
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '예약 구매 대행',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                '여행 예약, 상품 구매를\n도와드려요',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // 천안을 여행중입니다
                                    Container(
                                      width: double.infinity,
                                      height: 140,
                                      margin: const EdgeInsets.only(
                                          left: 8, top: 8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                                'assets/home_image2.jpg'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '천안을 여행중입니다',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    offset: Offset(2.0, 2.0),
                                                    blurRadius: 4.0,
                                                    color: Colors.black87,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                '05.13',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  shadows: [
                                                    Shadow(
                                                      offset: Offset(2.0, 2.0),
                                                      blurRadius: 4.0,
                                                      color: Colors.black87,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // LocalIT 커뮤니티
                          GestureDetector(
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
                              width: double.infinity,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.lightBlue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LocalIt 커뮤니티',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '로컬인과 여행자의 연결을 가장 쉽고 따뜻하게',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20), // 하단 여백
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // 네비게이션 처리
          switch (index) {
            case 0:
              // 현재 화면이므로 아무것도 하지 않음
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const PurchaseAgencyScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const CommunityHomeScreen()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MenuScreen()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: '구매대행',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send_outlined),
            label: '메시지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.all_inclusive),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '메뉴',
          ),
        ],
      ),
    );
  }
}
