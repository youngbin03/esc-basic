import 'package:bump/auth.service.dart';
import 'package:bump/voteprovider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class VotePage extends StatefulWidget {
  final String userName;

  const VotePage({Key? key, required this.userName}) : super(key: key);

  @override
  _VotePageState createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  //질문에 대한 답변 리스트
  List<Map<String, String>> _responses = [];

  int _currentQuestionIndex = 0;
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  List<String> _userNames = []; // 사용자 이름 리스트
  bool _voteCompleted = false; // 투표 완료 여부

  @override
  void initState() {
    super.initState();
    print(
        "VotePage initialized with userName: ${widget.userName}"); // 디버깅 메시지 추가
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final firestore = FirebaseFirestore.instance;

    // 질문을 가져오는 로직
    final questionSnapshot = await firestore.collection('questions').get();
    final allQuestions = questionSnapshot.docs.map((doc) {
      return {
        'question': doc['question'],
        'image': doc['image'],
      };
    }).toList();

    // 질문을 랜덤으로 최대 5개 선택
    allQuestions.shuffle();
    final questions = allQuestions.take(5).toList();

    // 사용자 정보를 가져오는 로직
    final userSnapshot = await firestore.collection('users').get();
    final userNames = userSnapshot.docs
        .map((doc) => doc['name'].toString())
        .where((name) => name != widget.userName)
        .toList();

    setState(() {
      _questions = questions;
      _userNames = userNames; // 사용자 이름 설정
      _isLoading = false;
      _shuffleOptions(); // 첫 번째 질문의 선택지를 섞음
    });
  }

  void _nextQuestion(String selectedAnswer) {
    // 현재 질문에 대한 답변 저장
    _responses.add({
      'question': _questions[_currentQuestionIndex]['question'],
      'answer': selectedAnswer,
    });
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _shuffleOptions(); // 다음 질문으로 넘어갈 때 선택지 섞기
      });
    } else {
      setState(() {
        _voteCompleted = true; // 모든 질문 완료 시 투표 완료 상태로 설정
      });
      _saveResponses(); // 모든 답변 저장
    }
  }

  // 모든 답변을 Firestore에 저장하는 메서드
  Future<void> _saveResponses() async {
    final firestore = FirebaseFirestore.instance;
    final userId = (await FirebaseAuth.instance.currentUser)?.uid;

    if (userId != null) {
      final now = DateTime.now();
      final formattedDate = DateFormat('MM월 dd일').format(now);

      await firestore.collection('answers').doc(userId).set({
        'userName': widget.userName,
        'responses': _responses,
        'completedDate': formattedDate, // 투표 완료 날짜 추가
      });

      // Firestore에 투표 완료 상태 저장
      await _updateUserIsDoneStatus(userId);

      // VoteProvider의 상태 업데이트
      context.read<VoteProvider>().setVoteCompleted(true);

      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _updateUserIsDoneStatus(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final formattedDate = DateFormat('MM월 dd일').format(now);

    // 사용자 답변을 가져옴
    final answerSnapshot =
        await firestore.collection('answers').doc(userId).get();
    final answerData = answerSnapshot.data();

    if (answerData != null) {
      final completedDate = answerData['completedDate'];

      // 오늘 날짜와 비교
      final isDone = completedDate == formattedDate;

      // 사용자 상태 업데이트
      await firestore
          .collection('users')
          .doc(userId)
          .update({'isDone': isDone});
    }
  }

  void _shuffleOptions() {
    setState(() {
      _userNames.shuffle(); // 사용자 이름 섞기
    });
  }

  void _completeVote() async {
    print(
        "Complete vote called with userName: ${widget.userName}"); // 디버깅 메시지 추가
    if (widget.userName.isNotEmpty) {
      final firestore = FirebaseFirestore.instance;

      try {
        // 사용자 문서 찾기
        final userQuery = await firestore
            .collection('users')
            .where('name', isEqualTo: widget.userName)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userDocId = userQuery.docs.first.id;

          // isDone 필드를 true로 업데이트
          await firestore
              .collection('users')
              .doc(userDocId)
              .update({'isDone': true});
        } else {
          print("User document not found"); // 사용자 문서가 없을 경우 디버깅 메시지
        }

        // AuthService에서 투표 완료 상태 설정
        await Provider.of<AuthService>(context, listen: false)
            .setVoteCompletedByUserName(widget.userName, true);

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        print("Error updating user document: $e"); // 오류 발생 시 디버깅 메시지
      }
    } else {
      print("User name is empty or null"); // 디버깅 메시지 추가
    }
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

    if (_voteCompleted) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 36),
              Image(
                image: AssetImage('assets/images/vote.png'),
                width: 200,
                height: 200,
              ),
              SizedBox(height: 120),
              Container(
                width: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red,
                      const Color.fromARGB(255, 255, 136, 0)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ElevatedButton(
                  onPressed: _completeVote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    '투표 완료하기',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
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
                itemCount: 4, // 사용자 이름 리스트 크기
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // 4. _nextQuestion 호출 시 답변 전달
                      _nextQuestion(_userNames[index]);
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
                    onPressed: () {
                      _nextQuestion('건너뛰기');
                    },
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
              SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
