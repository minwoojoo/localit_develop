import 'package:flutter/material.dart';

class PurchaseAgencyScreen extends StatefulWidget {
  const PurchaseAgencyScreen({super.key});

  @override
  State<PurchaseAgencyScreen> createState() => _PurchaseAgencyScreenState();
}

class _PurchaseAgencyScreenState extends State<PurchaseAgencyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '예약 구매 대행',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 탭바
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: '예약 대행'),
                Tab(text: '구매 대행'),
              ],
            ),
          ),

          // 필터 및 정렬 버튼들
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // 즐겨찾기 버튼
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.star_border, size: 20),
                    onPressed: () {},
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 검색 버튼
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, size: 20),
                    onPressed: () {},
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 추천순 드롭다운
                Expanded(child: _buildDropdown('추천순')),
                const SizedBox(width: 8),

                // 지역별 드롭다운
                Expanded(child: _buildDropdown('지역별')),
                const SizedBox(width: 8),

                // 키워드 드롭다운
                Expanded(child: _buildDropdown('키워드')),
              ],
            ),
          ),

          // 상품 목록
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 예약 대행 탭
                _buildReservationAgencyTab(),

                // 구매 대행 탭
                _buildPurchaseAgencyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationAgencyTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Image.asset(
          'assets/reservation_agency.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildPurchaseAgencyTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Image.asset(
          'assets/purchase_agency.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
    );
  }
}
