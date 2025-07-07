import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'package:localit/screens/setting/profile_detail_screen.dart';
import 'package:localit/screens/setting/local_profile.dart';
import 'package:localit/screens/auth/local_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 로그인 정보가 없으면 로그인 화면으로 이동
      Future.microtask(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 설정 화면으로 이동
            },
          ),
        ],
      ),
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
          final nickname = data['nickname'] ?? '닉네임 없음';
          final email = data['email'] ?? user.email ?? '이메일 없음';
          final profileImageUrl = data['profileImageUrl'] ?? '';
          final trustScore = data['trust_score']?.toString() ?? '-';

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('locals')
                .doc(user.uid)
                .snapshots(),
            builder: (context, localSnapshot) {
              final isLocalRegistered =
                  localSnapshot.hasData && localSnapshot.data?.exists == true;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // 프로필 정보
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          profileImageUrl.isNotEmpty
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      NetworkImage(profileImageUrl),
                                )
                              : const CircleAvatar(
                                  radius: 50,
                                  child: Icon(Icons.person, size: 50),
                                ),
                          const SizedBox(height: 16),
                          Text(
                            nickname,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            email,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.workspace_premium,
                                  color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                '신뢰도: $trustScore',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 로컬인 섹션
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LocalProfileScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                '로컬인 프로필',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: isLocalRegistered
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      // 로컬인 등록 해제: locals 컬렉션에서 문서 삭제
                                      await FirebaseFirestore.instance
                                          .collection('locals')
                                          .doc(user.uid)
                                          .delete();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('로컬인 등록이 해제되었습니다.')),
                                      );
                                    },
                                    child: const Text(
                                      '로컬인 등록 해제',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LocalAuthScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      '로컬인 등록',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // 메뉴 리스트
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildMenuItem(
                          icon: Icons.article,
                          title: '내가 작성한 게시글',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.request_page,
                          title: '받은 요청',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.rate_review,
                          title: '후기 관리',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.workspace_premium,
                          title: '뱃지 / 신뢰도',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.history,
                          title: '활동 내역',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.payment,
                          title: '결제 내역',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: '고객센터',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // 프로필 상세보기 버튼
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProfileDetailScreen(),
                              ),
                            );
                          },
                          child: const Text('프로필 상세보기',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 로그아웃 버튼
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          child: const Text('로그아웃',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
