import 'package:bump/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class VotePage extends StatefulWidget {
  const VotePage({Key? key}) : super(key: key);

  @override
  _VotePageState createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  int _currentQuestionIndex = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': '첫 번째 질문?',
      'options': ['A', 'B', 'C', 'D'],
      'image': 'assets/images/singer.png'
    },
    {
      'question': '두 번째 질문?',
      'options': ['A', 'B', 'C', 'D'],
      'image': 'assets/images/singer.png'
    },
    {
      'question': '세 번째 질문?',
      'options': ['A', 'B', 'C', 'D'],
      'image': 'assets/images/singer.png'
    },
    {
      'question': '네 번째 질문?',
      'options': ['A', 'B', 'C', 'D'],
      'image': 'assets/images/singer.png'
    },
    {
      'question': '다섯 번째 질문?',
      'options': ['A', 'B', 'C', 'D'],
      'image': 'assets/images/singer.png'
    },
  ];

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _refreshNames() {
    // 이름 새로고침 로직을 여기에 추가하세요
  }

  void _skipQuestion() {
    _nextQuestion();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('5개 중 ${_currentQuestionIndex + 1}번째',
            style: TextStyle(color: Colors.white)),
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
                child: Image.asset(_questions[_currentQuestionIndex]['image'],
                    width: 145, height: 145),
              ),
              SizedBox(height: 16),
              Text(
                _questions[_currentQuestionIndex]['question'],
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
                itemCount: _questions[_currentQuestionIndex]['options'].length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: _nextQuestion,
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
                          _questions[_currentQuestionIndex]['options'][index],
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
                    onPressed: _refreshNames,
                    icon:
                        const Icon(CupertinoIcons.shuffle, color: Colors.white),
                    label: const Text(
                      '이름 새로고침',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _skipQuestion,
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
              SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}
