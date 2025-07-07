import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🌏 ${data['title'] ?? '로컬인 소개'}에 두고 싶으신가요?',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: (data['profileImageUrl'] != null &&
                              (data['profileImageUrl'] as String).isNotEmpty)
                          ? NetworkImage(data['profileImageUrl'])
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: (data['profileImageUrl'] == null ||
                              (data['profileImageUrl'] as String).isEmpty)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(data['nickname'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              const SizedBox(width: 6),
                              Icon(Icons.verified,
                                  color: Colors.green, size: 18),
                            ],
                          ),
                          Text(data['intro'] ?? '',
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(data['tag'] ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                Text('회원 정보',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _infoRow('희망 지역', data['preferred_location'] ?? ''),
                _infoRow('매칭 방식', meetupTypeText(data['preferred_meetup'])),
                _infoRow('매칭 횟수', data['matching_count']?.toString() ?? ''),
                _infoRow('인적 사항', data['personal_info'] ?? ''),
                _infoRow('매너 온도', data['manner_temp'] ?? ''),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (data['hashtags'] as List<dynamic>? ?? [])
                      .map((tag) => Chip(label: Text('#$tag')))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text(data['introduction'] ?? '',
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('더보기'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('요청하기'),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
