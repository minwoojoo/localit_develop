import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final Map<String, String> post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 상세'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post['title'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('작성자: ${post['author'] ?? ''}',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const Divider(height: 32),
            Text(post['content'] ?? '', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
