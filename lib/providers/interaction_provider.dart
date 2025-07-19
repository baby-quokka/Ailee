import 'package:flutter/material.dart';
import '../models/slab/post_likes.dart';
import '../services/slab_api_service.dart';

class InteractionProvider with ChangeNotifier {
  final SlabApiService _apiService = SlabApiService();

  // PostLikes 관련 상태
  final Map<int, List<PostLikes>> _postLikes = {}; // postId -> likes
  Map<int, bool> _userLikedPosts = {}; // postId -> isLiked
  final Map<int, int> _postLikesCount = {}; // postId -> likesCount

  // AnswerLikes 관련 상태
  Map<int, bool> _userLikedAnswers = {}; // answerId -> isLiked
  final Map<int, int> _answerLikesCount = {}; // answerId -> likesCount

  // CommentLikes 관련 상태
  Map<int, bool> _userLikedComments = {}; // commentId -> isLiked
  final Map<int, int> _commentLikesCount = {}; // commentId -> likesCount

  // Getter
  List<PostLikes> getPostLikes(int postId) => _postLikes[postId] ?? [];
  bool isPostLikedByUser(int postId) => _userLikedPosts[postId] ?? false;
  int getPostLikesCount(int postId) => _postLikesCount[postId] ?? 0;

  // Answer Likes Getter
  bool isAnswerLikedByUser(int answerId) =>
      _userLikedAnswers[answerId] ?? false;
  int getAnswerLikesCount(int answerId) => _answerLikesCount[answerId] ?? 0;

  // Comment Likes Getter
  bool isCommentLikedByUser(int commentId) =>
      _userLikedComments[commentId] ?? false;
  int getCommentLikesCount(int commentId) => _commentLikesCount[commentId] ?? 0;

  // 포스트 좋아요 목록 불러오기
  Future<void> loadPostLikes(int postId) async {
    try {
      final likes = await _apiService.fetchPostLikes(postId);
      _postLikes[postId] = likes;
      notifyListeners();
    } catch (e) {
      print('포스트 좋아요 로드 실패: $e');
      _postLikes[postId] = [];
    }
  }

  // 포스트 좋아요 추가
  Future<bool> addPostLike(int postId, int userId) async {
    try {
      // 임시로 API 호출 주석처리
      // await _apiService.addPostLike(postId, userId);

      // 로컬 상태 업데이트
      _userLikedPosts[postId] = true;
      _postLikesCount[postId] = (_postLikesCount[postId] ?? 0) + 1;

      // 좋아요 목록 새로고침 (임시로 주석처리)
      // await loadPostLikes(postId);

      notifyListeners();
      return true;
    } catch (e) {
      print('포스트 좋아요 추가 실패: $e');
      return false;
    }
  }

  // 포스트 좋아요 제거
  Future<bool> removePostLike(int postId, int userId) async {
    try {
      // 임시로 API 호출 주석처리
      // await _apiService.removePostLike(postId, userId);

      // 로컬 상태 업데이트
      _userLikedPosts[postId] = false;
      _postLikesCount[postId] = (_postLikesCount[postId] ?? 1) - 1;

      // 좋아요 목록 새로고침 (임시로 주석처리)
      // await loadPostLikes(postId);

      notifyListeners();
      return true;
    } catch (e) {
      print('포스트 좋아요 제거 실패: $e');
      return false;
    }
  }

  // 포스트 좋아요 토글 (추가/제거)
  Future<bool> togglePostLike(int postId, int userId) async {
    final isCurrentlyLiked = _userLikedPosts[postId] ?? false;

    if (isCurrentlyLiked) {
      return await removePostLike(postId, userId);
    } else {
      return await addPostLike(postId, userId);
    }
  }

  // 사용자가 좋아요한 포스트 설정 (초기화용)
  void setUserLikedPosts(Map<int, bool> likedPosts) {
    _userLikedPosts = likedPosts;
    notifyListeners();
  }

  // 특정 포스트의 사용자 좋아요 상태 설정
  void setPostLikedByUser(int postId, bool isLiked) {
    _userLikedPosts[postId] = isLiked;
    notifyListeners();
  }

  // 특정 포스트의 좋아요 개수 설정
  void setPostLikesCount(int postId, int count) {
    _postLikesCount[postId] = count;
    notifyListeners();
  }

  // Answer 좋아요 토글
  Future<bool> toggleAnswerLike(int answerId, int userId) async {
    final isCurrentlyLiked = _userLikedAnswers[answerId] ?? false;

    if (isCurrentlyLiked) {
      return await removeAnswerLike(answerId, userId);
    } else {
      return await addAnswerLike(answerId, userId);
    }
  }

  // Answer 좋아요 추가
  Future<bool> addAnswerLike(int answerId, int userId) async {
    try {
      _userLikedAnswers[answerId] = true;
      _answerLikesCount[answerId] = (_answerLikesCount[answerId] ?? 0) + 1;
      notifyListeners();
      return true;
    } catch (e) {
      print('Answer 좋아요 추가 실패: $e');
      return false;
    }
  }

  // Answer 좋아요 제거
  Future<bool> removeAnswerLike(int answerId, int userId) async {
    try {
      _userLikedAnswers[answerId] = false;
      _answerLikesCount[answerId] = (_answerLikesCount[answerId] ?? 1) - 1;
      notifyListeners();
      return true;
    } catch (e) {
      print('Answer 좋아요 제거 실패: $e');
      return false;
    }
  }

  // Answer 좋아요 상태 설정
  void setAnswerLikedByUser(int answerId, bool isLiked) {
    _userLikedAnswers[answerId] = isLiked;
    notifyListeners();
  }

  // Answer 좋아요 개수 설정
  void setAnswerLikesCount(int answerId, int count) {
    _answerLikesCount[answerId] = count;
    notifyListeners();
  }

  // Comment 좋아요 토글
  Future<bool> toggleCommentLike(int commentId, int userId) async {
    final isCurrentlyLiked = _userLikedComments[commentId] ?? false;

    if (isCurrentlyLiked) {
      return await removeCommentLike(commentId, userId);
    } else {
      return await addCommentLike(commentId, userId);
    }
  }

  // Comment 좋아요 추가
  Future<bool> addCommentLike(int commentId, int userId) async {
    try {
      _userLikedComments[commentId] = true;
      _commentLikesCount[commentId] = (_commentLikesCount[commentId] ?? 0) + 1;
      notifyListeners();
      return true;
    } catch (e) {
      print('Comment 좋아요 추가 실패: $e');
      return false;
    }
  }

  // Comment 좋아요 제거
  Future<bool> removeCommentLike(int commentId, int userId) async {
    try {
      _userLikedComments[commentId] = false;
      _commentLikesCount[commentId] = (_commentLikesCount[commentId] ?? 1) - 1;
      notifyListeners();
      return true;
    } catch (e) {
      print('Comment 좋아요 제거 실패: $e');
      return false;
    }
  }

  // Comment 좋아요 상태 설정
  void setCommentLikedByUser(int commentId, bool isLiked) {
    _userLikedComments[commentId] = isLiked;
    notifyListeners();
  }

  // Comment 좋아요 개수 설정
  void setCommentLikesCount(int commentId, int count) {
    _commentLikesCount[commentId] = count;
    notifyListeners();
  }
}
