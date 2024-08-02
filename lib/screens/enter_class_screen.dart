import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EnterClass extends StatefulWidget {
  const EnterClass({Key? key}) : super(key: key);

  @override
  State<EnterClass> createState() => _EnterClassState();
}

class _EnterClassState extends State<EnterClass> {
  int basicClassCount = 0;
  int advanceClassCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchClassCounts();
  }

  Future<void> _fetchClassCounts() async {
    final firestore = FirebaseFirestore.instance;

    // Basic Class count
    final basicSnapshot = await firestore
        .collection('users')
        .where('class', isEqualTo: 'Basic Class')
        .get();
    final basicCount = basicSnapshot.docs.length;

    // Advance Class count
    final advanceSnapshot = await firestore
        .collection('users')
        .where('class', isEqualTo: 'Advance Class')
        .get();
    final advanceCount = advanceSnapshot.docs.length;

    setState(() {
      basicClassCount = basicCount;
      advanceClassCount = advanceCount;
    });
  }

  Widget buildClassCard(BuildContext context, String className,
      String university, String status, int count) {
    return Container(
      width: double.infinity, // 버튼을 가로로 꽉 채우기
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3), // 그림자 위치 조정
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/signup', arguments: className);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    className,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.black, // 텍스트 검은색
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: <Color>[
                          Colors.red,
                          const Color.fromARGB(255, 255, 136, 0)
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      '$count명',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white, // 이 색상은 ShaderMask로 덮어씌워집니다.
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    university,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.grey, // 작은 회색 글씨
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.grey, // 작은 회색 글씨
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "반을 선택해줘!",
          style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back,
              color: Colors.white), // iOS 스타일의 뒤로가기 아이콘 및 색상
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, const Color.fromARGB(255, 255, 136, 0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 전체 패딩 추가
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildClassCard(
                context, 'Basic Class', '한양대학교 컴퓨터소프트', '사용중', basicClassCount),
            SizedBox(height: 16),
            buildClassCard(context, 'Advance Class', '한양대학교 컴퓨터소프트', '사용중',
                advanceClassCount),
          ],
        ),
      ),
    );
  }
}
