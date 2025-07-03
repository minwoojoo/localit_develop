import 'package:flutter/material.dart';
import 'post_detail_screen.dart';
import 'post_write_screen.dart';

class CommunityHomeScreen extends StatelessWidget {
  const CommunityHomeScreen({super.key});

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
    );
  }
}
