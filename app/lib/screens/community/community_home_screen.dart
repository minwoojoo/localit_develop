import 'package:flutter/material.dart';
import 'post_detail_screen.dart';
import 'post_write_screen.dart';
import 'package:localit/screens/matching/home_screen.dart';
import 'package:localit/screens/commerce/purchase_agency_screen.dart';
import 'package:localit/screens/chat/chat_screen.dart';
import 'package:localit/screens/common/menu_screen.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  int _selectedIndex = 3; // 커뮤니티 탭이 선택된 상태

  @override
  Widget build(BuildContext context) {
    // 샘플 게시글 데이터
    final List<Map<String, String>> posts = [
      {'title': '제주도 여행 후기', 'author': '홍길동', 'content': '제주도 너무 좋아요! 추천합니다.'},
      {'title': '부산 맛집 추천', 'author': '김철수', 'content': '부산에 이런 맛집이!'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
      ),
      body: ListView.separated(
        itemCount: posts.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            title: Text(post['title'] ?? ''),
            subtitle: Text('작성자: ${post['author'] ?? ''}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: post),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostWriteScreen(),
            ),
          );
        },
        child: const Icon(Icons.edit),
      ),
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
              // 현재 화면이므로 아무것도 하지 않음
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
}
