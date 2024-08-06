import 'package:bump/auth.service.dart';
import 'package:bump/screens/enter_class_screen.dart';
import 'package:bump/screens/home_screen.dart';
import 'package:bump/screens/profile_photo_screen.dart';
import 'package:bump/screens/signup_screen.dart';
import 'package:bump/screens/onboarding_screen.dart';
import 'package:bump/screens/signin_screen.dart';
import 'package:bump/vote.dart';
import 'package:bump/voteprovider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth.service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
  await Firebase.initializeApp(); // firebase 앱 시작

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (_) => VoteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser();
        if (user != null) {
          // 사용자가 로그인 되어 있으면 투표 완료 상태를 확인하여 VoteProvider 업데이트
          context
              .read<VoteProvider>()
              .checkIfUserCompletedVoteToday(authService);
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Pretendard',
          ),
          home: user == null ? Onboarding() : HomeScreen(),
          routes: {
            '/enter': (context) => EnterClass(),
            '/signup': (context) => SignUpScreen(),
            '/home': (context) => HomeScreen(),
            '/signin': (context) => SigninScreen(),
            '/photo': (context) => ProfilePhotoScreen(),
            '/vote': (context) => VotePage(
                  userName: '',
                )
          },
        );
      },
    );
  }
}
