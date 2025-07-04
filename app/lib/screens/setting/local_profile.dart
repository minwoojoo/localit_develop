import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocalProfileScreen extends StatelessWidget {
  const LocalProfileScreen({super.key});

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
        title: const Text('로컬인 프로필'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('locals')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '로컬인 정보가 없습니다.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '로컬인 등록을 먼저 해주세요.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final certified = data['certified'] ?? false;
          final age = data['age']?.toString() ?? '-';
          final gender = data['gender'] ?? '-';
          final preferredMeetup = data['preferred_meetup'] ?? '-';
          final preferredLocation = data['preferred_location'] ?? '-';
          final interests =
              (data['interests'] as List<dynamic>?)?.cast<String>() ?? [];
          final hobbies = data['hobbies'] ?? '-';
          final introduction = data['introduction'] ?? '';
          final profileImageUrl = data['profile_image_url'] ?? '';
          final verificationStatus = data['verification_status'] ?? 'pending';
          final createdAt = data['created_at'] ?? '-';
          final updatedAt = data['updated_at'] ?? '-';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 이미지
                if (profileImageUrl.isNotEmpty) ...[
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(profileImageUrl),
                      backgroundColor: const Color(0xFFEAE2F8),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 인증 상태 카드
                Card(
                  color:
                      certified ? Colors.green.shade50 : Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          certified ? Icons.verified : Icons.pending,
                          color: certified ? Colors.green : Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                certified ? '인증된 로컬인' : '인증 대기중',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      certified ? Colors.green : Colors.orange,
                                ),
                              ),
                              Text(
                                '검증 상태: ${_getVerificationStatusText(verificationStatus)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 기본 정보
                const Text(
                  '기본 정보',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoCard([
                  _buildInfoRow('나이', age),
                  _buildInfoRow('성별', gender),
                  _buildInfoRow('선호 만남 방식', preferredMeetup),
                  _buildInfoRow('선호 지역', preferredLocation),
                ]),
                const SizedBox(height: 24),

                // 관심사
                const Text(
                  '관심사',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoCard([
                  _buildInfoRow('관심 분야',
                      interests.isNotEmpty ? interests.join(', ') : '-'),
                  _buildInfoRow('취미', hobbies),
                ]),
                const SizedBox(height: 24),

                // 자기소개
                if (introduction.isNotEmpty) ...[
                  const Text(
                    '자기소개',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '자기소개',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            introduction,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 시스템 정보
                const Text(
                  '시스템 정보',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoCard([
                  _buildInfoRow('생성일', _formatTimestamp(createdAt)),
                  _buildInfoRow('수정일', _formatTimestamp(updatedAt)),
                ]),
                const SizedBox(height: 32),

                // 수정 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // TODO: 로컬인 정보 수정 화면으로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('수정 기능은 준비 중입니다.')),
                      );
                    },
                    child: const Text(
                      '로컬인 정보 수정',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _getVerificationStatusText(String status) {
    switch (status) {
      case 'pending':
        return '검토 중';
      case 'approved':
        return '승인됨';
      case 'rejected':
        return '거부됨';
      default:
        return '알 수 없음';
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == '-') return '-';
    try {
      if (timestamp is Timestamp) {
        return '${timestamp.toDate().year}-${timestamp.toDate().month.toString().padLeft(2, '0')}-${timestamp.toDate().day.toString().padLeft(2, '0')}';
      } else if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return timestamp.toString();
    }
    return timestamp.toString();
  }
}
