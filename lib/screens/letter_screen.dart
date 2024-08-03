import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LetterScreen extends StatelessWidget {
  final String message;

  const LetterScreen({required this.message});

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
                '@@@ 로부터',
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
                message,
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
                            "??",
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
