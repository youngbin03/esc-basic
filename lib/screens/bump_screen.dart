import 'package:bump/screens/letter_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BumpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: NotificationList(),
        decoration: BoxDecoration(color: Colors.white),
      ),
    );
  }
}

class NotificationList extends StatefulWidget {
  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    if (user == null) {
      return Center(child: Text('로그인을 해주세요!'));
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('User document not found'));
        }

        final userName = snapshot.data!['name'] as String;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('answers').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('알림이 오지 않았어요!'));
            }

            final Map<String, int> questionCounts = {};

            // 각 질문에 대해 나를 선택한 사람 수 계산
            snapshot.data!.docs.forEach((doc) {
              final responses = doc['responses'] as List<dynamic>;
              responses.forEach((response) {
                if (response['answer'] == userName) {
                  final question = response['question'];
                  if (questionCounts.containsKey(question)) {
                    questionCounts[question] = questionCounts[question]! + 1;
                  } else {
                    questionCounts[question] = 1;
                  }
                }
              });
            });

            // 나를 선택한 사람이 4명 이상인 질문 필터링
            final notifications = snapshot.data!.docs.where((doc) {
              final responses = doc['responses'] as List<dynamic>;
              final matchedResponse = responses.firstWhere(
                (response) => response['answer'] == userName,
                orElse: () => null,
              );
              if (matchedResponse != null) {
                final question = matchedResponse['question'];
                return questionCounts[question] != null &&
                    questionCounts[question]! >= 4;
              }
              return false;
            }).toList();

            // 중복 질문 제거
            final uniqueQuestions = <String>{};
            final filteredNotifications = notifications.where((doc) {
              final question = (doc['responses'] as List<dynamic>).firstWhere(
                  (response) => response['answer'] == userName)['question'];
              if (uniqueQuestions.contains(question)) {
                return false;
              } else {
                uniqueQuestions.add(question);
                return true;
              }
            }).toList();

            if (filteredNotifications.isEmpty) {
              return Center(child: Text('알림이 오지 않았어요!'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];
                final responses = notification['responses'] as List<dynamic>;
                final matchedResponse = responses.firstWhere(
                  (response) => response['answer'] == userName,
                  orElse: () => null,
                );

                if (matchedResponse != null) {
                  final question = matchedResponse['question'];
                  final completedDate = notification['completedDate'] as String;

                  return NotificationCard(
                    message: question,
                    date: completedDate,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  LetterScreen(
                            question: question,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            final offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  );
                }

                return Container();
              },
            );
          },
        );
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String message;
  final String date;
  final VoidCallback onTap;

  const NotificationCard(
      {required this.message, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/icons/logo.png', width: 45, height: 45),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientText(
                    message,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
