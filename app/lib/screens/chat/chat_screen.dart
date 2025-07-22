import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_room_screen.dart';
import 'package:localit/screens/matching/home_screen.dart';
import 'package:localit/screens/commerce/purchase_agency_screen.dart';
import 'package:localit/screens/community/community_home_screen.dart';
import 'package:localit/screens/common/menu_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedIndex = 2; // 메시지 탭이 선택된 상태

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('로그인이 필요합니다'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '💬 채팅',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .where('traveler_id', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, travelerSnapshot) {
          if (travelerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chat_rooms')
                .where('local_id', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, localSnapshot) {
              if (localSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // 여행자와 로컬인 채팅방을 모두 가져와서 합치기
              List<QueryDocumentSnapshot> allChatRooms = [];

              if (travelerSnapshot.hasData) {
                allChatRooms.addAll(travelerSnapshot.data!.docs);
              }

              if (localSnapshot.hasData) {
                allChatRooms.addAll(localSnapshot.data!.docs);
              }

              // 중복 제거 (같은 채팅방이 두 번 나타날 수 있음)
              final uniqueChatRooms = <String, QueryDocumentSnapshot>{};
              for (var doc in allChatRooms) {
                uniqueChatRooms[doc.id] = doc;
              }

              final chatRooms = uniqueChatRooms.values.toList();

              // 생성일 기준으로 정렬 (메모리에서 정렬)
              chatRooms.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aTime = aData['created_at'] as Timestamp?;
                final bTime = bData['created_at'] as Timestamp?;

                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;

                return bTime.compareTo(aTime); // 최신순 정렬
              });

              if (chatRooms.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '아직 채팅방이 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '로컬인과 매칭이 완료되면\n채팅방이 생성됩니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  final chatRoom = chatRooms[index];
                  final chatRoomData = chatRoom.data() as Map<String, dynamic>;

                  // 현재 사용자가 여행자인지 로컬인인지 확인
                  final isTraveler = chatRoomData['traveler_id'] == user.uid;
                  final otherUserId = isTraveler
                      ? chatRoomData['local_id']
                      : chatRoomData['traveler_id'];

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      String nickname = '알 수 없음';
                      String? profileImageUrl;

                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        try {
                          final userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          nickname = userData['nickname'] ?? '알 수 없음';
                          profileImageUrl = userData['profile_image_url'];
                        } catch (e) {
                          print('사용자 데이터 파싱 오류: $e');
                          nickname = '알 수 없음';
                          profileImageUrl = null;
                        }
                      }

                      // chat_rooms 컬렉션의 traveler_id/local_id에 따라 프로필 결정
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('locals')
                            .where('user_id', isEqualTo: otherUserId)
                            .snapshots(),
                        builder: (context, localSnapshot) {
                          String finalNickname = nickname;
                          String? finalProfileImageUrl = profileImageUrl;

                          // chat_rooms에서 상대방이 traveler_id인지 local_id인지 확인
                          bool isOtherUserTraveler =
                              chatRoomData['traveler_id'] == otherUserId;
                          bool isOtherUserLocal =
                              chatRoomData['local_id'] == otherUserId;

                          // 상대방이 traveler_id인 경우 무조건 기본 프로필 사용
                          if (isOtherUserTraveler) {
                            finalNickname = nickname;
                            finalProfileImageUrl = profileImageUrl;
                          } else if (isOtherUserLocal) {
                            // 상대방이 local_id인 경우 로컬인 프로필 확인
                            if (localSnapshot.hasData &&
                                localSnapshot.data!.docs.isNotEmpty) {
                              try {
                                final localData = localSnapshot.data!.docs.first
                                    .data() as Map<String, dynamic>;
                                final localNickname = localData['nickname'];
                                if (localNickname != null &&
                                    localNickname.isNotEmpty) {
                                  finalNickname = localNickname; // 로컬인 닉네임 사용
                                }
                                // 로컬인 프로필 이미지 사용
                                final localProfileImageUrl =
                                    localData['profile_image_url'];
                                if (localProfileImageUrl != null &&
                                    localProfileImageUrl.isNotEmpty) {
                                  finalProfileImageUrl = localProfileImageUrl;
                                }
                              } catch (e) {
                                print('로컬인 데이터 파싱 오류: $e');
                              }
                            }
                          }

                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('chat_rooms')
                                .doc(chatRoom.id)
                                .collection('messages')
                                .where('sender_id', isNotEqualTo: user.uid)
                                .snapshots(),
                            builder: (context, unreadSnapshot) {
                              int unreadCount = 0;

                              if (unreadSnapshot.hasData) {
                                // 읽지 않은 메시지 = 상대방이 보낸 메시지 중 내가 읽지 않은 것
                                for (var doc in unreadSnapshot.data!.docs) {
                                  final messageData =
                                      doc.data() as Map<String, dynamic>;
                                  final readBy = messageData['read_by'];

                                  // read_by 필드가 없거나 배열이 아닌 경우 빈 배열로 초기화
                                  List<String> readByList = [];
                                  if (readBy != null && readBy is List) {
                                    readByList = List<String>.from(readBy);
                                  }

                                  // 내가 읽지 않은 메시지인지 확인
                                  if (!readByList.contains(user.uid)) {
                                    unreadCount++;
                                  }
                                }
                              }

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      finalProfileImageUrl != null &&
                                              finalProfileImageUrl.isNotEmpty
                                          ? NetworkImage(finalProfileImageUrl)
                                          : null,
                                  backgroundColor: Colors.grey[300],
                                  child: finalProfileImageUrl == null ||
                                          finalProfileImageUrl.isEmpty
                                      ? const Icon(Icons.person,
                                          color: Colors.white)
                                      : null,
                                ),
                                title: Text(finalNickname),
                                subtitle: Text(
                                  isTraveler ? '로컬인과의 채팅' : '여행자와의 채팅',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: SizedBox(
                                  height: 48,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(chatRoomData['created_at']),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (unreadCount > 0) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            unreadCount.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        const SizedBox(
                                            height: 16), // 빈 공간으로 높이 맞춤
                                      ],
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                        chatRoomId: chatRoom.id,
                                        otherUserId: otherUserId,
                                        otherUserNickname: finalNickname,
                                        otherUserProfileImage:
                                            finalProfileImageUrl,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // 네비게이션 처리
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const PurchaseAgencyScreen()),
              );
              break;
            case 2:
              // 현재 화면이므로 아무것도 하지 않음
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const CommunityHomeScreen()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MenuScreen()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: '구매대행',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send_outlined),
            label: '메시지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.all_inclusive),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '메뉴',
          ),
        ],
      ),
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final time = timestamp.toDate();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
