import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StockCard extends StatelessWidget {
  final String name;
  final num firstStartPrice;
  final num firstRatio;
  final num firstEndPrice;
  final num secondStartPrice;
  final num secondRatio;
  final num secondEndPrice;
  final num sellPrice; // 판매가 변수

  const StockCard({
    super.key,
    required this.name,
    required this.firstStartPrice,
    required this.firstRatio,
    required this.firstEndPrice,
    required this.secondStartPrice,
    required this.secondRatio,
    required this.secondEndPrice,
    required this.sellPrice,
  });

  // 숫자 포맷팅 (1,000)
  String formatNum(num value) {
    return NumberFormat('#,###').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [상단] 종목 이름
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(thickness: 1, height: 24),

            // [중단] 1차 정보
            _buildInfoRow('1차', firstStartPrice, firstRatio, firstEndPrice),

            const SizedBox(height: 12),

            // [하단] 2차 정보
            _buildInfoRow('2차', secondStartPrice, secondRatio, secondEndPrice),

            const SizedBox(height: 16), // 간격 좀 더 띄움

            // [NEW] 판매가 정보 (하나의 Row로 구성)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50], // 살짝 강조된 배경색
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '판매가',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87
                    ),
                  ),
                  Text(
                    formatNum(sellPrice),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent // 파란색으로 강조
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 정보 한 줄을 만드는 위젯 (기존 코드 유지)
  Widget _buildInfoRow(String label, num start, num ratio, num end) {
    return Row(
      children: [
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildValueColumn('시작가', formatNum(start)),
              _buildValueColumn('비율', '$ratio%'),
              _buildValueColumn('종료가', formatNum(end)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueColumn(String subLabel, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          subLabel,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}