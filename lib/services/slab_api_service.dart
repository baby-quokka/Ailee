import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/slab/slab.dart';
import '../models/slab/post.dart';
import '../models/slab/post_likes.dart';

class SlabApiService {
  static final SlabApiService _instance = SlabApiService._internal();
  factory SlabApiService() => _instance;
  SlabApiService._internal();

  http.Client? _client;

  http.Client get _getClient {
    _client ??= http.Client();
    return _client!;
  }

  Map<String, String> get _headers => {...ApiConfig.defaultHeaders};

  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage = '알 수 없는 오류가 발생했습니다.';
      try {
        if (response.headers['content-type']?.contains('application/json') ==
            true) {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['error'] ?? errorData['message'] ?? errorMessage;
        } else {
          if (response.body.contains('<!DOCTYPE html>') ||
              response.body.contains('<html>')) {
            switch (response.statusCode) {
              case 404:
                errorMessage = '요청한 API 엔드포인트를 찾을 수 없습니다.';
                break;
              case 500:
                errorMessage = '서버 내부 오류가 발생했습니다.';
                break;
              case 401:
                errorMessage = '인증이 필요합니다. 로그인을 다시 시도해주세요.';
                break;
              case 403:
                errorMessage = '접근 권한이 없습니다.';
                break;
              default:
                errorMessage = '서버 오류가 발생했습니다. (${response.statusCode})';
            }
          } else {
            errorMessage = '서버 응답을 처리할 수 없습니다. (${response.statusCode})';
          }
        }
      } catch (e) {
        if (response.body.contains('<!DOCTYPE html>') ||
            response.body.contains('<html>')) {
          errorMessage = '서버에서 HTML 페이지를 반환했습니다. (${response.statusCode})';
        } else {
          errorMessage = '응답을 처리할 수 없습니다. (${response.statusCode})';
        }
      }
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  // GET 요청 헬퍼
  Future<T> _get<T>(String endpoint) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await _getClient
            .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: _headers)
            .timeout(ApiConfig.timeout);

        _handleError(response);
        return json.decode(utf8.decode(response.bodyBytes)) as T;
      } catch (e) {
        retryCount++;
        if (e.toString().contains('Connection closed') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
            _client?.close();
            _client = null;
            continue;
          }
        }
        if (e is ApiException) rethrow;
        throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
      }
    }
    throw ApiException('최대 재시도 횟수를 초과했습니다.', 0);
  }

  // POST 요청 헬퍼
  Future<T> _post<T>(String endpoint, Map<String, dynamic> data) async {
    int retryCount = 0;
    const maxRetries = 3;
    while (retryCount < maxRetries) {
      try {
        final response = await _getClient
            .post(
              Uri.parse('${ApiConfig.baseUrl}$endpoint'),
              headers: _headers,
              body: json.encode(data),
            )
            .timeout(ApiConfig.timeout);
        _handleError(response);
        return json.decode(utf8.decode(response.bodyBytes)) as T;
      } catch (e) {
        retryCount++;
        if (e.toString().contains('Connection closed') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
            _client?.close();
            _client = null;
            continue;
          }
        }
        if (e is ApiException) rethrow;
        throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
      }
    }
    throw ApiException('최대 재시도 횟수를 초과했습니다.', 0);
  }

  // PUT 요청 헬퍼
  Future<void> _put(String endpoint, Map<String, dynamic> data) async {
    int retryCount = 0;
    const maxRetries = 3;
    while (retryCount < maxRetries) {
      try {
        final response = await _getClient
            .put(
              Uri.parse('${ApiConfig.baseUrl}$endpoint'),
              headers: _headers,
              body: json.encode(data),
            )
            .timeout(ApiConfig.timeout);
        _handleError(response);
        return;
      } catch (e) {
        retryCount++;
        if (e.toString().contains('Connection closed') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
            _client?.close();
            _client = null;
            continue;
          }
        }
        if (e is ApiException) rethrow;
        throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
      }
    }
    throw ApiException('최대 재시도 횟수를 초과했습니다.', 0);
  }

  // PUT 요청 헬퍼(응답 반환)
  Future<T> _putWithResponse<T>(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;
    while (retryCount < maxRetries) {
      try {
        final response = await _getClient
            .put(
              Uri.parse('${ApiConfig.baseUrl}$endpoint'),
              headers: _headers,
              body: json.encode(data),
            )
            .timeout(ApiConfig.timeout);
        _handleError(response);
        return json.decode(utf8.decode(response.bodyBytes)) as T;
      } catch (e) {
        retryCount++;
        if (e.toString().contains('Connection closed') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
            _client?.close();
            _client = null;
            continue;
          }
        }
        if (e is ApiException) rethrow;
        throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
      }
    }
    throw ApiException('최대 재시도 횟수를 초과했습니다.', 0);
  }

  // DELETE 요청 헬퍼
  Future<void> _delete(String endpoint, {Map<String, dynamic>? body}) async {
    int retryCount = 0;
    const maxRetries = 3;
    while (retryCount < maxRetries) {
      try {
        final request = http.Request(
          'DELETE',
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        );
        request.headers.addAll(_headers);

        if (body != null) {
          request.body = json.encode(body);
        }

        final streamedResponse = await _getClient
            .send(request)
            .timeout(ApiConfig.timeout);
        final response = await http.Response.fromStream(streamedResponse);

        _handleError(response);
        return;
      } catch (e) {
        retryCount++;
        if (e.toString().contains('Connection closed') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
            _client?.close();
            _client = null;
            continue;
          }
        }
        if (e is ApiException) rethrow;
        throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
      }
    }
    throw ApiException('최대 재시도 횟수를 초과했습니다.', 0);
  }

  // 슬랩 전체 목록 가져오기 (임시 더미 데이터 사용)
  Future<List<Slab>> fetchSlabs() async {
    // TODO: 백엔드에 슬랩 목록 엔드포인트가 없어서 임시로 더미 데이터 반환

    // 임시 더미 데이터
    return [
      Slab(
        id: 1,
        name: "인간관계",
        description: "친구, 가족, 동료와의 관계에 관한 이야기",
        users: [],
        imoji: "👥",
        createdAt: "2024-01-01T00:00:00Z",
      ),
      Slab(
        id: 2,
        name: "자유",
        description: "자유롭게 이야기하는 공간",
        users: [],
        imoji: "🕊️",
        createdAt: "2024-01-02T00:00:00Z",
      ),
      Slab(
        id: 3,
        name: "진로",
        description: "직업과 진로에 관한 고민과 조언",
        users: [],
        imoji: "🎯",
        createdAt: "2024-01-03T00:00:00Z",
      ),
      Slab(
        id: 4,
        name: "학업",
        description: "공부와 학습에 관한 이야기",
        users: [],
        imoji: "📚",
        createdAt: "2024-01-04T00:00:00Z",
      ),
      Slab(
        id: 5,
        name: "심리",
        description: "마음과 정신 건강에 관한 이야기",
        users: [],
        imoji: "🧠",
        createdAt: "2024-01-05T00:00:00Z",
      ),
      Slab(
        id: 6,
        name: "취미/모임",
        description: "취미 활동과 모임에 관한 이야기",
        users: [],
        imoji: "🎨",
        createdAt: "2024-01-06T00:00:00Z",
      ),
      Slab(
        id: 7,
        name: "연애",
        description: "사랑과 연애에 관한 이야기",
        users: [],
        imoji: "💕",
        createdAt: "2024-01-07T00:00:00Z",
      ),
      Slab(
        id: 8,
        name: "운동",
        description: "운동과 건강에 관한 이야기",
        users: [],
        imoji: "💪",
        createdAt: "2024-01-08T00:00:00Z",
      ),
      Slab(
        id: 9,
        name: "맛집",
        description: "맛있는 음식과 맛집 추천",
        users: [],
        imoji: "🍽️",
        createdAt: "2024-01-09T00:00:00Z",
      ),
      Slab(
        id: 10,
        name: "소통",
        description: "의사소통과 대화에 관한 이야기",
        users: [],
        imoji: "💬",
        createdAt: "2024-01-10T00:00:00Z",
      ),
      Slab(
        id: 11,
        name: "게임",
        description: "게임과 엔터테인먼트에 관한 이야기",
        users: [],
        imoji: "🎮",
        createdAt: "2024-01-11T00:00:00Z",
      ),
      Slab(
        id: 12,
        name: "음악",
        description: "음악과 악기 연주에 관한 이야기",
        users: [],
        imoji: "🎵",
        createdAt: "2024-01-12T00:00:00Z",
      ),
      Slab(
        id: 13,
        name: "비공개 슬랩 1",
        description: "비공개 슬랩입니다",
        users: [],
        imoji: "🔒",
        createdAt: "2024-01-13T00:00:00Z",
      ),
      Slab(
        id: 14,
        name: "비공개 슬랩 2",
        description: "비공개 슬랩입니다",
        users: [],
        imoji: "🔒",
        createdAt: "2024-01-14T00:00:00Z",
      ),
      Slab(
        id: 15,
        name: "비공개 슬랩 3",
        description: "비공개 슬랩입니다",
        users: [],
        imoji: "🔒",
        createdAt: "2024-01-15T00:00:00Z",
      ),
    ];
  }

  // 특정 유저가 구독한 슬랩 목록 가져오기  // TODO: 아직 백엔드에서 구현 안됨
  Future<List<Slab>> fetchUserSlabs(int userId) async {
    final response = await _get<List<dynamic>>('/slabs/users/$userId/');
    return response.map((json) => Slab.fromJson(json)).toList();
  }

  // 슬랩 생성
  Future<Slab> createSlab(
    String name,
    String? description,
    String? emoji,
  ) async {
    final data = {'name': name, 'description': description, 'imoji': emoji};
    try {
      final response = await _post<Map<String, dynamic>>('/slabs/', data);
      return Slab.fromJson(response);
    } catch (e) {
      print('createSlab 예외: $e');
      rethrow;
    }
  }

  // 슬랩 수정
  Future<Slab> editSlab(
    int slabId, {
    String? name,
    String? description,
    String? emoji,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (emoji != null) data['imoji'] = emoji;

    try {
      final response = await _putWithResponse<Map<String, dynamic>>(
        '/slabs/$slabId/',
        data,
      );
      return Slab.fromJson(response);
    } catch (e) {
      print('editSlab 예외: $e');
      rethrow;
    }
  }

  // 슬랩 삭제
  Future<void> removeSlab(int slabId) async {
    try {
      await _delete('/slabs/$slabId/');
    } catch (e) {
      print('removeSlab 예외: $e');
      rethrow;
    }
  }

  // 포스트 목록 조회
  Future<List<Post>> fetchPosts(int slabId, {bool isTimeOrder = false}) async {
    try {
      String endpoint = '/slabs/$slabId/posts/';
      if (isTimeOrder) {
        endpoint += '?is_time_order=true';
      }
      final response = await _get<List<dynamic>>(endpoint);
      return response.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      print('fetchPosts 예외: $e');
      rethrow;
    }
  }

  // 포스트 상세 조회
  Future<Post> fetchPostDetail(int postId) async {
    try {
      final response = await _get<Map<String, dynamic>>(
        '/slabs/posts/$postId/',
      );
      return Post.fromJson(response);
    } catch (e) {
      print('fetchPostDetail 예외: $e');
      rethrow;
    }
  }

  // 포스트 생성
  Future<Post> createPost(
    int slabId,
    int userId,
    String content, {
    String? title,
    bool isWorkflow = false,
  }) async {
    try {
      String endpoint = '/slabs/posts/0/';
      if (isWorkflow) {
        endpoint += '?is_workflow=true';
      }
      final data = {
        'slab_id': slabId,
        'user_id': userId,
        'content': content,
        if (title != null) 'title': title,
      };
      final response = await _post<Map<String, dynamic>>(endpoint, data);
      return Post.fromJson(response);
    } catch (e) {
      print('createPost 예외: $e');
      rethrow;
    }
  }

  // 포스트 수정
  Future<void> updatePost(int postId, String content) async {
    try {
      final endpoint = '/slabs/posts/$postId/';
      final data = {'content': content};
      await _put(endpoint, data);
    } catch (e) {
      print('updatePost 예외: $e');
      rethrow;
    }
  }

  // 포스트 삭제
  Future<void> deletePost(int postId) async {
    try {
      final endpoint = '/slabs/posts/$postId/';
      await _delete(endpoint);
    } catch (e) {
      print('deletePost 예외: $e');
      rethrow;
    }
  }

  // PostLikes 관련 API 메서드들

  // 포스트 좋아요 목록 조회
  Future<List<PostLikes>> fetchPostLikes(int postId) async {
    try {
      final response = await _get<List<dynamic>>('/slabs/posts/$postId/likes/');
      return response.map((json) => PostLikes.fromJson(json)).toList();
    } catch (e) {
      print('fetchPostLikes 예외: $e');
      rethrow;
    }
  }

  // 포스트 좋아요 추가
  Future<void> addPostLike(int postId, int userId) async {
    try {
      final data = {'user_id': userId};
      await _post('/slabs/posts/$postId/likes/', data);
    } catch (e) {
      print('addPostLike 예외: $e');
      rethrow;
    }
  }

  // 포스트 좋아요 제거
  Future<void> removePostLike(int postId, int userId) async {
    try {
      final data = {'user_id': userId};
      await _delete('/slabs/posts/$postId/likes/', body: data);
    } catch (e) {
      print('removePostLike 예외: $e');
      rethrow;
    }
  }

  // 전체 포스트 목록 가져오기 (임시 더미 데이터 사용)
  Future<List<Map<String, dynamic>>> fetchAllPosts() async {
    // TODO: 백엔드에 전체 포스트 목록 엔드포인트가 없어서 임시로 더미 데이터 반환

    return [
      {
        'id': 1,
        'type': 'workflow',
        'user': {
          'id': 1,
          'username': 'Alex Rivera',
          'email': 'alex@example.com',
        },
        'slab': {
          'id': 1,
          'name': '인간관계',
          'description': '친구, 가족, 동료와의 관계에 관한 이야기',
          'imoji': '👥',
          'created_at': '2024-01-01T00:00:00Z',
        },
        'title': '치우가 친구 문제를 해결할 수 있도록 도와주세요!',
        'content': '''
친구들이 관계 문제를 해결할 수 있도록 돕기 위해 이 워크플로를 만들었습니다. 성격 유형에 따라 개인화된 조언을 제공하고 대화 시작자를 제안하며 갈등 해결 전략을 제공합니다.

워크플로에는 다음이 포함됩니다:
• 성격 평가
• 상황 분석
• 맞춤형 조언
• 후속 체크인

비슷한 상황에 처한 다른 사람들에게도 도움이 되길 바랍니다! 💙''',
        'created_at': '2025-07-19T10:00:00Z',
        'views': 45,
        'likes_count': 12,
      },
      {
        'id': 2,
        'user': {
          'id': 2,
          'username': 'baby_quokka520',
          'email': 'quokka@example.com',
        },
        'slab': {
          'id': 2,
          'name': '자유',
          'description': '자유롭게 이야기하는 공간',
          'imoji': '🕊️',
          'created_at': '2024-01-02T00:00:00Z',
        },
        'content':
            '오늘은 정말 기분이 좋은 하루였어요! 친구들과 공원에서 산책하고 맛있는 아이스크림도 먹었어요. 덕분에 스트레스가 확 풀렸답니다. 여러분은 오늘 뭐 하셨나요?',
        'created_at': '2025-07-19T14:30:00Z',
        'views': 23,
        'likes_count': 8,
      },
      {
        'id': 3,
        'user': {
          'id': 3,
          'username': 'career_hopeful',
          'email': 'career@example.com',
        },
        'slab': {
          'id': 3,
          'name': '진로',
          'description': '직업과 진로에 관한 고민과 조언',
          'imoji': '🎯',
          'created_at': '2024-01-03T00:00:00Z',
        },
        'content':
            '요즘 진로 때문에 너무 고민이에요. 디자인 쪽으로 가고 싶은데, 부모님은 안정적인 직장을 원하시네요. 어떻게 설득하면 좋을까요?',
        'created_at': '2025-07-19T13:50:00Z',
        'views': 18,
        'likes_count': 5,
      },
      {
        'id': 4,
        'user': {
          'id': 4,
          'username': 'study_holic',
          'email': 'study@example.com',
        },
        'slab': {
          'id': 4,
          'name': '학업',
          'description': '공부와 학습에 관한 이야기',
          'imoji': '📚',
          'created_at': '2024-01-04T00:00:00Z',
        },
        'content': '오늘은 밤새서 통계학 공부했어요. 베이즈 정리가 이렇게 어렵다니... 혹시 쉽게 이해하는 팁 있나요?',
        'created_at': '2025-07-19T13:30:00Z',
        'views': 32,
        'likes_count': 15,
      },
      {
        'id': 5,
        'type': 'workflow',
        'user': {
          'id': 5,
          'username': 'Jordan Kim',
          'email': 'jordan@example.com',
        },
        'slab': {
          'id': 5,
          'name': '심리',
          'description': '마음과 정신 건강에 관한 이야기',
          'imoji': '🧠',
          'created_at': '2024-01-05T00:00:00Z',
        },
        'title':
            'Daily mindfulness and productivity tracker with mood analysis and habit recommendations',
        'content': '''
This workflow helps you maintain mental clarity and track productivity patterns throughout the day.

Features:
• Morning intention setting
• Mood tracking with AI insights
• Productivity pattern analysis
• Evening reflection prompts
• Personalized habit suggestions

I've been using this for 3 months and it's transformed my daily routine. The AI recommendations get better over time as it learns your patterns.''',
        'created_at': '2025-07-19T13:10:00Z',
        'views': 67,
        'likes_count': 23,
      },
      {
        'id': 6,
        'user': {
          'id': 6,
          'username': 'hikinglover',
          'email': 'hiking@example.com',
        },
        'slab': {
          'id': 6,
          'name': '취미/모임',
          'description': '취미 활동과 모임에 관한 이야기',
          'imoji': '🎨',
          'created_at': '2024-01-06T00:00:00Z',
        },
        'content': '이번 주말에 북한산 등반 계획 있는데 같이 가실 분 구해요~ 초보 환영이고, 끝나고 맛집도 가요!',
        'created_at': '2025-07-19T12:00:00Z',
        'views': 15,
        'likes_count': 7,
      },
      {
        'id': 7,
        'user': {
          'id': 7,
          'username': 'relation_talk',
          'email': 'relation@example.com',
        },
        'slab': {
          'id': 1,
          'name': '인간관계',
          'description': '친구, 가족, 동료와의 관계에 관한 이야기',
          'imoji': '👥',
          'created_at': '2024-01-01T00:00:00Z',
        },
        'content':
            '친구랑 사소한 일로 다퉜는데 너무 마음이 무거워요. 먼저 연락하는 게 좋을까요? 경험 있으신 분 조언 부탁드려요.',
        'created_at': '2025-07-19T11:00:00Z',
        'views': 28,
        'likes_count': 11,
      },
      {
        'id': 8,
        'user': {
          'id': 8,
          'username': 'love_diary',
          'email': 'love@example.com',
        },
        'slab': {
          'id': 7,
          'name': '연애',
          'description': '사랑과 연애에 관한 이야기',
          'imoji': '💕',
          'created_at': '2024-01-07T00:00:00Z',
        },
        'content': '썸타는 사람과 오늘도 연락했는데, 답장이 늦으면 괜히 불안해지네요. 이런 감정 어떻게 조절하시나요?',
        'created_at': '2025-07-19T10:00:00Z',
        'views': 41,
        'likes_count': 18,
      },
      {
        'id': 9,
        'user': {'id': 9, 'username': 'mind_care', 'email': 'mind@example.com'},
        'slab': {
          'id': 5,
          'name': '심리',
          'description': '마음과 정신 건강에 관한 이야기',
          'imoji': '🧠',
          'created_at': '2024-01-05T00:00:00Z',
        },
        'content': '요즘 무기력하고 아무것도 하기 싫어요. 이런 상태가 계속되는데, 혹시 다들 이럴 때 어떻게 극복하시나요?',
        'created_at': '2025-07-19T09:00:00Z',
        'views': 89,
        'likes_count': 34,
      },
      {
        'id': 10,
        'user': {
          'id': 10,
          'username': 'fitness_guru',
          'email': 'fitness@example.com',
        },
        'slab': {
          'id': 8,
          'name': '운동',
          'description': '운동과 건강에 관한 이야기',
          'imoji': '💪',
          'created_at': '2024-01-08T00:00:00Z',
        },
        'content': '오늘 하체 운동 제대로 했더니 다리가 후들거리네요 ㅋㅋ 여러분은 스쿼트 몇 kg까지 치세요?',
        'created_at': '2025-07-19T08:00:00Z',
        'views': 56,
        'likes_count': 22,
      },
      {
        'id': 11,
        'user': {
          'id': 11,
          'username': 'foodie_jjang',
          'email': 'foodie@example.com',
        },
        'slab': {
          'id': 9,
          'name': '맛집',
          'description': '맛있는 음식과 맛집 추천',
          'imoji': '🍽️',
          'created_at': '2024-01-09T00:00:00Z',
        },
        'content':
            '신사동에 새로 생긴 파스타집 다녀왔어요! 크림 파스타가 진짜 고소하고 담백해서 완전 제 스타일이었어요. 추천합니다~',
        'created_at': '2025-07-19T07:00:00Z',
        'views': 73,
        'likes_count': 29,
      },
      {
        'id': 12,
        'user': {
          'id': 12,
          'username': 'open_talker',
          'email': 'talker@example.com',
        },
        'slab': {
          'id': 10,
          'name': '소통',
          'description': '의사소통과 대화에 관한 이야기',
          'imoji': '💬',
          'created_at': '2024-01-10T00:00:00Z',
        },
        'content': '다들 오늘 하루 어땠나요? 저는 일이 많아서 정신없었는데, 이렇게 소통할 수 있어 좋아요!',
        'created_at': '2025-07-19T06:00:00Z',
        'views': 19,
        'likes_count': 6,
      },
      {
        'id': 13,
        'user': {
          'id': 13,
          'username': 'game_addict',
          'email': 'gamer@example.com',
        },
        'slab': {
          'id': 11,
          'name': '게임',
          'description': '게임과 엔터테인먼트에 관한 이야기',
          'imoji': '🎮',
          'created_at': '2024-01-11T00:00:00Z',
        },
        'content': '롤 신규 챔피언 해보신 분? 스킬셋이 재밌어 보여서 궁금하네요. 메타에 적합한지 후기 부탁드립니다!',
        'created_at': '2025-07-19T05:00:00Z',
        'views': 34,
        'likes_count': 13,
      },
      {
        'id': 14,
        'user': {
          'id': 14,
          'username': 'music_healer',
          'email': 'music@example.com',
        },
        'slab': {
          'id': 12,
          'name': '음악',
          'description': '음악과 악기 연주에 관한 이야기',
          'imoji': '🎵',
          'created_at': '2024-01-12T00:00:00Z',
        },
        'content':
            '오늘은 아이유 노래 들으면서 하루를 시작했어요. 가사가 너무 예쁘고 위로가 되네요. 여러분은 어떤 노래로 하루를 시작하시나요?',
        'created_at': '2025-07-19T04:00:00Z',
        'views': 62,
        'likes_count': 25,
      },
      {
        'id': 15,
        'user': {
          'id': 15,
          'username': 'study_buddy',
          'email': 'buddy@example.com',
        },
        'slab': {
          'id': 4,
          'name': '학업',
          'description': '공부와 학습에 관한 이야기',
          'imoji': '📚',
          'created_at': '2024-01-04T00:00:00Z',
        },
        'content': '중간고사 끝났는데 결과가 생각보다 안 좋네요... 다들 시험 끝나고 슬럼프는 어떻게 극복하시나요?',
        'created_at': '2025-07-19T03:00:00Z',
        'views': 27,
        'likes_count': 9,
      },
      {
        'id': 16,
        'user': {
          'id': 16,
          'username': 'lover101',
          'email': 'lover@example.com',
        },
        'slab': {
          'id': 7,
          'name': '연애',
          'description': '사랑과 연애에 관한 이야기',
          'imoji': '💕',
          'created_at': '2024-01-07T00:00:00Z',
        },
        'content': '짝사랑 중인데, 오늘 눈 마주쳤어요! 괜히 두근거려서 공부가 안되네요 ㅠㅠ',
        'created_at': '2025-07-19T02:00:00Z',
        'views': 48,
        'likes_count': 20,
      },
      {
        'id': 17,
        'user': {
          'id': 17,
          'username': 'mental_health',
          'email': 'mental@example.com',
        },
        'slab': {
          'id': 5,
          'name': '심리',
          'description': '마음과 정신 건강에 관한 이야기',
          'imoji': '🧠',
          'created_at': '2024-01-05T00:00:00Z',
        },
        'content': '불면증 때문에 새벽 4시까지 잠 못 자고 있어요. 잠드는 팁 있으면 알려주세요...',
        'created_at': '2025-07-19T01:00:00Z',
        'views': 95,
        'likes_count': 41,
      },
      {
        'id': 18,
        'user': {'id': 18, 'username': 'gymrat', 'email': 'gym@example.com'},
        'slab': {
          'id': 8,
          'name': '운동',
          'description': '운동과 건강에 관한 이야기',
          'imoji': '💪',
          'created_at': '2024-01-08T00:00:00Z',
        },
        'content': '벤치프레스 기록 갱신! 60kg에서 65kg 성공했어요. 다음 목표는 70kg입니다🔥',
        'created_at': '2025-07-19T00:00:00Z',
        'views': 71,
        'likes_count': 31,
      },
      {
        'id': 19,
        'user': {
          'id': 19,
          'username': 'food_hunter',
          'email': 'hunter@example.com',
        },
        'slab': {
          'id': 9,
          'name': '맛집',
          'description': '맛있는 음식과 맛집 추천',
          'imoji': '🍽️',
          'created_at': '2024-01-09T00:00:00Z',
        },
        'content':
            '부산에서 밀면 먹고 왔어요. 여름에는 시원한 밀면이 최고네요. 혹시 부산 사시는 분들, 숨겨진 맛집 추천해주세요!',
        'created_at': '2025-07-18T23:00:00Z',
        'views': 84,
        'likes_count': 36,
      },
      {
        'id': 20,
        'user': {
          'id': 20,
          'username': 'friend_maker',
          'email': 'friend@example.com',
        },
        'slab': {
          'id': 10,
          'name': '소통',
          'description': '의사소통과 대화에 관한 이야기',
          'imoji': '💬',
          'created_at': '2024-01-10T00:00:00Z',
        },
        'content': '소통하고 싶어요~ 오늘 하루 있었던 재미있는 일 한 가지씩 공유해볼까요?',
        'created_at': '2025-07-18T22:00:00Z',
        'views': 12,
        'likes_count': 4,
      },
    ];
  }

  // 연결 해제
  void dispose() {
    _client?.close();
  }
}

// API 예외 클래스
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
