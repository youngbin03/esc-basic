import 'package:bump/auth.service.dart';
import 'package:bump/vote.dart';
import 'package:bump/voteprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkVoteStatus();
  }

  void _checkVoteStatus() async {
    final authService = context.read<AuthService>();
    final isCompleted = await authService.isVoteCompleted();
    context.read<VoteProvider>().setVoteCompleted(isCompleted);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        leading: Container(),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "BUMP's"),
            Tab(text: '투표하기'),
            Tab(text: '프로필 페이지'),
          ],
          indicatorColor: Colors.orange, // 선택된 탭의 하단 막대기 색상 설정
          labelColor: Colors.orange, // 선택된 탭의 텍스트 색상 설정
          unselectedLabelColor: Colors.grey, // 선택되지 않은 탭의 텍스트 색상 설정
        ),
        elevation: 0,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BumpScreen(),
          VoteScreen(),
          ProfileScreen(),
        ],
      ),
    );
  }
}

class BumpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Welcome to BUMP's page!"),
    );
  }
}

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
                          Navigator.pushNamed(context, '/home');
                        },
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

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final profileImage = context.watch<AuthService>().profileImage;

    return FutureBuilder<String?>(
      future: authService.getUserName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('User name not found'));
        } else {
          final userName = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red,
                        const Color.fromARGB(255, 255, 136, 0)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    radius: 80,
                    backgroundImage:
                        profileImage != null ? FileImage(profileImage) : null,
                    child: profileImage == null
                        ? Icon(
                            CupertinoIcons.person_fill,
                            color: Colors.white,
                            size: 80,
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 36),
                Text(
                  userName,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
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
                    onPressed: () {
                      authService.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/signin', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
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
                    onPressed: () {
                      // 회원 탈퇴 로직을 여기에 추가하세요
                      // 예시: authService.deleteAccount();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      '회원 탈퇴',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
