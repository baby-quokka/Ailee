class ChatMessage {
  final int id;
  final int sessionId;
  final String sender; // 'user' or 'model'
  final String message;
  final int order;
  final List<String>? localImagePaths; // 로컬 이미지 경로 리스트
  final List<String>? localFilePaths; // 로컬 파일 경로 리스트
  final List<Map<String, dynamic>>? images; // 서버 이미지 정보 리스트
  final List<Map<String, dynamic>>? files; // 서버 파일 정보 리스트
  final List<Map<String, dynamic>>? audios; // 서버 오디오 정보 리스트

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.sender,
    required this.message,
    required this.order,
    this.localImagePaths,
    this.localFilePaths,
    this.images,
    this.files,
    this.audios,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      sessionId: json['session'] ?? 0,
      sender: json['sender'] ?? 'user',
      message: json['message'] ?? '',
      order: json['order'] ?? 0,
      localImagePaths: json['localImagePaths'] != null
          ? List<String>.from(json['localImagePaths'])
          : null,
      localFilePaths: json['localFilePaths'] != null
          ? List<String>.from(json['localFilePaths'])
          : null,
      images: json['images'] != null
          ? List<Map<String, dynamic>>.from(json['images'])
          : null,
      files: json['files'] != null
          ? List<Map<String, dynamic>>.from(json['files'])
          : null,
      audios: json['audios'] != null
          ? List<Map<String, dynamic>>.from(json['audios'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session': sessionId,
      'sender': sender,
      'message': message,
      'order': order,
      if (localImagePaths != null) 'localImagePaths': localImagePaths,
      if (localFilePaths != null) 'localFilePaths': localFilePaths,
      if (images != null) 'images': images,
      if (files != null) 'files': files,
      if (audios != null) 'audios': audios,
    };
  }

  bool get isUser => sender == 'user';
  bool get isModel => sender == 'model';

  /// 서버 이미지 URL 리스트를 반환하는 getter
  List<String> get serverImageUrls {
    if (images == null) return [];
    return images!.map((image) => image['image'] as String).toList();
  }

  /// 서버 파일 URL 리스트를 반환하는 getter
  List<String> get serverFileUrls {
    if (files == null) return [];
    return files!.map((file) => file['file'] as String).toList();
  }

  /// 서버 오디오 URL 리스트를 반환하는 getter
  List<String> get serverAudioUrls {
    if (audios == null) return [];
    return audios!.map((audio) => audio['audio'] as String).toList();
  }

  /// 객체의 일부 속성만 변경하여 새로운 객체를 생성하는 메서드
  ChatMessage copyWith({
    int? id,
    int? sessionId,
    String? sender,
    String? message,
    int? order,
    List<String>? localImagePaths,
    List<String>? localFilePaths,
    List<Map<String, dynamic>>? images,
    List<Map<String, dynamic>>? files,
    List<Map<String, dynamic>>? audios,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      sender: sender ?? this.sender,
      message: message ?? this.message,
      order: order ?? this.order,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      localFilePaths: localFilePaths ?? this.localFilePaths,
      images: images ?? this.images,
      files: files ?? this.files,
      audios: audios ?? this.audios,
    );
  }
}
