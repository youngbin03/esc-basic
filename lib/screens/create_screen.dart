import 'package:bump/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController questionController = TextEditingController();
  int _selectedImageIndex = 0;

  final List<String> imageOptions = ['🤫', '🥵', '😊', '🤭', '😈'];
  final List<String> imagePath = [
    'assets/images/quiet.png',
    'assets/images/hot.png',
    'assets/images/smile.png',
    'assets/images/charm.png',
    'assets/images/devil.png'
  ];

  void _createQuestion() {
    // 질문 생성 로직을 여기에 추가하세요
    final String question = questionController.text;
    final String selectedImage = imageOptions[_selectedImageIndex];

    print('Question: $question');
    print('Selected Image: $selectedImage');

    // 추가적인 작업 수행
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      extendBodyBehindAppBar: true,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'NEW 투표 질문 만들기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 32),
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: '궁금한 질문입력',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 24),
                Text(
                  'Select an Icon:',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                ToggleButtons(
                  isSelected: List.generate(imageOptions.length,
                      (index) => index == _selectedImageIndex),
                  onPressed: (int index) {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                  children: imageOptions.map((image) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        image,
                        style: TextStyle(
                          color:
                              _selectedImageIndex == imageOptions.indexOf(image)
                                  ? Colors.white
                                  : Colors.orange,
                        ),
                      ),
                    );
                  }).toList(),
                  selectedColor: Colors.white,
                  color: Colors.orange,
                  fillColor: Colors.orange.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                SizedBox(height: 48),
                Center(
                  child: ElevatedButton(
                    onPressed: _createQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 62, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      '질문 올리기',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
