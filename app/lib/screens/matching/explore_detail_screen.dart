import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExploreDetailScreen extends StatelessWidget {
  final String localId;
  const ExploreDetailScreen({super.key, required this.localId});

  String meetupTypeText(dynamic value) {
    if (value == null) return '';
    if (value is String) {
      final v = value.toLowerCase();
      if (v.contains('on') && v.contains('off')) return '온/오프';
      if (v == '둘 다' || v == 'both') return '온/오프';
      if (v.contains('on')) return '온';
      if (v.contains('off')) return '오프';
      return value;
    }
    if (value is List) {
      final list = value.map((e) => e.toString().toLowerCase()).toList();
      if (list.contains('on') && list.contains('off')) return '온/오프';
      if (list.contains('on')) return '온';
      if (list.contains('off')) return '오프';
      return list.join(', ');
    }
    return value.toString();
  }

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

  Future<void> _showRequestDialog(BuildContext context, String localId) async {
    // 현재 로그인한 사용자 확인
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    // 로컬인 문서에서 user_id 확인
    try {
      final localDoc = await FirebaseFirestore.instance
          .collection('locals')
          .doc(localId)
          .get();

      if (!localDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로컬인 정보를 찾을 수 없습니다')),
        );
        return;
      }

      final localData = localDoc.data() as Map<String, dynamic>;
      final localUserId = localData['user_id'];

      // 디버깅을 위한 로그
      print('DEBUG: localUserId = $localUserId');
      print('DEBUG: current user.uid = ${user.uid}');
      print('DEBUG: localId = $localId');

      // 본인의 게시글인지 확인
      if (localUserId == user.uid) {
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
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('매칭 요청'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: '메시지',
                  hintText: '로컬인에게 전할 메시지를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: '희망 날짜',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    dateController.text =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
                readOnly: true,
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
                if (dateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('희망 날짜를 선택해주세요')),
                  );
                  return;
                }

                await _submitMatchRequest(
                  context,
                  localId,
                  messageController.text.trim(),
                  dateController.text,
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

  Future<void> _submitMatchRequest(BuildContext context, String localId,
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

      // 매칭 요청 저장
      await FirebaseFirestore.instance.collection('match_requests').add({
        'requester_id': user.uid,
        'receiver_id': localId,
        'requester_nickname': requesterNickname,
        'status': 'pending',
        'preferred_date': preferredDate,
        'message': message,
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
          '🌏 로컬인 소개',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('locals').doc(localId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('정보를 불러올 수 없습니다.'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;

          final nickname = data['nickname'] ?? '';
          final schoolOrCompany = data['school_or_company'] ?? '';
          final languages = _convertToList<String>(data['languages']);
          final tags = _convertToList<String>(data['tags']);
          final isGraduated = data['is_graduated'] ?? false;
          final mannerScore = data['manner_score'] ?? 60.0;
          final matchCount = data['match_count'] ?? 0;
          final preferredLocation = data['preferred_location'] ?? '';
          final preferredMeetup = data['preferred_meetup'] ?? '';
          final personalInfo = data['personal_info'] ?? '';
          final introduction = data['introduction'] ?? '';
          final interests = _convertToList<String>(data['interests']);

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
                                  color: Colors.green, size: 20),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // 학교/직장 정보
                          if (schoolOrCompany.isNotEmpty)
                            Text(
                              schoolOrCompany,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(height: 4),
                          // 가능언어
                          if (languages.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.book,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  languages.join(' | '),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          // 배지
                          if (isGraduated || interests.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isGraduated)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '대학졸업',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                if (interests.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  const Text(
                                    '관심분야',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: interests
                                        .take(3)
                                        .map((interest) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                interest,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ],
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

                // 회원 정보 섹션
                const Text(
                  '회원 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _infoRow('희망 지역', preferredLocation),
                _infoRow('매칭 방식',
                    '${meetupTypeText(preferredMeetup)} | 누적매칭횟수 ${matchCount}회'),
                _infoRow(
                    '인적 사항', personalInfo.isNotEmpty ? personalInfo : '정보 없음'),
                _infoRow('매너 온도',
                    '${(mannerScore - 6).round()}~${(mannerScore + 6).round()}°C',
                    valueColor: Colors.orange),
                const SizedBox(height: 16),

                // 관심사 태그
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 24),

                // 구분선
                const Divider(color: Colors.black, thickness: 1),
                const SizedBox(height: 24),

                // 자기소개
                if (introduction.isNotEmpty)
                  Text(
                    introduction,
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
                          await _showRequestDialog(context, localId);
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
