import 'package:flutter/material.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Spacer(), // 추가하여 전체 레이아웃을 위로 이동
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Image.asset('assets/icons/logo.png',
                      width: 45, height: 45),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.red,
                          Colors.orange,
                          const Color.fromARGB(255, 255, 193, 59)
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      'BUMP',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -2.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24), // 텍스트 사이 간격
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Colors.red, Color.fromARGB(255, 255, 94, 0)],
                ).createShader(bounds);
              },
              child: Text(
                '친구들은 나를 어떻게 생각할까?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // 이 색상은 ShaderMask로 덮어씌워집니다.
                ),
              ),
            ),
            SizedBox(height: 36),
            Image(
              image: AssetImage('assets/images/smile.png'),
              width: 200,
              height: 200,
            ),
            SizedBox(height: 120),
            Container(
              width: 250, // 버튼의 고정 너비 설정
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, const Color.fromARGB(255, 255, 136, 0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/enter');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'EOS 인증하기',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Container(
              width: 250, // 버튼의 고정 너비 설정
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
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signin');
                  // 버튼 클릭 시 수행할 작업
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: <Color>[
                        Colors.red,
                        const Color.fromARGB(255, 255, 136, 0)
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    '이미 가입했다면 로그인!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Spacer(flex: 2), // 추가하여 전체 레이아웃을 위로 이동
          ],
        ),
      ),
    );
  }
}
