import 'package:bump/auth.service.dart';
import 'package:bump/screens/bump_screen.dart';
import 'package:bump/screens/prfile_screen.dart';
import 'package:bump/screens/vote_screen.dart';
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
