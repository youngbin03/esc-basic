import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore 인스턴스 초기화

  User? currentUser() {
    return _auth.currentUser;
  }

  String? getUserId() {
    return _auth.currentUser?.uid;
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

  Future<void> _updateClassCount(String group) async {
    DocumentReference classRef = _firestore.collection('classes').doc(group);
    _firestore.runTransaction((transaction) async {
      DocumentSnapshot classSnapshot = await transaction.get(classRef);
      if (!classSnapshot.exists) {
        transaction.set(classRef, {'count': 1});
      } else {
        int newCount = classSnapshot['count'] + 1;
        transaction.update(classRef, {'count': newCount});
      }
    });
  }

  void signUp({
    required String name,
    required String password,
    required String group,
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

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore에 유저 정보 저장
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'class': group,
        'isDone': false, // 기본값 설정
      });

      // 클래스 인원수 업데이트
      await _updateClassCount(group);

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
      await _auth.signInWithEmailAndPassword(
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
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> setVoteCompleted() async {
    final userName = getUserName();
    if (userName != null) {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('name', isEqualTo: userName)
          .get();
      if (query.docs.isNotEmpty) {
        String docId = query.docs.first.id;
        await _firestore
            .collection('users')
            .doc(docId)
            .update({'isDone': true});
        notifyListeners();
      }
    }
  }
}
