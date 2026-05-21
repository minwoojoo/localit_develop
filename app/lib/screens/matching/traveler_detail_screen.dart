import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localit/screens/matching/home_screen.dart';
import 'package:localit/screens/commerce/purchase_agency_screen.dart';
import 'package:localit/screens/chat/chat_screen.dart';
import 'package:localit/screens/community/community_home_screen.dart';
import 'package:localit/screens/common/menu_screen.dart';

class TravelerDetailScreen extends StatefulWidget {
  final String travelerPostId;
  const TravelerDetailScreen({super.key, required this.travelerPostId});

  @override
  State<TravelerDetailScreen> createState() => _TravelerDetailScreenState();
}

class _TravelerDetailScreenState extends State<TravelerDetailScreen> {
  int _selectedIndex = 0;

  Future<String?> getProfileImageUrl(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  List<T> _convertToList<T>(dynamic data) {
    if (data == null) return <T>[];
    if (data is List) {
      try {
        return data.cast<T>();
      } catch (e) {
        return <T>[];
      }
    }
    return <T>[];
  }

  // 사용자의 trust_score를 가져오는 함수
  Future<double> getUserTrustScore(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        return (userData?['trust_score'] ?? 30.0).toDouble();
      }
      return 30.0; // 기본값
    } catch (e) {
      return 30.0; // 기본값
    }
  }

  Future<void> _showMatchRequestDialog(
      BuildContext context, String travelerPostId) async {
    // 현재 로그인한 사용자 확인
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    // 여행자 게시글에서 user_id 확인
    try {
      final travelerDoc = await FirebaseFirestore.instance
          .collection('travelers_post')
          .doc(travelerPostId)
          .get();

      if (!travelerDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('여행자 정보를 찾을 수 없습니다')),
        );
        return;
      }

      final travelerData = travelerDoc.data() as Map<String, dynamic>;
      final travelerUserId = travelerData['user_id'];

      // 본인의 게시글인지 확인
      if (travelerUserId == user.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('본인의 게시글입니다'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')),
      );
      return;
    }

    final messageController = TextEditingController();
    final preferredDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('매칭 요청하기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: '메시지',
                  hintText: '여행자에게 전할 메시지를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: preferredDateController,
                decoration: const InputDecoration(
                  labelText: '희망 날짜 (선택사항)',
                  hintText: '예: 2024.03.20~03.25',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (messageController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('메시지를 입력해주세요')),
                  );
                  return;
                }

                await _submitMatchRequest(
                  context,
                  travelerPostId,
                  messageController.text.trim(),
                  preferredDateController.text.trim(),
                );
                Navigator.of(context).pop();
              },
              child: const Text('요청하기'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitMatchRequest(BuildContext context, String travelerPostId,
      String message, String preferredDate) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
        return;
      }

      // 요청자 정보 가져오기
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();
      final requesterNickname = userData?['nickname'] ?? '알 수 없음';

      // 여행자 게시글 정보 가져오기
      final travelerDoc = await FirebaseFirestore.instance
          .collection('travelers_post')
          .doc(travelerPostId)
          .get();

      if (!travelerDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('여행자 정보를 찾을 수 없습니다')),
        );
        return;
      }

      final travelerData = travelerDoc.data() as Map<String, dynamic>;
      final travelerUserId = travelerData['user_id'];

      // 매칭 요청 저장
      await FirebaseFirestore.instance.collection('match_requests').add({
        'requester_id': user.uid, // 요청자 ID
        'receiver_id': travelerUserId, // 여행자 ID (받는 사람)
        'traveler_post_id': travelerPostId, // 여행자 게시글 ID
        'requester_nickname': requesterNickname,
        'message': message,
        'preferred_date': preferredDate,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('매칭 요청이 전송되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('요청 전송 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '✈️ 여행자 소개',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('travelers_post')
            .doc(widget.travelerPostId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('정보를 불러올 수 없습니다.'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;

          final nickname = data['nickname'] ?? '';
          final age = data['age'] ?? '';
          final nationality = data['nationality'] ?? '';
          final gender = data['gender'] ?? '';
          final accommodationInfo = data['accommodation_info'] ?? '';
          final matchingMethod = data['matching_method'] ?? '';
          final visitSchedule = data['visit_schedule'] ?? '';
          final hashtags = _convertToList<String>(data['hashtags']);
          final description = data['description'] ?? '';
          final matchingCount = data['matching_count'] ?? 0;
          final userId = data['user_id'] ?? '';
          final createdAt = data['created_at'] as Timestamp?;

          // 날짜 포맷팅
          String formattedDate = '';
          if (createdAt != null) {
            final date = createdAt.toDate();
            formattedDate =
                '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 헤더 섹션
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 프로필 이미지
                    FutureBuilder<String?>(
                      future: getProfileImageUrl(data['profile_image_url']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                          );
                        }
                        final url = snapshot.data;
                        return CircleAvatar(
                          radius: 40,
                          backgroundImage: (url != null && url.isNotEmpty)
                              ? NetworkImage(url)
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: (url == null || url.isEmpty)
                              ? const Icon(Icons.person,
                                  color: Colors.white, size: 40)
                              : null,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    // 프로필 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 이름과 인증 마크
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  nickname,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const Icon(Icons.verified,
                                  color: Colors.green, size: 18),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // 나이, 국적, 성별
                          if (age.isNotEmpty &&
                              nationality.isNotEmpty &&
                              gender.isNotEmpty)
                            Text(
                              '${age}세 | $nationality | $gender',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(height: 4),
                          // 누적매칭횟수
                          Text(
                            '누적매칭횟수 ${matchingCount}회',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 매너온도 (FutureBuilder로 trust_score 가져오기)
                          FutureBuilder<double>(
                            future: getUserTrustScore(userId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text(
                                  '매너 온도 로딩중...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                );
                              }
                              final trustScore = snapshot.data ?? 30.0;
                              return Text(
                                '매너 온도 ${(trustScore - 2).toInt()} ~ ${(trustScore + 2).toInt()}°C',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 구분선
                const Divider(color: Colors.black, thickness: 1),
                const SizedBox(height: 24),

                // 여행 정보 섹션
                const Text(
                  '여행 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _infoRow('숙소 정보', accommodationInfo),
                _infoRow('매칭 방식', matchingMethod),
                _infoRow('방문 일정', visitSchedule),
                if (formattedDate.isNotEmpty) _infoRow('게시일', formattedDate),
                const SizedBox(height: 16),

                // 해시태그
                if (hashtags.isNotEmpty) ...[
                  const Text(
                    '관심 해시태그',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: hashtags
                        .map((hashtag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#$hashtag',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // 구분선
                const Divider(color: Colors.black, thickness: 1),
                const SizedBox(height: 24),

                // 여행 자기소개
                const Text(
                  '여행 자기소개',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                const SizedBox(height: 24),

                // 하단 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {},
                        child: const Text(
                          '더보기',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          await _showMatchRequestDialog(
                              context, widget.travelerPostId);
                        },
                        child: const Text(
                          '요청하기',
                          style: TextStyle(color: Colors.white),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
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

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: Text(
              value,
              style: valueColor != null ? TextStyle(color: valueColor) : null,
            ),
          ),
        ],
      ),
    );
  }
}
