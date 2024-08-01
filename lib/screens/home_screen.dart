import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back,
              color: Colors.white), // iOS 스타일의 뒤로가기 아이콘 및 색상
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "BUMP's"),
            Tab(text: '투표하기'),
            Tab(text: '프로필 페이지'),
          ],
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
    return Center(
      child: Text('Welcome to Vote page!'),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to Profile page!'),
    );
  }
}
