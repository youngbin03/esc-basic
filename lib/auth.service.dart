import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? currentUser() {
    return _auth.currentUser;
  }

  String? getUserName() {
    final user = _auth.currentUser;
    if (user != null) {
      final email = user.email!;
      return email.split('@')[0]; // 이메일의 '@' 앞 부분을 이름으로 사용
    }
    return null;
  }

  File? _profileImage;

  File? get profileImage => _profileImage;

  void setProfileImage(File? image) {
    _profileImage = image;
    notifyListeners();
  }

  void signUp({
    required String name,
    required String password,
    required Function() onSuccess,
    required Function(String err) onError,
  }) async {
    if (name.isEmpty) {
      onError("이름을 입력해 주세요.");
      return;
    } else if (password.isEmpty) {
      onError("비밀번호를 입력해 주세요.");
      return;
    }
    try {
      String email = '$name@bump.com';

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // 성공 함수 호출
      onSuccess();
    } on FirebaseAuthException catch (e) {
      // Firebase auth 에러 발생
      if (e.code == 'email-already-in-use') {
        onError('이미 가입된 이메일 입니다.');
      } else {
        onError(e.message!);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  void signIn({
    required String name,
    required String password,
    required Function() onSuccess,
    required Function(String err) onError,
  }) async {
    if (name.isEmpty) {
      onError('이름을 입력해주세요.');
      return;
    } else if (password.isEmpty) {
      onError('비밀번호를 입력해주세요.');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: '$name@bump.com',
        password: password,
      );
      onSuccess();
      notifyListeners(); // 로그인 상태 변경 알림
    } on FirebaseAuthException catch (e) {
      onError(e.message!);
    } catch (e) {
      onError(e.toString());
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}
