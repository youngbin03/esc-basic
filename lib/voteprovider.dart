import 'package:flutter/material.dart';

class VoteProvider with ChangeNotifier {
  bool _isVoteCompleted = false;

  bool get isVoteCompleted => _isVoteCompleted;

  void completeVote() {
    _isVoteCompleted = true;
    notifyListeners();
  }
}
