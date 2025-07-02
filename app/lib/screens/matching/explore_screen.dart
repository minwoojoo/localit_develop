import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('로컬 매칭 찾기', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
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
                child: Row(
                  children: [
                    _buildDropdown(sort, (val) => setState(() => sort = val)),
                    const SizedBox(width: 4),
                    _buildDropdown(
                        region, (val) => setState(() => region = val)),
                    const SizedBox(width: 4),
                    _buildDropdown(
                        keyword, (val) => setState(() => keyword = val)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(isCardView ? Icons.view_list : Icons.grid_view,
                          color: Colors.black),
                      onPressed: () {
                        setState(() {
                          isCardView = !isCardView;
                        });
                      },
                    ),
                  ],
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
          isCardView ? _buildTravelerPostsCard() : _buildTravelerPostsList(),
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

  // 리스트형 로컬인 게시글
  Widget _buildLocalPostsList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(radius: 28, backgroundColor: Colors.grey[300]),
          title:
              Text('서울윤순바다안에', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('서울대학교 입학사정관 10년차'),
              Row(
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text('신뢰도 100점',
                      style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
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

  // 카드형 로컬인 게시글
  Widget _buildLocalPostsCard() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                      radius: 32, backgroundColor: Colors.grey[300]),
                ),
                const SizedBox(height: 8),
                Text('두세배속8282', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('서울대학교 입학사정관 10년차', style: TextStyle(fontSize: 12)),
                Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text('신뢰도 100점',
                        style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('ON/OFF',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                    Icon(Icons.more_vert, size: 18),
                  ],
                ),
              ],
            ),
          ),
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
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                      radius: 32, backgroundColor: Colors.grey[300]),
                ),
                const SizedBox(height: 8),
                Text('두세배속8282', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('여행자 | 2024.03.20~03.25', style: TextStyle(fontSize: 12)),
                Text('서울에서 5박 6일 여행을 계획 중입니다.', style: TextStyle(fontSize: 12)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('ON/OFF',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                    Icon(Icons.more_vert, size: 18),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
