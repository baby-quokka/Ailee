class ApiConfig {
  // 개발 환경
  static const String baseUrl = 'http://10.64.141.126:8000/api';

  // API 엔드포인트
  static const String userCreate = '/user/create/';
  static const String userLogin = '/user/login/';
  static const String userProfile = '/user/'; // /user/{user_id}/

  // 팔로잉/팔로워 API 엔드포인트
  static const String userFollow = '/user/'; // /user/{user_id}/follow/
  static const String userFollowing = '/user/'; // /user/{user_id}/following/
  static const String userFollowers = '/user/'; // /user/{user_id}/followers/

  // 채팅 API 엔드포인트
  static const String chatSessions =
      '/chat/users/'; // /chat/users/{user_id}/sessions/
  static const String chatSession =
      '/chat/sessions/'; // /chat/sessions/{session_id}/

  // 슬랩 API 엔드포인트
  static const String userSlab = '/slabs/users/{user_id}/'; // 사용자의 슬랩 목록
  static const String slabPosts = '/slabs/{slab_id}/posts/'; // 특정 슬랩의 포스트 목록
  static const String postDetail = '/slabs/posts/{post_id}/'; // 포스트 상세/수정/삭제
  static const String postAnswers =
      '/slabs/posts/{post_id}/answers/'; // 포스트의 답변 목록
  static const String answerDetail =
      '/slabs/answers/{answer_id}/'; // 답변 상세/수정/삭제
  static const String answerComments =
      '/slabs/answers/{answer_id}/comments/'; // 답변의 댓글 목록
  static const String commentDetail =
      '/slabs/comments/{comment_id}/'; // 댓글 상세/수정/삭제
  static const String postLikes = '/slabs/posts/{post_id}/likes/'; // 포스트 좋아요 목록
  static const String answerLikes =
      '/slabs/answers/{answer_id}/likes/'; // 답변 좋아요 목록
  static const String commentLikes =
      '/slabs/comments/{comment_id}/likes/'; // 댓글 좋아요 목록

  // 헤더 설정
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 타임아웃 설정
  static const Duration timeout = Duration(seconds: 30);
}
