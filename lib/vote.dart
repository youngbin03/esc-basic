import 'package:bump/voteprovider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class VotePage extends StatefulWidget {
  const VotePage({Key? key}) : super(key: key);

  @override
  _VotePageState createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  int _currentQuestionIndex = 0;
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  bool _isShuffled = false;
  List<String> _userNames = []; // 사용자 이름 리스트

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final firestore = FirebaseFirestore.instance;

    // 질문을 가져오는 로직
    final questionSnapshot = await firestore.collection('questions').get();

    final questions = questionSnapshot.docs.map((doc) {
      return {'question': doc['question'], 'image': doc['image']};
    }).toList();

    // 사용자 정보를 가져오는 로직
    final userSnapshot = await firestore.collection('users').get();
    final userNames =
        userSnapshot.docs.map((doc) => doc['name'].toString()).toList();

    setState(() {
      _questions = questions;
      _userNames = userNames; // 사용자 이름 설정
      _isLoading = false;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isShuffled = false;
      });
    } else {
      Provider.of<VoteProvider>(context, listen: false).completeVote();
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _shuffleOptions() {
    setState(() {
      _userNames.shuffle(); // 사용자 이름 섞기
      _isShuffled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(CupertinoIcons.clear, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          title: Text('투표 완료', style: TextStyle(color: Colors.white)),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red,
                Colors.orange,
                const Color.fromARGB(255, 255, 136, 0)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              '오늘의 투표는 끝났습니다!',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 35,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.clear, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        title: Text('${_questions.length}개 중 ${_currentQuestionIndex + 1}번째',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.refresh, color: Colors.white),
            onPressed: _shuffleOptions, // 사용자 이름 섞기 버튼
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.white.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red,
              Colors.orange,
              const Color.fromARGB(255, 255, 136, 0)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 180),
              Flexible(
                child: Image.asset(
                  'assets/images/${_questions[_currentQuestionIndex]['image']}',
                  width: 145,
                  height: 145,
                ),
              ),
              SizedBox(height: 16),
              Text(
                _questions[_currentQuestionIndex]['question'].toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 35,
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 2,
                ),
                itemCount: _userNames.length, // 사용자 이름 리스트 크기
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // 선택된 항목에 대한 클릭 모션 추가
                        // 예: 선택된 항목 강조하기
                      });
                      _nextQuestion();
                    },
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
                          _userNames[index], // 사용자 이름 표시
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _shuffleOptions,
                    icon:
                        const Icon(CupertinoIcons.shuffle, color: Colors.white),
                    label: const Text(
                      '이름 새로고침', // 사용자 이름 섞기 버튼
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _nextQuestion,
                    icon: const Icon(CupertinoIcons.arrow_right_circle,
                        color: Colors.white),
                    label: const Text(
                      '건너뛰기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
