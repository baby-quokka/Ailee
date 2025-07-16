import 'package:flutter/material.dart';
import '../models/slab/slab.dart';
import '../models/slab/post.dart';
import '../services/slab_api_service.dart';

class SlabProvider with ChangeNotifier {
  final SlabApiService _apiService = SlabApiService();

  List<Slab> _slabs = [];
  List<Slab> get slabs => _slabs;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 슬랩 목록 불러오기
  Future<void> loadSlabs() async {
    _isLoading = true;
    notifyListeners();
    try {
      _slabs = await _apiService.fetchSlabs();
    } catch (e) {
      _slabs = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // 특정 슬랩의 포스트 불러오기
  Future<void> loadPosts(int slabId, {bool isTimeOrder = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _posts = await _apiService.fetchPosts(slabId, isTimeOrder: isTimeOrder);
    } catch (e) {
      _posts = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // 포스트 추가
  Future<Post?> addPost(
    int slabId,
    int userId,
    String content, {
    String? title,
    bool isWorkflow = false,
  }) async {
    try {
      final newPost = await _apiService.createPost(
        slabId,
        userId,
        content,
        title: title,
        isWorkflow: isWorkflow,
      );
      _posts.insert(0, newPost); // 최신글 맨 앞에 추가
      notifyListeners();
      return newPost;
    } catch (e) {
      return null;
    }
  }

  // 포스트 수정
  Future<bool> editPost(int postId, String content) async {
    try {
      await _apiService.updatePost(postId, content);
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx] = Post(
          id: _posts[idx].id,
          slab: _posts[idx].slab,
          user: _posts[idx].user,
          title: _posts[idx].title,
          content: content,
          createdAt: _posts[idx].createdAt,
          views: _posts[idx].views,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // 포스트 삭제
  Future<bool> removePost(int postId) async {
    try {
      await _apiService.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 슬랩 생성
  Future<Slab?> createSlab({
    required String name,
    String? description,
    String? emoji,
  }) async {
    try {
      final newSlab = await _apiService.createSlab(name, description, emoji);
      _slabs.add(newSlab);
      notifyListeners();
      return newSlab;
    } catch (e) {
      return null;
    }
  }

  // 슬랩 수정
  Future<bool> editSlab(
    int slabId, {
    String? name,
    String? description,
    String? emoji,
  }) async {
    try {
      final updatedSlab = await _apiService.editSlab(
        slabId,
        name: name,
        description: description,
        emoji: emoji,
      );
      final idx = _slabs.indexWhere((s) => s.id == slabId);
      if (idx != -1) {
        _slabs[idx] = updatedSlab;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 슬랩 삭제
  Future<bool> removeSlab(int slabId) async {
    try {
      await _apiService.removeSlab(slabId);
      _slabs.removeWhere((s) => s.id == slabId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
