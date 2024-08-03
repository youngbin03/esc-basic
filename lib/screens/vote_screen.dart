import 'package:bump/auth.service.dart';
import 'package:bump/screens/create_screen.dart';
import 'package:bump/vote.dart';
import 'package:bump/voteprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<VoteProvider>(
      builder: (context, voteProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [Colors.red, Color.fromARGB(255, 255, 115, 0)],
                    tileMode: TileMode.mirror,
                  ).createShader(bounds);
                },
                child: Text(
                  voteProvider.isVoteCompleted
                      ? '오늘은 투표가 끝났어요ㅠ'
                      : '친구들은 나를\n 어떻게 생각할까?',
                  textAlign: TextAlign.center, // 텍스트 중앙 정렬
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white, // 이 색상은 ShaderMask에 의해 덮어씌워집니다.
                  ),
                ),
              ),
              SizedBox(height: 24),
              Image(
                image: AssetImage(voteProvider.isVoteCompleted
                    ? 'assets/images/sad.png'
                    : 'assets/images/quiet.png'),
                width: 200,
                height: 200,
              ),
              SizedBox(height: 32),
              voteProvider.isVoteCompleted
                  ? Container(
                      width: 250, // 버튼의 고정 너비 설정
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
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          '투표 질문만들기',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 250, // 버튼의 고정 너비 설정
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
                        onPressed: () async {
                          final userName =
                              await context.read<AuthService>().getUserName();
                          if (userName != null && userName.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VotePage(userName: userName),
                              ),
                            );
                          } else {
                            print("User name is null or empty");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          '투표 시작하기',
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
        );
      },
    );
  }
}
