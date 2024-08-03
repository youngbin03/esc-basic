import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LetterScreen extends StatefulWidget {
  final String message;

  const LetterScreen({required this.message});

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _fromUser = 'loading...';
  List<String> _selectedByUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // Firestore에서 현재 사용자의 이름을 가져오기
      //Firestore의 users 컬렉션에서 현재 사용자의 문서를 가져옵니다.
      //문서가 존재하면 _fromUser 변수에 사용자의 이름을 저장합니다.
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _fromUser = userDoc['name'];
        });
      }

      // Firestore에서 답변을 가져오기
      final answersSnapshot =
          await FirebaseFirestore.instance.collection('answers').get();
      final selectedByUsers = answersSnapshot.docs
          .where((doc) => doc['responses']
              .any((response) => response['answer'] == _fromUser))
          .map((doc) => doc['userName'])
          .toList();
      //각 문서를 순회하여, responses 필드에서 현재 사용자가 답변으로 선택된 경우를 찾습니다.
      //해당 문서의 userName 필드를 selectedByUsers 리스트에 저장합니다.

      setState(() {
        _selectedByUsers = List<String>.from(selectedByUsers);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // 앱바를 body 뒤에 연장하여 투명하게 보이게 함
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(CupertinoIcons.clear, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.red],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 150),
              Text(
                '$_fromUser 로부터',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20), // 간격을 줄이기 위해 높이를 줄였습니다.
              Flexible(
                child: Image.asset('assets/icons/logo.png',
                    width: 150, height: 150),
              ),
              SizedBox(height: 24), // 간격을 줄이기 위해 높이를 줄였습니다.
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 2,
                  ),
                  itemCount: 4, // 사용자 이름 리스트 크기
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: Offset(0, 3), // 그림자 위치 조정
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _selectedByUsers[index],
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 80), // 간격을 줄이기 위해 높이를 줄였습니다.
            ],
          ),
        ),
      ),
    );
  }
}
