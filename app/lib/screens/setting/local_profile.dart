import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import '../auth/local_auth.dart';

class LocalProfileScreen extends StatefulWidget {
  const LocalProfileScreen({super.key});

  @override
  State<LocalProfileScreen> createState() => _LocalProfileScreenState();
}

class _LocalProfileScreenState extends State<LocalProfileScreen> {
  bool _editing = false;
  bool _loading = false;
  bool _uploadingImage = false;
  final _nicknameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = '남';
  String _selectedMeetup = '오프';
  String _selectedLocation = 'Hongdae';
  List<String> _selectedInterests = [];
  final _hobbiesController = TextEditingController();
  final _introductionController = TextEditingController();
  final _schoolOrCompanyController = TextEditingController();
  final _languagesController = TextEditingController();
  final _tagsController = TextEditingController();
  final _personalInfoController = TextEditingController();
  bool _isGraduated = false;

  // 이미지 관련 변수
  String _currentProfileImageUrl = '';

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
    _schoolOrCompanyController.dispose();
    _languagesController.dispose();
    _tagsController.dispose();
    _personalInfoController.dispose();
    super.dispose();
  }

  // 이미지 선택 및 업로드 함수
  Future<void> _pickAndUploadImage(String uid) async {
    try {
      setState(() => _uploadingImage = true);

      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (picked == null) {
        setState(() => _uploadingImage = false);
        return;
      }

      // 로딩 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 업로드 중입니다...')),
        );
      }

      // 파일 확장자에 따라 contentType 결정
      String contentType;
      String fileExtension;

      if (kIsWeb) {
        // 웹에서는 picked.name으로 파일명 확인
        final fileName = picked.name.toLowerCase();
        if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
          contentType = 'image/jpeg';
          fileExtension = 'jpg';
        } else if (fileName.endsWith('.png')) {
          contentType = 'image/png';
          fileExtension = 'png';
        } else if (fileName.endsWith('.gif')) {
          contentType = 'image/gif';
          fileExtension = 'gif';
        } else {
          // 기본값
          contentType = 'image/jpeg';
          fileExtension = 'jpg';
        }
      } else {
        // 모바일에서는 picked.path로 파일명 확인
        final fileName = picked.path.toLowerCase();
        if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
          contentType = 'image/jpeg';
          fileExtension = 'jpg';
        } else if (fileName.endsWith('.png')) {
          contentType = 'image/png';
          fileExtension = 'png';
        } else if (fileName.endsWith('.gif')) {
          contentType = 'image/gif';
          fileExtension = 'gif';
        } else {
          // 기본값
          contentType = 'image/jpeg';
          fileExtension = 'jpg';
        }
      }

      final storage = FirebaseStorage.instanceFor(
        bucket: 'localit-ef984.firebasestorage.app',
      );
      final ref = storage.ref().child('profile_images/$uid.$fileExtension');
      String url;

      if (kIsWeb) {
        // 웹: putData(Uint8List)
        final bytes = await picked.readAsBytes();
        final metadata = SettableMetadata(
          contentType: contentType,
          customMetadata: {'userId': uid},
        );
        await ref.putData(bytes, metadata);
        url = await ref.getDownloadURL();
      } else {
        // 모바일: putFile(File)
        final file = io.File(picked.path);
        final metadata = SettableMetadata(
          contentType: contentType,
          customMetadata: {'userId': uid},
        );
        await ref.putFile(file, metadata);
        url = await ref.getDownloadURL();
      }

      // 상태 업데이트
      if (mounted) {
        setState(() {
          _currentProfileImageUrl = url;
          _uploadingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 이미지가 업데이트되었습니다.')),
        );
      }
    } catch (e) {
      setState(() => _uploadingImage = false);
      if (mounted) {
        // 에러 메시지를 화면에 표시
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('이미지 업로드 실패'),
              content: Text('이미지 업로드 에러: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );

        // 추가로 스낵바에도 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 업로드 에러: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      print('이미지 업로드 에러: $e');
    }
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('locals')
            .where('user_id', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    '로컬인 등록이 필요합니다',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '로컬인으로 활동하려면\n등록을 먼저 해주세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // 로컬인 인증 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocalAuthScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      '로컬인 등록하기',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          final data =
              snapshot.data!.docs.first.data() as Map<String, dynamic>?;
          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    '로컬인 등록이 필요합니다',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '로컬인으로 활동하려면\n등록을 먼저 해주세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // 로컬인 인증 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocalAuthScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      '로컬인 등록하기',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
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
            _schoolOrCompanyController.text = data['school_or_company'] ?? '';
            _languagesController.text =
                (data['languages'] as List<dynamic>?)?.join(', ') ?? '';
            _tagsController.text =
                (data['tags'] as List<dynamic>?)?.join(', ') ?? '';
            _personalInfoController.text = data['personal_info'] ?? '';
            _isGraduated = data['is_graduated'] ?? false;
            _currentProfileImageUrl = data['profile_image_url'] ?? '';
          }

          final verificationStatus = data['verification_status'] ?? 'pending';
          final certified = verificationStatus == 'accepted';
          final profileImageUrl = data['profile_image_url'] ?? '';
          final createdAt = data['created_at'] ?? '-';
          final updatedAt = data['updated_at'] ?? '-';
          final schoolOrCompany = data['school_or_company'] ?? '';
          final tags = (data['tags'] as List<dynamic>?)?.cast<String>() ?? [];
          final personalInfo = data['personal_info'] ?? '';
          final languages =
              (data['languages'] as List<dynamic>?)?.cast<String>() ?? [];
          final isGraduated = data['is_graduated'] ?? false;
          final matchCount = data['match_count']?.toString() ?? '0';
          final mannerScore = data['manner_score']?.toString() ?? '60.0';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 이미지
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _currentProfileImageUrl.isNotEmpty
                          ? CircleAvatar(
                              radius: 56,
                              backgroundImage:
                                  NetworkImage(_currentProfileImageUrl),
                              backgroundColor: const Color(0xFFEAE2F8),
                            )
                          : const CircleAvatar(
                              radius: 56,
                              backgroundColor: Color(0xFFEAE2F8),
                              child: Icon(
                                Icons.person,
                                size: 64,
                                color: Color(0xFF5F4B8B),
                              ),
                            ),
                      const SizedBox(height: 12),
                      if (_editing)
                        ElevatedButton(
                          onPressed: _uploadingImage
                              ? null
                              : () => _pickAndUploadImage(user.uid),
                          child: const Text('프로필 이미지 변경'),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

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
                        _buildInfoRow('학교/직장', schoolOrCompany),
                        _buildInfoRow('대학교 졸업', isGraduated ? '예' : '아니오'),
                        _buildInfoRow('가능언어',
                            languages.isNotEmpty ? languages.join(', ') : '-'),
                        _buildInfoRow(
                            '태그', tags.isNotEmpty ? tags.join(', ') : '-'),
                        _buildInfoRow('인적사항',
                            personalInfo.isNotEmpty ? personalInfo : '-'),
                        _buildInfoRow('매칭 횟수', matchCount),
                        _buildInfoRow('매너 온도', mannerScore),
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
                    onPressed: _loading || _uploadingImage
                        ? null
                        : () async {
                            if (!_editing) {
                              setState(() => _editing = true);
                              return;
                            }
                            setState(() => _loading = true);
                            try {
                              if (snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                // Firestore 업데이트
                                final updateData = {
                                  'nickname': _nicknameController.text.trim(),
                                  'age': int.tryParse(_ageController.text) ?? 0,
                                  'gender': _selectedGender,
                                  'preferred_meetup': _selectedMeetup,
                                  'preferred_location': _selectedLocation,
                                  'interests': _selectedInterests,
                                  'hobbies': _hobbiesController.text.trim(),
                                  'introduction':
                                      _introductionController.text.trim(),
                                  'updated_at':
                                      DateTime.now().toIso8601String(),
                                };

                                // 새 이미지가 있으면 추가
                                if (_currentProfileImageUrl.isNotEmpty) {
                                  updateData['profile_image_url'] =
                                      _currentProfileImageUrl;
                                }

                                await FirebaseFirestore.instance
                                    .collection('locals')
                                    .doc(snapshot.data!.docs.first.id)
                                    .update(updateData);

                                setState(() => _editing = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('프로필이 수정되었습니다.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('수정 실패: $e')),
                              );
                            } finally {
                              setState(() => _loading = false);
                            }
                          },
                    child: _loading || _uploadingImage
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _schoolOrCompanyController,
              decoration: const InputDecoration(
                labelText: '학교/직장',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
                hintText: '예: 연세대학교, 삼성전자 (선택사항)',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _isGraduated,
                  onChanged: (value) {
                    setState(() {
                      _isGraduated = value ?? false;
                    });
                  },
                ),
                const Text('대학교 졸업', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _languagesController,
              decoration: const InputDecoration(
                labelText: '가능언어',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
                hintText: '예: 비즈니스 영어, 아랍어, 스페인어 (쉼표로 구분)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: '태그',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
                hintText: '예: #친절한, #사진잘찍는, #맛집고수 (쉼표로 구분)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _personalInfoController,
              decoration: const InputDecoration(
                labelText: '인적사항',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
                hintText: '추가적인 개인 정보를 입력해주세요. (선택사항)',
              ),
              maxLines: 3,
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
