import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_inv/body/notice/notice_card.dart'; // 분리한 카드 파일 임포트

class NoticeBody extends StatelessWidget {
  const NoticeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // 최신 공지사항이 위로 오도록 정렬 (descending: true)
      stream: FirebaseFirestore.instance
          .collection('notices')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('오류 발생: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('등록된 공지사항이 없습니다.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            // Timestamp를 DateTime으로 변환 (null이면 현재 시간)
            DateTime createdDate = DateTime.now();
            if (data['createdAt'] != null) {
              createdDate = (data['createdAt'] as Timestamp).toDate();
            }

            return NoticeCard(
              title: data['title'] ?? '제목 없음',
              content: data['content'] ?? '',
              createdAt: createdDate,
            );
          },
        );
      },
    );
  }
}