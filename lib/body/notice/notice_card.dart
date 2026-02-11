import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_inv/body/notice/notice_card_detail.dart'; // 상세 페이지 임포트

class NoticeCard extends StatelessWidget {
  final String title;
  final String content; // 내용은 여기서 안 보여줘도, 디테일 페이지로 넘겨야 하므로 받아야 함
  final DateTime createdAt;

  const NoticeCard({
    super.key,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      // [수정] 클릭 이벤트를 위해 InkWell 혹은 ListTile의 onTap 사용
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          // [핵심] 클릭 시 상세 페이지로 이동하며 데이터 전달
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoticeCardDetail(
                title: title,
                content: content,
                createdAt: createdAt,
              ),
            ),
          );
        },
        leading: const CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.notifications_outlined, color: Colors.white),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        // [수정] subtitle에는 날짜만 표시 (content 제거됨)
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            dateStr,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        // 우측에 화살표 아이콘 추가하여 클릭 가능함을 암시
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}