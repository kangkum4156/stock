import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoticeCardDetail extends StatelessWidget {
  final String title;
  final String content;
  final DateTime createdAt;

  const NoticeCardDetail({
    super.key,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    // 날짜 포맷
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

    return Scaffold(
      // 상단 앱바 (뒤로가기 버튼 자동 생성됨)
      appBar: AppBar(
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 제목 영역
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // 2. 날짜 영역
            Text(
              '작성일: $dateStr',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const Divider(height: 40, thickness: 1), // 구분선

            // 3. 본문 내용 영역
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6, // 줄간격 살짝 넓게
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}