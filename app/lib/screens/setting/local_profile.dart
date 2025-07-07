import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocalProfileScreen extends StatefulWidget {
  const LocalProfileScreen({super.key});

  @override
  State<LocalProfileScreen> createState() => _LocalProfileScreenState();
}

class _LocalProfileScreenState extends State<LocalProfileScreen> {
  bool _editing = false;
  bool _loading = false;
  final _nicknameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = '남';
  String _selectedMeetup = '오프';
  String _selectedLocation = 'Hongdae';
  List<String> _selectedInterests = [];
  final _hobbiesController = TextEditingController();
  final _introductionController = TextEditingController();

  final List<String> _genderOptions = ['남', '여', '기타'];
  final List<String> _meetupOptions = ['온', '오프', '둘 다'];
  final List<String> _locationOptions = [
    'Hongdae',
    'Gangnam',
    'Myeongdong',
    'Itaewon',
    'Jongno',
    'Dongdaemun',
    'Seoul Station',
    'Yeouido'
  ];
  final List<String> _interestOptions = [
    'food',
    'culture',
    'shopping',
    'nature',
    'history',
    'art',
    'music',
    'sports',
    'technology'
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    _ageController.dispose();
    _hobbiesController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

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

          // 최초 진입 또는 저장 후 컨트롤러/상태 초기화
          if (!_editing || _loading) {
            _nicknameController.text = data['nickname'] ?? '';
            _ageController.text = data['age']?.toString() ?? '';
            _selectedGender = data['gender'] ?? '남';
            _selectedMeetup = data['preferred_meetup'] ?? '오프';
            _selectedLocation = data['preferred_location'] ?? 'Hongdae';
            _selectedInterests =
                (data['interests'] as List<dynamic>?)?.cast<String>() ?? [];
            _hobbiesController.text = data['hobbies'] ?? '';
            _introductionController.text = data['introduction'] ?? '';
          }

          final verificationStatus = data['verification_status'] ?? 'pending';
          final certified = verificationStatus == 'accepted';
          final profileImageUrl = data['profile_image_url'] ?? '';
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
                _editing
                    ? _buildEditableInfo()
                    : _buildInfoCard([
                        _buildInfoRow('닉네임', _nicknameController.text),
                        _buildInfoRow('나이', _ageController.text),
                        _buildInfoRow('성별', _selectedGender),
                        _buildInfoRow('선호 만남 방식', _selectedMeetup),
                        _buildInfoRow('선호 지역', _selectedLocation),
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
                _editing
                    ? _buildEditableInterests()
                    : _buildInfoCard([
                        _buildInfoRow(
                            '관심 분야',
                            _selectedInterests.isNotEmpty
                                ? _selectedInterests.join(', ')
                                : '-'),
                        _buildInfoRow('취미', _hobbiesController.text),
                      ]),
                const SizedBox(height: 24),

                // 자기소개
                if (_introductionController.text.isNotEmpty) ...[
                  const Text(
                    '자기소개',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _editing
                      ? TextFormField(
                          controller: _introductionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: '자기소개',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_pin),
                            hintText: '여행자들에게 자신을 소개해주세요. (선택사항)',
                          ),
                        )
                      : Card(
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
                                  _introductionController.text,
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

                // 수정/저장 버튼
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
                    onPressed: _loading
                        ? null
                        : () async {
                            if (!_editing) {
                              setState(() => _editing = true);
                              return;
                            }
                            setState(() => _loading = true);
                            try {
                              await FirebaseFirestore.instance
                                  .collection('locals')
                                  .doc(user.uid)
                                  .update({
                                'nickname': _nicknameController.text.trim(),
                                'age': int.tryParse(_ageController.text) ?? 0,
                                'gender': _selectedGender,
                                'preferred_meetup': _selectedMeetup,
                                'preferred_location': _selectedLocation,
                                'interests': _selectedInterests,
                                'hobbies': _hobbiesController.text.trim(),
                                'introduction':
                                    _introductionController.text.trim(),
                                'updated_at': DateTime.now().toIso8601String(),
                              });
                              setState(() => _editing = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('프로필이 수정되었습니다.')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('수정 실패: $e')),
                              );
                            } finally {
                              setState(() => _loading = false);
                            }
                          },
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_editing ? '저장' : '프로필 수정',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white)),
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

  Widget _buildEditableInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: '닉네임',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
                hintText: '예: 홍길동, SeoulGuy, 여행왕',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: '나이',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: '성별',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: _genderOptions.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedGender = value!);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedMeetup,
              decoration: const InputDecoration(
                labelText: '선호 만남 방식',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.meeting_room),
              ),
              items: _meetupOptions.map((meetup) {
                return DropdownMenuItem(
                  value: meetup,
                  child: Text(meetup),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedMeetup = value!);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: const InputDecoration(
                labelText: '선호 지역',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: _locationOptions.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedLocation = value!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInterests() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '관심 분야 (여러 개 선택 가능)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _interestOptions.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(_getInterestText(interest)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedInterests.add(interest);
                      } else {
                        _selectedInterests.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _hobbiesController,
              decoration: const InputDecoration(
                labelText: '취미',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_esports),
                hintText: '예: 등산, 사진, 요리',
              ),
              maxLines: 2,
            ),
          ],
        ),
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
      case 'accepted':
        return '인증됨';
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

  String _getInterestText(String interest) {
    switch (interest) {
      case 'food':
        return '음식';
      case 'culture':
        return '문화';
      case 'shopping':
        return '쇼핑';
      case 'nature':
        return '자연';
      case 'history':
        return '역사';
      case 'art':
        return '예술';
      case 'music':
        return '음악';
      case 'sports':
        return '스포츠';
      case 'technology':
        return '기술';
      default:
        return interest;
    }
  }
}
