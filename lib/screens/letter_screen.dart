import 'package:bump/screens/bump_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LetterScreen extends StatefulWidget {
  final String question;

  const LetterScreen({required this.question});

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _selectedByUsers = [];
  bool _isLoading = true;
  bool _hasError = false;
  List<bool> _showNames = [];
  int _visibleIndex = -1;
  String _revealedName = '';
  bool _nameRevealed = false;
  int _selectedCount = 0; // 나를 선택한 사람 수

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) return;

      final userName = userDoc['name'];

      final answersSnapshot = await FirebaseFirestore.instance
          .collection('answers')
          .where('responses', arrayContains: {
        'question': widget.question,
        'answer': userName,
      }).get();

      final selectedByUsers =
          answersSnapshot.docs.map((doc) => doc['userName'] as String).toList();
      selectedByUsers.shuffle();

      final clickedSnapshot = await FirebaseFirestore.instance
          .collection('clicked')
          .doc(user.uid)
          .get();

      if (clickedSnapshot.exists) {
        _visibleIndex = clickedSnapshot['visibleIndex'];
        _revealedName = clickedSnapshot['revealedName'];
        _nameRevealed = clickedSnapshot['nameRevealed'];
      }

      setState(() {
        _selectedByUsers = selectedByUsers.take(4).toList();
        _showNames = List<bool>.filled(_selectedByUsers.length, false);
        _selectedCount = selectedByUsers.length; // 나를 선택한 사람 수 설정
        if (_nameRevealed) {
          _showNames[_visibleIndex] = true;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  Future<void> _saveClickedData(int index, String name) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('clicked').doc(user.uid).set({
        'visibleIndex': index,
        'revealedName': name,
        'nameRevealed': true,
      });
    } catch (e) {
      print('Error saving clicked data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
          child: _isLoading
              ? CircularProgressIndicator()
              : _hasError
                  ? Text('Error loading data',
                      style: TextStyle(color: Colors.white))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: screenSize.height * 0.15),
                          Text(
                            '친구 $_selectedCount명이 나를 선택했어요!',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.06,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenSize.height * 0.05),
                          Image.asset('assets/icons/logo.png',
                              width: screenSize.width * 0.3,
                              height: screenSize.width * 0.3),
                          SizedBox(height: screenSize.height * 0.05),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.0), // 오른쪽과 왼쪽 여백 추가
                            child: Text(
                              widget.question,
                              style: TextStyle(
                                fontSize: screenSize.width * 0.07,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    (screenSize.width > 600) ? 3 : 2,
                                crossAxisSpacing: 16.0,
                                mainAxisSpacing: 16.0,
                                childAspectRatio: 2,
                              ),
                              itemCount: _selectedByUsers.length,
                              itemBuilder: (context, index) {
                                final isRevealed =
                                    _nameRevealed && _visibleIndex == index;
                                final name = isRevealed
                                    ? _revealedName
                                    : _selectedByUsers[index];

                                return GestureDetector(
                                  onTap: () async {
                                    if (!_nameRevealed) {
                                      setState(() {
                                        _visibleIndex = index;
                                        _nameRevealed = true;
                                        _revealedName = name;
                                        _showNames = List<bool>.filled(
                                            _selectedByUsers.length, false);
                                        _showNames[index] = true;
                                      });
                                      await _saveClickedData(index, name);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _showNames[index]
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 5,
                                          blurRadius: 15,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _showNames[index] ? name : '???',
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
                          SizedBox(height: screenSize.height * 0.1),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
