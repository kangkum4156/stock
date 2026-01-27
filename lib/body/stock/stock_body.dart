import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_inv/body/stock/stock_card.dart';
import 'package:stock_inv/body/stock/stock_price_control.dart'; // 컨트롤 파일 임포트

class StockBody extends StatefulWidget {
  const StockBody({super.key});

  @override
  State<StockBody> createState() => _StockBodyState();
}

class _StockBodyState extends State<StockBody> {
  // 실제 필터링에 적용될 범위 (기본값: 전체)
  RangeValues _filterRange = const RangeValues(0, 300000);

  // 컨트롤러에서 [설정] 버튼을 눌렀을 때 호출되는 함수
  void _onFilterApplied(RangeValues newRange) {
    setState(() {
      _filterRange = newRange;
    });

    // 사용자 피드백 (선택사항)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('가격 필터가 적용되었습니다.'),
        duration: Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---------------------------------------------------------
        // 1. 상단 컨트롤 영역 (별도 파일로 분리된 위젯 사용)
        // ---------------------------------------------------------
        StockPriceControl(
          onApply: _onFilterApplied, // 콜백 함수 전달
        ),

        const Divider(height: 1, thickness: 1),

        // ---------------------------------------------------------
        // 2. 리스트 영역 (Expanded로 남은 공간 채움)
        // ---------------------------------------------------------
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('stock').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('데이터 로드 오류: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              final now = DateTime.now();

              // [필터링 로직]
              final filteredDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;

                // (1) 100시간 이내 업데이트 체크**
                if (!data.containsKey('lastUpdated') || data['lastUpdated'] == null) {
                  return false;
                }
                Timestamp timestamp = data['lastUpdated'];
                if (now.difference(timestamp.toDate()).inHours > 100) {
                  return false; // 100시간 지남
                }

                // (2) 가격 범위 체크 (1stStartPrice 기준)
                num startPrice = data['1stStartPrice'] ?? 0;

                // 설정된 최소값보다 작거나, 최대값보다 크면 제외
                if (startPrice < _filterRange.start || startPrice > _filterRange.end) {
                  return false;
                }

                return true; // 조건 통과
              }).toList();

              if (filteredDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.filter_alt_off, size: 50, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        '조건에 맞는 종목이 없습니다.\n(${_filterRange.start.toInt()}원 ~ ${_filterRange.end.toInt()}원)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return StockCard(
                    name: data['name'] ?? '이름 없음',
                    firstStartPrice: data['1stStartPrice'] ?? 0,
                    firstRatio:      data['1stRatio'] ?? 0,
                    firstEndPrice:   data['1stEndPrice'] ?? 0,
                    secondStartPrice: data['2ndStartPrice'] ?? 0,
                    secondRatio:      data['2ndRatio'] ?? 0,
                    secondEndPrice:   data['2ndEndPrice'] ?? 0,
                    sellPrice:        data['sellPrice'] ?? 0,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}