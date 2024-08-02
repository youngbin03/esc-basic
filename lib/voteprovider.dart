import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VoteProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isVoteCompleted = false;

  bool get isVoteCompleted => _isVoteCompleted;

  Future<void> checkIfVoteCompleted(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      _isVoteCompleted = userDoc.data()?['isDone'] ?? false;
      notifyListeners();
    }
  }

  Future<void> checkIfVoteCompletedByUserName(String userName) async {
    print("Checking vote completion for user: $userName"); // 디버깅 메시지 추가
    final query = await _firestore
        .collection('users')
        .where('name', isEqualTo: userName)
        .get();
    if (query.docs.isNotEmpty) {
      final userDoc = query.docs.first;
      _isVoteCompleted = userDoc.data()['isDone'] ?? false;
      notifyListeners();
    } else {
      print("No user found with name: $userName"); // 디버깅 메시지 추가
    }
  }

  Future<void> completeVote(String userName) async {
    print("Completing vote for user: $userName"); // 디버깅 메시지 추가
    final query = await _firestore
        .collection('users')
        .where('name', isEqualTo: userName)
        .get();
    if (query.docs.isNotEmpty) {
      final userDoc = query.docs.first;
      await _firestore
          .collection('users')
          .doc(userDoc.id)
          .update({'isDone': true});
      _isVoteCompleted = true;
      notifyListeners();
    } else {
      print("No user found with name: $userName"); // 디버깅 메시지 추가
    }
  }
}
