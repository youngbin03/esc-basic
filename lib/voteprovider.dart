import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth.service.dart';

class VoteProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isVoteCompleted = false;

  bool get isVoteCompleted => _isVoteCompleted;

  Future<void> checkIfVoteCompleted(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      _isVoteCompleted = userDoc.data()?['isDone'] ?? false;
      notifyListeners();
    } else {
      _isVoteCompleted = false; // 유저가 존재하지 않으면 false로 설정
      notifyListeners();
    }
  }

  void setVoteCompleted(bool isCompleted) {
    _isVoteCompleted = isCompleted;
    notifyListeners();
  }
}
