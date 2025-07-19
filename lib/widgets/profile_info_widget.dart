import 'package:flutter/material.dart';
import '../models/chat/chat_bot.dart';
import '../models/user.dart';

class ProfileInfoWidget extends StatelessWidget {
  final User? currentUser;
  final int selectedBotIndex;
  final ValueChanged<int> onBotChanged;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;
  final int followersCount;
  final int followingCount;

  const ProfileInfoWidget({
    super.key,
    required this.currentUser,
    required this.selectedBotIndex,
    required this.onBotChanged,
    required this.onFollowersTap,
    required this.onFollowingTap,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bot = ChatBot.bots[selectedBotIndex];
    final summary = _getUserSummary(bot.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 프로필 사진
        Container(
          width: double.infinity,
          height: 150,
          color: Colors.grey[200],
          child: Center(
            child: Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
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
                  currentUser?.name ?? '사용자',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
        // 팔로잉/팔로워
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onFollowersTap,
                child: Column(
                  children: [
                    Text(
                      followersCount.toString(),
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
                onTap: onFollowingTap,
                child: Column(
                  children: [
                    Text(
                      followingCount.toString(),
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
        SizedBox(height: 16),
        // 파트너 영역
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                          onBotChanged(idx);
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
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
              3,
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
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getUserSummary(String botId) {
    const Map<String, String> userSummaries = {
      'ailee': 'Ailee가 본 사용자님은 긍정적이고, 새로운 것에 도전하는 성향이 강해요!',
      'joon': 'Joon이 본 사용자님은 논리적이고, 기술에 관심이 많아요.',
      'rin': 'Rin이 본 사용자님은 창의적이고, 아이디어가 넘쳐나요!',
      'nick': 'Nick이 본 사용자님은 전략적이고, 목표 지향적이에요.',
      'chad': 'Chad가 본 사용자님은 학습에 열정적이고, 꾸준함이 돋보여요.',
    };
    return userSummaries[botId] ?? '';
  }
}
