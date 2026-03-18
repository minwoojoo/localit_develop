import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchRequestsScreen extends StatelessWidget {
  const MatchRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('받은 매칭 요청'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('locals')
            .where('user_id', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, localSnapshot) {
          if (localSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!localSnapshot.hasData || localSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('로컬인 정보를 찾을 수 없습니다.'));
          }

          final localDocId = localSnapshot.data!.docs.first.id;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('match_requests')
                .where('receiver_id', isEqualTo: localDocId)
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '받은 매칭 요청이 없습니다.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final requesterNickname =
                      data['requester_nickname'] ?? '알 수 없음';
                  final message = data['message'] ?? '';
                  final preferredDate = data['preferred_date'] ?? '';
                  final status = data['status'] ?? 'pending';
                  final createdAt = data['created_at'] as Timestamp?;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  requesterNickname.isNotEmpty
                                      ? requesterNickname[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      requesterNickname,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (createdAt != null)
                                      Text(
                                        '${createdAt.toDate().year}-${createdAt.toDate().month.toString().padLeft(2, '0')}-${createdAt.toDate().day.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              _buildStatusChip(status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (preferredDate.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '희망 날짜: $preferredDate',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            message,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  onPressed: () => _updateRequestStatus(
                                      context, doc.id, 'rejected'),
                                  child: const Text(
                                    '거부',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: () => _updateRequestStatus(
                                      context, doc.id, 'accepted'),
                                  child: const Text(
                                    '수락',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = '대기중';
        break;
      case 'accepted':
        color = Colors.green;
        text = '수락됨';
        break;
      case 'rejected':
        color = Colors.red;
        text = '거부됨';
        break;
      default:
        color = Colors.grey;
        text = '알 수 없음';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _updateRequestStatus(
      BuildContext context, String requestId, String status) async {
    try {
      // 매칭 요청 상태 업데이트
      await FirebaseFirestore.instance
          .collection('match_requests')
          .doc(requestId)
          .update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // 수락된 경우 채팅방 생성
      if (status == 'accepted') {
        await _createChatRoom(context, requestId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'accepted'
              ? '요청을 수락했습니다! 채팅방이 생성되었습니다.'
              : '요청을 거부했습니다.'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('상태 업데이트 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createChatRoom(BuildContext context, String requestId) async {
    try {
      // 매칭 요청 정보 가져오기
      final requestDoc = await FirebaseFirestore.instance
          .collection('match_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw Exception('매칭 요청 정보를 찾을 수 없습니다.');
      }

      final requestData = requestDoc.data() as Map<String, dynamic>;
      final requesterId = requestData['requester_id']; // 여행자 ID
      final receiverId = requestData['receiver_id']; // 로컬인 문서 ID

      // receiver_id는 locals 컬렉션의 문서 ID이므로, 해당 로컬인의 user_id를 가져와야 함
      final localDoc = await FirebaseFirestore.instance
          .collection('locals')
          .doc(receiverId)
          .get();

      if (!localDoc.exists) {
        throw Exception('로컬인 정보를 찾을 수 없습니다.');
      }

      final localData = localDoc.data() as Map<String, dynamic>;
      final localUserId = localData['user_id']; // 로컬인의 실제 user_id

      // 이미 채팅방이 존재하는지 확인
      final existingChatRoom = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('traveler_id', isEqualTo: requesterId)
          .where('local_id', isEqualTo: localUserId)
          .get();

      if (existingChatRoom.docs.isNotEmpty) {
        // 이미 채팅방이 존재하는 경우
        print('이미 채팅방이 존재합니다.');
        return;
      }

      // 새 채팅방 생성
      await FirebaseFirestore.instance.collection('chat_rooms').add({
        'traveler_id': requesterId, // 여행자 ID
        'local_id': localUserId, // 로컬인의 user_id
        'related_match_id': requestId, // 매칭 요청 ID
        'created_at': FieldValue.serverTimestamp(),
      });

      print('채팅방이 성공적으로 생성되었습니다.');
      print('traveler_id: $requesterId');
      print('local_id: $localUserId');
      print('related_match_id: $requestId');
    } catch (e) {
      print('채팅방 생성 중 오류: $e');
      // mounted 체크 후에만 SnackBar 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('채팅방 생성 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
