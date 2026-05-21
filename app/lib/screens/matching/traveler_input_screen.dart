import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

class TravelerInputScreen extends StatefulWidget {
  const TravelerInputScreen({super.key});

  @override
  State<TravelerInputScreen> createState() => _TravelerInputScreenState();
}

class _TravelerInputScreenState extends State<TravelerInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _ageController = TextEditingController();
  final _accommodationInfoController = TextEditingController();
  final _visitScheduleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedGender = '남';
  String _selectedNationality = '한국인';
  String _selectedMatchingMethod = 'ON';
  List<String> _selectedHashtags = [];
  bool _isLoading = false;
  String? _profileImageUrl;

  final List<String> _genderOptions = ['남', '여'];
  final List<String> _nationalityOptions = [
    '한국인',
    '미국인',
    '일본인',
    '중국인',
    '영국인',
    '프랑스인',
    '독일인',
    '호주인',
    '캐나다인',
    '기타'
  ];
  final List<String> _matchingMethodOptions = ['ON', 'OFF', 'ON/OFF'];
  final List<String> _hashtagOptions = [
    '야구',
    '세계사',
    '여행',
    '전시회 관람',
    '음식',
    '문화',
    '쇼핑',
    '자연',
    '역사',
    '예술',
    '음악',
    '스포츠',
    '기술',
    '사진',
    '모험'
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    _ageController.dispose();
    _accommodationInfoController.dispose();
    _visitScheduleController.dispose();
    _descriptionController.dispose();
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
      final ref = FirebaseStorage.instance
          .ref()
          .child('traveler_profile_images/$uid.jpg');
      String url;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': uid, 'type': 'traveler_profile'},
        );
        await ref.putData(bytes, metadata);
        url = await ref.getDownloadURL();
      } else {
        final file = io.File(picked.path);
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': uid, 'type': 'traveler_profile'},
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
          const SnackBar(content: Text('여행자 프로필 이미지가 업로드되었습니다.')),
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

      // users 컬렉션에서 사용자 정보 확인
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('사용자 정보를 찾을 수 없습니다. 먼저 회원가입을 완료해주세요.');
      }

      final userData = userDoc.data();
      if (userData == null) {
        throw Exception('사용자 데이터를 불러올 수 없습니다.');
      }

      final travelerData = {
        'user_id': user.uid,
        'nickname': _nicknameController.text.trim(),
        'age': _ageController.text.trim(),
        'nationality': _selectedNationality,
        'gender': _selectedGender,
        'accommodation_info': _accommodationInfoController.text.trim(),
        'matching_method': _selectedMatchingMethod,
        'visit_schedule': _visitScheduleController.text.trim(),
        'hashtags': _selectedHashtags,
        'description': _descriptionController.text.trim(),
        'profile_image_url': _profileImageUrl ?? '',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'status': 'active', // active, completed, cancelled
        'view_count': 0,
        'like_count': 0,
        'matching_count': 0, // 누적매칭횟수 기본값
      };

      // travelers_post 컬렉션에 새 문서 생성
      await FirebaseFirestore.instance
          .collection('travelers_post')
          .add(travelerData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('여행자 게시글이 등록되었습니다!'),
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
        title: const Text('여행자 게시글 작성'),
        backgroundColor: Colors.blue,
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
                '닉네임',
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
                  hintText: '예: 여행자123, SeoulExplorer',
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
                            backgroundColor: const Color(0xFFE3F2FD),
                          )
                        : const CircleAvatar(
                            radius: 56,
                            backgroundColor: Color(0xFFE3F2FD),
                            child: Icon(
                              Icons.person,
                              size: 64,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _pickAndUploadImage(user.uid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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

              // 여행 정보
              const Text(
                '여행 정보',
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
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: '예: 23',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '나이를 입력해주세요';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 1 || age > 120) {
                    return '올바른 나이를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 국적
              DropdownButtonFormField<String>(
                value: _selectedNationality,
                decoration: const InputDecoration(
                  labelText: '국적',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: _nationalityOptions.map((nationality) {
                  return DropdownMenuItem(
                    value: nationality,
                    child: Text(nationality),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedNationality = value!);
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

              // 숙소 정보
              TextFormField(
                controller: _accommodationInfoController,
                decoration: const InputDecoration(
                  labelText: '숙소 정보',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.hotel),
                  hintText: '예: 서울특별시 마포구 | 상암동 H호텔',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '숙소 정보를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 매칭 방식
              DropdownButtonFormField<String>(
                value: _selectedMatchingMethod,
                decoration: const InputDecoration(
                  labelText: '매칭 방식',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.connect_without_contact),
                ),
                items: _matchingMethodOptions.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedMatchingMethod = value!);
                },
              ),
              const SizedBox(height: 16),

              // 방문 일정
              TextFormField(
                controller: _visitScheduleController,
                decoration: const InputDecoration(
                  labelText: '방문 일정',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: '예: 2025.05.19 ~ 2025.06.21',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '방문 일정을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 관심 해시태그
              const Text(
                '관심 해시태그',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 해시태그 (다중 선택)
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
                children: _hashtagOptions.map((hashtag) {
                  final isSelected = _selectedHashtags.contains(hashtag);
                  return FilterChip(
                    label: Text('#$hashtag'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedHashtags.add(hashtag);
                        } else {
                          _selectedHashtags.remove(hashtag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 여행 자기소개
              const Text(
                '여행 자기소개',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '여행 계획 및 자기소개',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: '여행 계획이나 원하는 활동에 대해 설명해주세요.',
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '여행 자기소개를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 등록 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          '여행자 게시글 등록하기',
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
}
