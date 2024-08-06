import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  Future<String?> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc['name'];
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
      if (e.code == 'user-not-found') {
        onError('등록되어 있지 않은 사용자입니다.');
      } else if (e.code == 'wrong-password') {
        onError('잘못된 비밀번호입니다.');
      } else {
        onError(e.message!);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  void signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> setVoteCompleted() async {
    final userId = getUserId();
    if (userId != null) {
      await _firestore.collection('users').doc(userId).update({'isDone': true});
      notifyListeners();
    }
  }

  Future<bool> isVoteCompleted() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc['isDone'] ?? false;
    }
    return false;
  }

  Future<void> setVoteCompletedByUserName(String userName, bool isDone) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('name', isEqualTo: userName)
          .get();

      if (query.docs.isNotEmpty) {
        String docId = query.docs.first.id;
        await _firestore
            .collection('users')
            .doc(docId)
            .update({'isDone': isDone});
        notifyListeners(); // 화면 갱신
      } else {
        throw Exception("User not found");
      }
    } catch (e) {
      print("Failed to update isDone: $e");
      throw e;
    }
  }

  Future<bool> checkIfUserCompletedVoteToday() async {
    final user = _auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final formattedDate = DateFormat('MM월 dd일').format(now);

      final answerDoc =
          await _firestore.collection('answers').doc(user.uid).get();
      if (answerDoc.exists) {
        final data = answerDoc.data();
        final completedDate = data?['completedDate'];
        print('User completed vote on: $completedDate'); // 디버깅 메시지
        return completedDate == formattedDate;
      }
    }
    return false;
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Firestore에서 사용자 데이터 삭제
        await _firestore.collection('users').doc(user.uid).delete();

        // Firebase Authentication에서 사용자 계정 삭제
        await user.delete();

        notifyListeners();
      }
    } catch (e) {
      print("Failed to delete account: $e");
      throw e;
    }
  }
}
