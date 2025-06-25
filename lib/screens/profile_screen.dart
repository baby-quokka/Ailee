import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_bot.dart';
import '../providers/auth_provider.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 선택된 봇 인덱스
  int selectedBotIndex = 0;

  // TODO: 봇별 사용자 설명 예시
  static const Map<String, String> userSummaries = {
    'ailee': 'Ailee가 본 사용자님은 긍정적이고, 새로운 것에 도전하는 성향이 강해요!',
    'ben': 'Ben이 본 사용자님은 논리적이고, 기술에 관심이 많아요.',
    'clara': 'Clara가 본 사용자님은 창의적이고, 아이디어가 넘쳐나요!',
    'david': 'David가 본 사용자님은 전략적이고, 목표 지향적이에요.',
    'emma': 'Emma가 본 사용자님은 학습에 열정적이고, 꾸준함이 돋보여요.',
  };

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('로그아웃'),
            content: const Text('정말 로그아웃하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('로그아웃'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<AuthProvider>().logout();
        // 로그아웃 성공 후 네비게이션
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        // 에러 발생 시 다이얼로그 표시
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('오류'),
                  content: Text('로그아웃 중 오류가 발생했습니다: ${e.toString()}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('확인'),
                    ),
                  ],
                ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bot = ChatBot.bots[selectedBotIndex];
    final summary = userSummaries[bot.id] ?? '';

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: Colors.grey[700]),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.grey[700]),
                onPressed: _logout,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 프로필 사진
                Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // 사용자 정보
                Padding(
                  padding: const EdgeInsets.only(left: 48.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.username ?? '사용자',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentUser?.email ?? '@user',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // TODO: 팔로잉/팔로워 (현재 더미 데이터)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => Scaffold(
                                    appBar: AppBar(
                                      title: Text('팔로워'),
                                      leading: IconButton(
                                        icon: Icon(Icons.arrow_back),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                    body: ListView(
                                      children: [
                                        ListTile(
                                          leading: CircleAvatar(
                                            child: Icon(Icons.person),
                                          ),
                                          title: Text('김민수'),
                                          subtitle: Text('@minsu_kim'),
                                        ),
                                        ListTile(
                                          leading: CircleAvatar(
                                            child: Icon(Icons.person),
                                          ),
                                          title: Text('이지은'),
                                          subtitle: Text('@jieun_lee'),
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              '2',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('팔로워', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      child: VerticalDivider(color: Colors.grey, thickness: 1),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => Scaffold(
                                    appBar: AppBar(
                                      title: Text('팔로잉'),
                                      leading: IconButton(
                                        icon: Icon(Icons.arrow_back),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                    body: ListView(
                                      children: [
                                        ListTile(
                                          leading: CircleAvatar(
                                            child: Icon(Icons.person),
                                          ),
                                          title: Text('박서연'),
                                          subtitle: Text('@seoyeon_park'),
                                        ),
                                        ListTile(
                                          leading: CircleAvatar(
                                            child: Icon(Icons.person),
                                          ),
                                          title: Text('최준호'),
                                          subtitle: Text('@junho_choi'),
                                        ),
                                        ListTile(
                                          leading: CircleAvatar(
                                            child: Icon(Icons.person),
                                          ),
                                          title: Text('정다은'),
                                          subtitle: Text('@daeun_jung'),
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              '3',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('팔로잉', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // 친구 추가 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('+ 팔로우하기', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // 파트너 영역
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 캐릭터 이미지와 이름 + 드롭다운
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue[100],
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.blue[400],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: DropdownButton<int>(
                              value: selectedBotIndex,
                              items: List.generate(ChatBot.bots.length, (idx) {
                                return DropdownMenuItem(
                                  value: idx,
                                  child: Text(ChatBot.bots[idx].name),
                                );
                              }),
                              onChanged: (idx) {
                                if (idx != null) {
                                  setState(() => selectedBotIndex = idx);
                                }
                              },
                              underline: SizedBox(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              icon: Icon(Icons.arrow_drop_down),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      // 말풍선 영역
                      Expanded(
                        child: Container(
                          width: 250,
                          height: 100,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            summary,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // 활동 등 추가 영역 (참여한 콘텐츠)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    children: List.generate(
                      3, // TODO: 임시 갯수
                      (idx) => Container(
                        margin: EdgeInsets.only(bottom: 16),
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Text(
                            '참여한 콘텐츠 ${idx + 1}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
