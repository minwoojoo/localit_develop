import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

const List<String> regionOptions = [
  '서울',
  '경기',
  '인천',
  '강원',
  '대전/세종',
  '충남',
  '충북',
  '대구',
  '경북',
  '부산',
  '울산',
  '경남',
  '광주',
  '전남',
  '전북',
  '제주',
];
const List<String> languageOptions = ['한국어', '영어', '일본어'];

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _travelStyleController = TextEditingController();
  bool _editing = false;
  bool _loading = false;
  List<String> _preferredRegions = [];
  String? _selectedLanguage;
  String? _profileImageUrl;

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    _travelStyleController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(String uid) async {
    try {
      setState(() => _loading = true);

      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (picked == null) {
        setState(() => _loading = false);
        return;
      }

      // 로딩 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 업로드 중입니다...')),
        );
      }

      final ref =
          FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
      String url;

      if (kIsWeb) {
        // 웹: putData(Uint8List)
        final bytes = await picked.readAsBytes();
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': uid},
        );
        await ref.putData(bytes, metadata);
        url = await ref.getDownloadURL();
      } else {
        // 모바일: putFile(File)
        final file = io.File(picked.path);
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': uid},
        );
        await ref.putFile(file, metadata);
        url = await ref.getDownloadURL();
      }

      // Firestore 업데이트
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileImageUrl': url,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 상태 업데이트
      if (mounted) {
        setState(() {
          _profileImageUrl = url;
          _loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 이미지가 업데이트되었습니다.')),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 업로드 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('이미지 업로드 에러: $e');
    }
  }

  Future<void> _addRegion(String region) async {
    if (!_preferredRegions.contains(region)) {
      setState(() => _preferredRegions.add(region));
    }
  }

  void _removeRegion(String region) {
    setState(() => _preferredRegions.remove(region));
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
      appBar: AppBar(title: const Text('프로필 상세보기')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text('프로필 정보를 불러올 수 없습니다.'));
          }

          // 최초 진입 또는 저장 후 컨트롤러/리스트 초기화
          if (!_editing || _loading) {
            _nicknameController.text = data['nickname'] ?? '';
            _phoneController.text = data['phone_number'] ?? '';
            _travelStyleController.text = (data['travel_style'] is List &&
                    (data['travel_style'] as List).isNotEmpty)
                ? (data['travel_style'] as List).join(', ')
                : '';
            _preferredRegions = (data['preferred_regions'] is List)
                ? List<String>.from(data['preferred_regions'])
                : [];
            final langs = (data['languages'] is List &&
                    (data['languages'] as List).isNotEmpty)
                ? List<String>.from(data['languages'])
                : [];
            _selectedLanguage = langs.isNotEmpty ? langs.first : null;
            _profileImageUrl = data['profileImageUrl'] ?? null;
          }

          final email = data['email'] ?? '';
          final type = data['type'] ?? '';
          final trustScore = data['trust_score']?.toString() ?? '';

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // 상단 프로필 아바타 (이미지 or 기본)
              Column(
                children: [
                  const SizedBox(height: 24),
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
                  if (_editing)
                    ElevatedButton(
                      onPressed: () => _pickAndUploadImage(user.uid),
                      child: const Text('프로필 이미지 변경'),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
              _readonlyField('계정(이메일)', email),
              _readonlyField('타입', type),
              _readonlyField('신뢰도', trustScore),
              _editableField('별명', _nicknameController, enabled: _editing),
              _editableField('전화번호', _phoneController, enabled: _editing),
              // 선호지역 드롭다운 + Chip
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('선호지역',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _preferredRegions
                          .map((region) => Chip(
                                label: Text(region),
                                deleteIcon: _editing
                                    ? const Icon(Icons.close, size: 18)
                                    : null,
                                onDeleted: _editing
                                    ? () => _removeRegion(region)
                                    : null,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    if (_editing)
                      DropdownButton<String>(
                        value: null,
                        hint: const Text('지역 선택'),
                        items: regionOptions
                            .where((r) => !_preferredRegions.contains(r))
                            .map((region) => DropdownMenuItem(
                                  value: region,
                                  child: Text(region),
                                ))
                            .toList(),
                        onChanged: (region) {
                          if (region != null) {
                            _addRegion(region);
                          }
                        },
                      ),
                  ],
                ),
              ),
              _editableField('선호여행스타일', _travelStyleController,
                  hint: '여러 개는 쉼표로 구분', enabled: _editing),
              // 언어 드롭다운 (단일 선택)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('언어',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      hint: const Text('언어 선택'),
                      items: languageOptions
                          .map((lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ))
                          .toList(),
                      onChanged: _editing
                          ? (lang) {
                              setState(() {
                                _selectedLanguage = lang;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
                                .collection('users')
                                .doc(user.uid)
                                .update({
                              'nickname': _nicknameController.text.trim(),
                              'phone_number': _phoneController.text.trim(),
                              'preferred_regions': _preferredRegions,
                              'travel_style':
                                  _travelStyleController.text.trim().isNotEmpty
                                      ? _travelStyleController.text
                                          .trim()
                                          .split(',')
                                          .map((e) => e.trim())
                                          .toList()
                                      : [],
                              'languages': _selectedLanguage != null
                                  ? [_selectedLanguage!]
                                  : [],
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
          );
        },
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _editableField(String label, TextEditingController controller,
      {String? hint, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
