import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

class LocalRegistrationScreen extends StatefulWidget {
  const LocalRegistrationScreen({super.key});

  @override
  State<LocalRegistrationScreen> createState() =>
      _LocalRegistrationScreenState();
}

class _LocalRegistrationScreenState extends State<LocalRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _introductionController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _schoolOrCompanyController = TextEditingController();
  final _personalInfoController = TextEditingController();
  final _tagsController = TextEditingController();
  final _languagesController = TextEditingController();
  String _selectedGender = '남';
  String _selectedMeetup = '오프';
  String _selectedLocation = 'Hongdae';
  bool _isGraduated = false;
  List<String> _selectedInterests = [];
  bool _isLoading = false;
  String? _profileImageUrl;

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
    _ageController.dispose();
    _hobbiesController.dispose();
    _introductionController.dispose();
    _nicknameController.dispose();
    _schoolOrCompanyController.dispose();
    _personalInfoController.dispose();
    _tagsController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(String uid) async {
    try {
      setState(() => _isLoading = true);
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) {
        setState(() => _isLoading = false);
        return;
      }
      final ref =
          FirebaseStorage.instance.ref().child('local_profile_images/$uid.jpg');
      String url;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': uid, 'type': 'local_profile'},
        );
        await ref.putData(bytes, metadata);
        url = await ref.getDownloadURL();
      } else {
        final file = io.File(picked.path);
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': uid, 'type': 'local_profile'},
        );
        await ref.putFile(file, metadata);
        url = await ref.getDownloadURL();
      }
      if (mounted) {
        setState(() {
          _profileImageUrl = url;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로컬인 프로필 이미지가 업로드되었습니다.')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 업로드 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      print('DEBUG: Current user.uid = ${user.uid}');
      print('DEBUG: Current user.email = ${user.email}');
      print('DEBUG: Current user.phoneNumber = ${user.phoneNumber}');

      // users 컬렉션에서 사용자 정보 확인
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      print('DEBUG: User document exists = ${userDoc.exists}');
      print('DEBUG: User document ID = ${userDoc.id}');

      if (!userDoc.exists) {
        throw Exception('사용자 정보를 찾을 수 없습니다. 먼저 회원가입을 완료해주세요.');
      }

      final userData = userDoc.data();
      print('DEBUG: User data = $userData');

      if (userData == null) {
        throw Exception('사용자 데이터를 불러올 수 없습니다.');
      }

      // users 컬렉션의 phone_verified 필드 확인 (모의 인증이므로 항상 true로 간주)
      final phoneVerified = true; // 모의 인증이므로 항상 true
      print('DEBUG: phone_verified = $phoneVerified');

      // 기존 사용자의 user_id 사용 (없으면 현재 uid 사용)
      final actualUserId = userData['user_id'] ?? user.uid;
      print('DEBUG: actualUserId = $actualUserId');

      // 기존 로컬인 등록 확인
      final existingLocal = await FirebaseFirestore.instance
          .collection('locals')
          .where('user_id', isEqualTo: actualUserId)
          .get();

      if (existingLocal.docs.isNotEmpty) {
        throw Exception('이미 로컬인으로 등록되어 있습니다.');
      }

      final localData = {
        'user_id': actualUserId, // 실제 사용자의 user_id 사용
        'nickname': _nicknameController.text.trim(),
        'certified': true,
        'age': int.parse(_ageController.text),
        'gender': _selectedGender,
        'profile_image_url': _profileImageUrl ?? '',
        'preferred_meetup': _selectedMeetup,
        'preferred_location': _selectedLocation,
        'interests': _selectedInterests,
        'hobbies': _hobbiesController.text.trim(),
        'introduction': _introductionController.text.trim(),
        'verification_status': 'approved',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'phone_number':
            userData['phone_number'] ?? '01012345678', // 사용자 데이터에서 가져오거나 모의 번호
        'manner_score': 60.0, // 매너 온도 기본값 60
        'school_or_company': _schoolOrCompanyController.text.trim(),
        'match_count': 0, // 매칭 횟수 기본값 0
        'tags': _tagsController.text.trim().isNotEmpty
            ? _tagsController.text
                .trim()
                .split(',')
                .map((tag) => tag.trim())
                .toList()
            : [],
        'personal_info': _personalInfoController.text.trim(),
        'languages': _languagesController.text.trim().isNotEmpty
            ? _languagesController.text
                .trim()
                .split(',')
                .map((lang) => lang.trim())
                .toList()
            : [],
        'is_graduated': _isGraduated,
      };

      // locals 컬렉션에 새 문서 생성
      await FirebaseFirestore.instance.collection('locals').add(localData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로컬인 등록이 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('등록 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        title: const Text('로컬인 정보 입력'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 닉네임 입력
              const Text(
                '닉네임(별명)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: '예: 홍길동, SeoulGuy, 여행왕',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '닉네임을 입력해주세요';
                  }
                  if (value.length < 2 || value.length > 12) {
                    return '닉네임은 2~12자 이내여야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 프로필 이미지
              const Text(
                '프로필 이미지',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? CircleAvatar(
                            radius: 56,
                            backgroundImage: NetworkImage(_profileImageUrl!),
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
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _pickAndUploadImage(user.uid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                            ? '프로필 이미지 변경'
                            : '프로필 이미지 선택',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
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

              // 나이
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: '나이',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '나이를 입력해주세요';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 18 || age > 100) {
                    return '올바른 나이를 입력해주세요 (18-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 성별
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
              const SizedBox(height: 16),

              // 선호 만남 방식
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
              const SizedBox(height: 16),

              // 선호 지역
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

              // 관심 분야 (다중 선택)
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
              const SizedBox(height: 16),

              // 취미
              TextFormField(
                controller: _hobbiesController,
                decoration: const InputDecoration(
                  labelText: '취미',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports_esports),
                  hintText: '예: 등산, 사진, 요리',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '취미를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 자기소개
              const Text(
                '자기소개',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _introductionController,
                decoration: const InputDecoration(
                  labelText: '자기소개',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_pin),
                  hintText: '여행자들에게 자신을 소개해주세요. (선택사항)',
                ),
                maxLines: 4,
                validator: (value) {
                  // 자기소개는 선택사항이므로 검증하지 않음
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 학교/직장 정보
              const Text(
                '학교/직장 정보',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schoolOrCompanyController,
                decoration: const InputDecoration(
                  labelText: '학교 또는 직장',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                  hintText: '예: 연세대학교, 삼성전자 (선택사항)',
                ),
                validator: (value) {
                  // 선택사항이므로 검증하지 않음
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 태그
              const Text(
                '태그',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: '태그',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                  hintText: '예: 친절한, 사진잘찍는, 맛집고수 (쉼표로 구분)',
                ),
                validator: (value) {
                  // 선택사항이므로 검증하지 않음
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 인적사항
              const Text(
                '인적사항',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _personalInfoController,
                decoration: const InputDecoration(
                  labelText: '인적사항',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                  hintText: '추가적인 개인 정보를 입력해주세요. (선택사항)',
                ),
                maxLines: 3,
                validator: (value) {
                  // 선택사항이므로 검증하지 않음
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 가능언어
              const Text(
                '가능언어',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _languagesController,
                decoration: const InputDecoration(
                  labelText: '구사 가능한 언어',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                  hintText: '예: 비즈니스 영어, 아랍어, 스페인어 (쉼표로 구분)',
                ),
                validator: (value) {
                  // 선택사항이므로 검증하지 않음
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 대학교 졸업 여부
              const Text(
                '학력 정보',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isGraduated,
                      onChanged: (value) {
                        setState(() {
                          _isGraduated = value ?? false;
                        });
                      },
                    ),
                    const Text(
                      '대학교 졸업',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 등록 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          '로컬인 등록하기',
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
        ),
      ),
    );
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
