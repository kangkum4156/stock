import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StockPriceControl extends StatefulWidget {
  // 부모(StockBody)에게 설정된 값을 전달할 콜백 함수
  final Function(RangeValues) onApply;

  const StockPriceControl({
    super.key,
    required this.onApply,
  });

  @override
  State<StockPriceControl> createState() => _StockPriceControlState();
}

class _StockPriceControlState extends State<StockPriceControl> {
  // 슬라이더 설정 상수
  static const double _min = 0;
  static const double _max = 300000;
  static const int _step = 10000; // 1만 원 단위

  // 현재 슬라이더 상태 (화면 표시용)
  RangeValues _currentRangeValues = const RangeValues(_min, _max);

  // 숫자 포맷팅 (10,000)
  String formatNum(double value) {
    return NumberFormat('#,###').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.transparent, // 배경 투명
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. 가격 범위 슬라이더 및 텍스트 (왼쪽 영역)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 현재 범위 텍스트
                Text(
                  '${formatNum(_currentRangeValues.start)}원 ~ ${formatNum(_currentRangeValues.end)}원',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.0, // [수정] 텍스트 위아래 기본 여백(줄간격) 제거
                  ),
                ),

                // [수정] SizedBox로 슬라이더 높이를 강제로 24px로 제한 (간격 축소)
                SizedBox(
                  height: 24,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      activeTrackColor: Colors.black,
                      thumbColor: Colors.black,
                      valueIndicatorColor: Colors.black,

                      // [수정] 높이를 줄였으므로 터치 물결(Overlay) 크기도 줄여야 안 잘림
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      overlayColor: Colors.black.withOpacity(0.2),

                      // 썸(손잡이) 크기 설정 (기본값 유지 또는 조절 가능)
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: RangeSlider(
                      values: _currentRangeValues,
                      min: _min,
                      max: _max,
                      divisions: (_max / _step).round(),
                      labels: RangeLabels(
                        formatNum(_currentRangeValues.start),
                        formatNum(_currentRangeValues.end),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _currentRangeValues = values;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12), // 슬라이더와 버튼 사이 간격

          // 2. 설정 버튼 (오른쪽)
          ElevatedButton(
            onPressed: () {
              // 버튼을 누르면 부모에게 현재 슬라이더 값을 전달
              widget.onApply(_currentRangeValues);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              // 버튼 높이를 슬림하게 줄이고 싶다면 아래 visualDensity 추가 가능
              // visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('설정', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}