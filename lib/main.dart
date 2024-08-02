import 'package:bump/auth.service.dart';
import 'package:bump/screens/enter_class_screen.dart';
import 'package:bump/screens/home_screen.dart';
import 'package:bump/screens/signup_screen.dart';
import 'package:bump/screens/onboarding_screen.dart';
import 'package:bump/screens/signin_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
  await Firebase.initializeApp(); // firebase 앱 시작
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Pretendard',
          ),
          home: user == null ? Onboarding() : HomeScreen(),
          routes: {
            '/enter': (context) => EnterClass(),
            '/login': (context) => LoginScreen(),
            '/home': (context) => HomeScreen(),
            '/signin': (context) => SigninScreen(),
          },
        );
      },
    );
  }
}
