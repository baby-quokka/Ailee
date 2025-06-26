class User {
  final int id;
  final String email;
  final String name;
  final String mainCharacter;
  final String country;
  final DateTime birthDate;
  final String activationTime;

  // MBTI 점수 (0~100)
  final int iE;
  final int nS;
  final int tF;
  final int pJ;

  // 캐릭터별 대화 수
  final int aileeChatCount;
  final int joonChatCount;
  final int nickChatCount;
  final int chadChatCount;
  final int rinChatCount;

  // 문제유형별 대화 수
  final int emotionCount;
  final int decisionCount;
  final int socialCount;
  final int identityCount;
  final int motivationCount;
  final int learningCount;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.mainCharacter,
    required this.country,
    required this.birthDate,
    required this.activationTime,
    required this.iE,
    required this.nS,
    required this.tF,
    required this.pJ,
    required this.aileeChatCount,
    required this.joonChatCount,
    required this.nickChatCount,
    required this.chadChatCount,
    required this.rinChatCount,
    required this.emotionCount,
    required this.decisionCount,
    required this.socialCount,
    required this.identityCount,
    required this.motivationCount,
    required this.learningCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['gmail'] ?? json['email'], // 백엔드에서는 'gmail' 필드 사용
      name: json['name'],
      mainCharacter: json['main_character'],
      country: json['country'],
      birthDate: DateTime.parse(json['birth_date']),
      activationTime: json['activation_time'],
      iE: json['i_e'] ?? 0,
      nS: json['n_s'] ?? 0,
      tF: json['t_f'] ?? 0,
      pJ: json['p_j'] ?? 0,
      aileeChatCount: json['ailee_chat_count'] ?? 0,
      joonChatCount: json['joon_chat_count'] ?? 0,
      nickChatCount: json['nick_chat_count'] ?? 0,
      chadChatCount: json['chad_chat_count'] ?? 0,
      rinChatCount: json['rin_chat_count'] ?? 0,
      emotionCount: json['emotion_count'] ?? 0,
      decisionCount: json['decision_count'] ?? 0,
      socialCount: json['social_count'] ?? 0,
      identityCount: json['identity_count'] ?? 0,
      motivationCount: json['motivation_count'] ?? 0,
      learningCount: json['learning_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gmail': email, // 백엔드 호환성
      'name': name,
      'main_character': mainCharacter,
      'country': country,
      'birth_date': birthDate.toIso8601String().split('T')[0], // YYYY-MM-DD 형식
      'activation_time': activationTime,
      'i_e': iE,
      'n_s': nS,
      't_f': tF,
      'p_j': pJ,
      'ailee_chat_count': aileeChatCount,
      'joon_chat_count': joonChatCount,
      'nick_chat_count': nickChatCount,
      'chad_chat_count': chadChatCount,
      'rin_chat_count': rinChatCount,
      'emotion_count': emotionCount,
      'decision_count': decisionCount,
      'social_count': socialCount,
      'identity_count': identityCount,
      'motivation_count': motivationCount,
      'learning_count': learningCount,
    };
  }

  // 회원가입용 데이터 (비밀번호 포함)
  Map<String, dynamic> toSignupJson(String password) {
    final json = toJson();
    json['password'] = password;
    return json;
  }

  // MBTI 유형 계산
  String get mbtiType {
    final i = iE < 50 ? 'I' : 'E';
    final n = nS < 50 ? 'N' : 'S';
    final t = tF < 50 ? 'T' : 'F';
    final p = pJ < 50 ? 'P' : 'J';
    return '$i$n$t$p';
  }

  // 활성화 시간 한글 표시
  String get activationTimeDisplay {
    switch (activationTime) {
      case 'morning':
        return '🌅 아침 (6~11시)';
      case 'afternoon':
        return '☀️ 낮 (12~17시)';
      case 'evening':
        return '🌙 저녁 / 밤 (18~24시)';
      case 'dawn':
        return '🌃 새벽 (1~5시)';
      default:
        return activationTime;
    }
  }

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? mainCharacter,
    String? country,
    DateTime? birthDate,
    String? activationTime,
    int? iE,
    int? nS,
    int? tF,
    int? pJ,
    int? aileeChatCount,
    int? joonChatCount,
    int? nickChatCount,
    int? chadChatCount,
    int? rinChatCount,
    int? emotionCount,
    int? decisionCount,
    int? socialCount,
    int? identityCount,
    int? motivationCount,
    int? learningCount,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      mainCharacter: mainCharacter ?? this.mainCharacter,
      country: country ?? this.country,
      birthDate: birthDate ?? this.birthDate,
      activationTime: activationTime ?? this.activationTime,
      iE: iE ?? this.iE,
      nS: nS ?? this.nS,
      tF: tF ?? this.tF,
      pJ: pJ ?? this.pJ,
      aileeChatCount: aileeChatCount ?? this.aileeChatCount,
      joonChatCount: joonChatCount ?? this.joonChatCount,
      nickChatCount: nickChatCount ?? this.nickChatCount,
      chadChatCount: chadChatCount ?? this.chadChatCount,
      rinChatCount: rinChatCount ?? this.rinChatCount,
      emotionCount: emotionCount ?? this.emotionCount,
      decisionCount: decisionCount ?? this.decisionCount,
      socialCount: socialCount ?? this.socialCount,
      identityCount: identityCount ?? this.identityCount,
      motivationCount: motivationCount ?? this.motivationCount,
      learningCount: learningCount ?? this.learningCount,
    );
  }
}
