import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localit/screens/matching/explore_detail_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:localit/screens/matching/home_screen.dart';
import 'package:localit/screens/commerce/purchase_agency_screen.dart';
import 'package:localit/screens/chat/chat_screen.dart';
import 'package:localit/screens/community/community_home_screen.dart';
import 'package:localit/screens/common/menu_screen.dart';
import 'package:localit/screens/matching/traveler_input_screen.dart';
import 'package:localit/screens/matching/traveler_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isCardView = false;
  String sort = '추천순';
  String region = '지역별';
  String keyword = '키워드';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('로컬 매칭 찾기', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: const [
                  Tab(text: '로컬인의 게시글'),
                  Tab(text: '여행자의 게시글'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.star_border, color: Colors.black, size: 24),
                      const SizedBox(width: 8),
                      Icon(Icons.search, color: Colors.black, size: 24),
                      const SizedBox(width: 8),
                      _buildDropdown(sort, (val) => setState(() => sort = val)),
                      const SizedBox(width: 8),
                      _buildDropdown(
                          region, (val) => setState(() => region = val)),
                      const SizedBox(width: 8),
                      _buildDropdown(
                          keyword, (val) => setState(() => keyword = val)),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                              isCardView ? Icons.view_list : Icons.grid_view,
                              color: Colors.black),
                          onPressed: () {
                            setState(() {
                              isCardView = !isCardView;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          isCardView ? _buildLocalPostsCard() : _buildLocalPostsList(),
          _buildTravelerPostsCard(), // 여행자 게시글은 항상 카드 형태로 표시
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TravelerInputScreen(),
                  ),
                );
              },
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // 네비게이션 처리
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const PurchaseAgencyScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const CommunityHomeScreen()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MenuScreen()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: '구매대행',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send_outlined),
            label: '메시지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.all_inclusive),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '메뉴',
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, ValueChanged<String> onChanged) {
    return DropdownButton<String>(
      value: label,
      items: [label, '옵션1', '옵션2']
          .toSet()
          .map((e) => DropdownMenuItem(
              value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
          .toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
      underline: const SizedBox(),
      style: const TextStyle(color: Colors.black),
      icon: const Icon(Icons.arrow_drop_down, size: 18),
    );
  }

  Future<String?> getProfileImageUrl(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      print('DEBUG: Loading profile image for path: $path');
      final ref = FirebaseStorage.instance.ref().child(path);
      final url = await ref.getDownloadURL();
      print('DEBUG: Got URL: $url');
      return url;
    } catch (e) {
      print('DEBUG: Error loading profile image: $e');
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

  // 리스트형 로컬인 게시글
  Widget _buildLocalPostsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('locals').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('로컬인 게시글이 없습니다.'));
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final nickname = data['nickname'] ?? '';
            final schoolOrCompany = data['school_or_company'] ?? '';
            final languages = _convertToList<String>(data['languages']);
            final interests = _convertToList<String>(data['interests']);
            final isGraduated = data['is_graduated'] ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ExploreDetailScreen(localId: docs[index].id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // 프로필 이미지
                      FutureBuilder<String?>(
                        key: ValueKey(
                            'profile_${docs[index].id}_${data['profile_image_url']}'),
                        future: getProfileImageUrl(data['profile_image_url']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey,
                            );
                          }
                          final url = snapshot.data;
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: (url != null && url.isNotEmpty)
                                ? NetworkImage(url)
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: (url == null || url.isEmpty)
                                ? const Icon(Icons.person,
                                    color: Colors.white, size: 50)
                                : null,
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      // 텍스트 정보
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
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified,
                                    color: Colors.green, size: 18),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 4),
                            // 가능언어
                            if (languages.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.book,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      languages.join(' | '),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            // 관심분야
                            if (interests.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '관심분야',
                                    style: TextStyle(
                                      fontSize: 10,
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
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                interest,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.orange[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            // 대학교 졸업 배지
                            if (isGraduated) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '대학졸업',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 카드형 로컬인 게시글
  Widget _buildLocalPostsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('locals').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('로컬인 게시글이 없습니다.'));
        }
        final docs = snapshot.data!.docs;
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final nickname = data['nickname'] ?? '';
            final schoolOrCompany = data['school_or_company'] ?? '';
            final languages = _convertToList<String>(data['languages']);
            final interests = _convertToList<String>(data['interests']);
            final isGraduated = data['is_graduated'] ?? false;
            final mannerScore = data['manner_score'] ?? 60.0;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필 이미지
                    Center(
                      child: FutureBuilder<String?>(
                        key: ValueKey(
                            'profile_card_${docs[index].id}_${data['profile_image_url']}'),
                        future: getProfileImageUrl(data['profile_image_url']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey,
                            );
                          }
                          final url = snapshot.data;
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: (url != null && url.isNotEmpty)
                                ? NetworkImage(url)
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: (url == null || url.isEmpty)
                                ? const Icon(Icons.person,
                                    color: Colors.white, size: 50)
                                : null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 이름과 인증 마크
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nickname,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.verified,
                            color: Colors.green, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 학교/직장 정보
                    if (schoolOrCompany.isNotEmpty)
                      Text(
                        schoolOrCompany,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    // 가능언어
                    if (languages.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.book, size: 12, color: Colors.grey),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              languages.take(2).join(' | '),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const Spacer(),
                    // 관심분야
                    if (interests.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '관심분야',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: 2,
                            runSpacing: 2,
                            children: interests
                                .take(2)
                                .map((interest) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        interest,
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.orange[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    // 대학교 졸업 배지
                    if (isGraduated) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '대학졸업',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 리스트형 여행자 게시글
  Widget _buildTravelerPostsList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(radius: 28, backgroundColor: Colors.grey[300]),
          title:
              Text('두세배속8282', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('여행자 | 2024.03.20~03.25'),
              Text('서울에서 5박 6일 여행을 계획 중입니다.', style: TextStyle(fontSize: 12)),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ON/OFF',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Icon(Icons.more_vert, size: 18),
            ],
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      },
    );
  }

  // 카드형 여행자 게시글
  Widget _buildTravelerPostsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('travelers_post').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('여행자 게시글이 없습니다.'));
        }
        final docs = snapshot.data!.docs;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final nickname = data['nickname'] ?? '여행자';
            final age = data['age'] ?? '';
            final nationality = data['nationality'] ?? '';
            final gender = data['gender'] ?? '';
            final visitSchedule = data['visit_schedule'] ?? '';
            final description = data['description'] ?? '';
            final matchingMethod = data['matching_method'] ?? '';
            final createdAt = data['created_at'] as Timestamp?;

            // 날짜 포맷팅
            String formattedDate = '';
            if (createdAt != null) {
              final date = createdAt.toDate();
              formattedDate =
                  '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
            }

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TravelerDetailScreen(
                        travelerPostId: docs[index].id,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단: 프로필 이미지와 매칭 방식
                      Row(
                        children: [
                          // 프로필 이미지
                          FutureBuilder<String?>(
                            future:
                                getProfileImageUrl(data['profile_image_url']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.person,
                                      color: Colors.white, size: 40),
                                );
                              }
                              final url = snapshot.data;
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: (url != null && url.isNotEmpty)
                                      ? DecorationImage(
                                          image: NetworkImage(url),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: (url == null || url.isEmpty)
                                      ? Colors.grey[300]
                                      : null,
                                ),
                                child: (url == null || url.isEmpty)
                                    ? const Icon(Icons.person,
                                        color: Colors.white, size: 40)
                                    : null,
                              );
                            },
                          ),
                          const Spacer(),
                          // 매칭 방식 태그
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              matchingMethod,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 닉네임
                      Text(
                        nickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // 나이, 국적, 성별 (사람 아이콘)
                      if (age.isNotEmpty &&
                          nationality.isNotEmpty &&
                          gender.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.person,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${age}세 | $nationality | ${gender == '남' ? '남자' : '여자'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),

                      // 위치 정보 (위치 아이콘)
                      if (data['accommodation_info'] != null &&
                          data['accommodation_info'].toString().isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                data['accommodation_info'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),

                      // 해시태그 (북마크 아이콘)
                      if (data['hashtags'] != null &&
                          (data['hashtags'] as List).isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.bookmark,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                (data['hashtags'] as List).take(3).join(' | '),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
