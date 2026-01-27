import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoticeCard extends StatelessWidget {
  final String title;
  final String content;
  final DateTime createdAt;

  const NoticeCard({
    super.key,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    // 날짜 포맷팅 (예: 2026-01-26 16:22)
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.notifications_outlined, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // 2줄 넘어가면 ... 처리
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}