import 'package:flutter/material.dart';
import 'package:localit/screens/auth/profile_screen.dart';
import 'package:localit/screens/matching/explore_screen.dart';
import 'package:localit/screens/commerce/purchase_agency_screen.dart';
import 'package:localit/screens/community/community_home_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 메뉴'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: '프로필',
            items: [
              _buildMenuItem(
                icon: Icons.person,
                title: '프로필',
                subtitle: '프로필 보기',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: '서비스',
            items: [
              _buildMenuItem(
                icon: Icons.people,
                title: '로컬 매칭',
                subtitle: '현지인과 함께하는 여행',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExploreScreen()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.shopping_cart,
                title: '구매대행',
                subtitle: '현지 상품 구매 대행',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PurchaseAgencyScreen()),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: '커뮤니티',
            items: [
              _buildMenuItem(
                icon: Icons.forum,
                title: '여행 후기',
                subtitle: '여행 경험 공유',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CommunityHomeScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items,
        const Divider(),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
