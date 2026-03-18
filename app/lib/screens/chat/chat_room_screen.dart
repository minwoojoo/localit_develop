import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserId;
  final String otherUserNickname;
  final String? otherUserProfileImage;

  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUserId,
    required this.otherUserNickname,
    this.otherUserProfileImage,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _currentUserId;
  bool _hasMarkedAsRead = false; // 읽음 처리 중복 방지

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // 채팅방에 들어가면 자동으로 메시지를 읽음 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      _markMessagesAsRead();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 메시지를 읽음 처리하는 함수
  Future<void> _markMessagesAsRead() async {
    if (_currentUserId == null) {
      print('DEBUG: _currentUserId가 null입니다');
      return;
    }

    print(
        'DEBUG: 읽음 처리 시작 - 채팅방: ${widget.chatRoomId}, 상대방: ${widget.otherUserId}, 나: $_currentUserId');

    try {
      // 상대방이 보낸 메시지 중 아직 읽지 않은 것들을 찾아서 읽음 처리
      final unreadMessages = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .where('sender_id', isEqualTo: widget.otherUserId)
          .get();

      print('DEBUG: 상대방이 보낸 메시지 개수: ${unreadMessages.docs.length}');

      // 읽음 처리 (read_by 배열에 현재 사용자 ID 추가)
      final batch = FirebaseFirestore.instance.batch();
      int updatedCount = 0;

      for (var doc in unreadMessages.docs) {
        final messageData = doc.data() as Map<String, dynamic>;
        final readBy = messageData['read_by'];

        // read_by 필드가 없거나 배열이 아닌 경우 빈 배열로 초기화
        List<String> readByList = [];
        if (readBy != null && readBy is List) {
          readByList = List<String>.from(readBy);
        }

        print('DEBUG: 메시지 ${doc.id} - read_by: $readByList');

        // 아직 읽지 않은 메시지인 경우에만 읽음 처리
        if (!readByList.contains(_currentUserId)) {
          batch.update(doc.reference, {
            'read_by': FieldValue.arrayUnion([_currentUserId])
          });
          updatedCount++;
          print('DEBUG: 메시지 ${doc.id} 읽음 처리됨');
        }
      }

      if (updatedCount > 0) {
        await batch.commit();
        print('DEBUG: $updatedCount개 메시지 읽음 처리 완료');
      } else {
        print('DEBUG: 읽음 처리할 메시지가 없습니다');
      }
    } catch (e) {
      print('메시지 읽음 처리 오류: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add({
        'sender_id': currentUser.uid,
        'content': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
        'read_by': [], // 읽은 사용자 ID 배열 (초기값은 빈 배열)
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지 전송 실패: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.otherUserId)
              .snapshots(),
          builder: (context, userSnapshot) {
            String nickname = widget.otherUserNickname;
            String? profileImageUrl = widget.otherUserProfileImage;

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              try {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                nickname = userData['nickname'] ?? widget.otherUserNickname;
                profileImageUrl = userData['profile_image_url'];
              } catch (e) {
                print('사용자 데이터 파싱 오류: $e');
              }
            }

            // chat_rooms 컬렉션의 traveler_id/local_id에 따라 프로필 결정
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(widget.chatRoomId)
                  .snapshots(),
              builder: (context, chatRoomSnapshot) {
                String finalNickname = nickname;
                String? finalProfileImageUrl = profileImageUrl;

                if (chatRoomSnapshot.hasData && chatRoomSnapshot.data!.exists) {
                  try {
                    final chatRoomData =
                        chatRoomSnapshot.data!.data() as Map<String, dynamic>;

                    // chat_rooms에서 상대방이 traveler_id인지 local_id인지 확인
                    bool isOtherUserTraveler =
                        chatRoomData['traveler_id'] == widget.otherUserId;
                    bool isOtherUserLocal =
                        chatRoomData['local_id'] == widget.otherUserId;

                    // 상대방이 traveler_id인 경우 무조건 기본 프로필 사용
                    if (isOtherUserTraveler) {
                      finalNickname = nickname;
                      finalProfileImageUrl = profileImageUrl;
                    } else if (isOtherUserLocal) {
                      // 상대방이 local_id인 경우 로컬인 프로필 확인
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('locals')
                            .where('user_id', isEqualTo: widget.otherUserId)
                            .snapshots(),
                        builder: (context, localSnapshot) {
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

                          return _buildAppBarTitle(
                              finalNickname, finalProfileImageUrl);
                        },
                      );
                    }
                  } catch (e) {
                    print('채팅방 데이터 파싱 오류: $e');
                  }
                }

                return _buildAppBarTitle(finalNickname, finalProfileImageUrl);
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black),
            onPressed: () {
              // 전화 통화 기능
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black),
            onPressed: () {
              // 영상 통화 기능
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 채팅 메시지 영역
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                          '아직 메시지가 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '첫 번째 메시지를 보내보세요!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs;
                final currentUser = FirebaseAuth.instance.currentUser;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageData = message.data() as Map<String, dynamic>;
                    final isMe = messageData['sender_id'] == currentUser?.uid;
                    final timestamp = messageData['timestamp'] as Timestamp?;
                    final content = messageData['content'] ?? '';

                    // read_by 필드 안전하게 처리
                    final readByData = messageData['read_by'];
                    List<String> readBy = [];
                    if (readByData != null && readByData is List) {
                      readBy = List<String>.from(readByData);
                    }

                    // 시간 표시 로직
                    bool showTime = true;
                    if (index > 0) {
                      final prevMessage = messages[index - 1];
                      final prevData =
                          prevMessage.data() as Map<String, dynamic>;
                      final prevTimestamp = prevData['timestamp'] as Timestamp?;

                      if (timestamp != null && prevTimestamp != null) {
                        final timeDiff = timestamp
                            .toDate()
                            .difference(prevTimestamp.toDate());
                        showTime = timeDiff.inMinutes >= 5; // 5분 이상 차이나면 시간 표시
                      }
                    }

                    return Column(
                      children: [
                        if (showTime && timestamp != null) ...[
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatTime(timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                        _buildMessageBubble(isMe, content, timestamp, readBy),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          // 메시지 입력 영역
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.blue),
                  onPressed: () {
                    // 파일 첨부
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Aa',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions, color: Colors.blue),
                  onPressed: () {
                    // 이모지 선택
                  },
                ),
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: Colors.blue),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      bool isMe, String content, Timestamp? timestamp, List<String> readBy) {
    // 상대방이 읽었는지 확인 (안전한 타입 체크)
    bool isRead = false;
    if (readBy.isNotEmpty) {
      isRead = readBy.contains(widget.otherUserId);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.otherUserId)
                  .snapshots(),
              builder: (context, userSnapshot) {
                String? profileImageUrl = widget.otherUserProfileImage;

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  try {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    profileImageUrl = userData['profile_image_url'];
                  } catch (e) {
                    print('사용자 데이터 파싱 오류: $e');
                  }
                }

                // chat_rooms 컬렉션의 traveler_id/local_id에 따라 프로필 결정
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chat_rooms')
                      .doc(widget.chatRoomId)
                      .snapshots(),
                  builder: (context, chatRoomSnapshot) {
                    String? finalProfileImageUrl = profileImageUrl;

                    if (chatRoomSnapshot.hasData &&
                        chatRoomSnapshot.data!.exists) {
                      try {
                        final chatRoomData = chatRoomSnapshot.data!.data()
                            as Map<String, dynamic>;

                        // chat_rooms에서 상대방이 traveler_id인지 local_id인지 확인
                        bool isOtherUserTraveler =
                            chatRoomData['traveler_id'] == widget.otherUserId;
                        bool isOtherUserLocal =
                            chatRoomData['local_id'] == widget.otherUserId;

                        // 상대방이 traveler_id인 경우 무조건 기본 프로필 사용
                        if (isOtherUserTraveler) {
                          finalProfileImageUrl = profileImageUrl;
                        } else if (isOtherUserLocal) {
                          // 상대방이 local_id인 경우 로컬인 프로필 확인
                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('locals')
                                .where('user_id', isEqualTo: widget.otherUserId)
                                .snapshots(),
                            builder: (context, localSnapshot) {
                              if (localSnapshot.hasData &&
                                  localSnapshot.data!.docs.isNotEmpty) {
                                try {
                                  final localData =
                                      localSnapshot.data!.docs.first.data()
                                          as Map<String, dynamic>;
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

                              return CircleAvatar(
                                radius: 16,
                                backgroundImage: finalProfileImageUrl != null &&
                                        finalProfileImageUrl!.isNotEmpty
                                    ? NetworkImage(finalProfileImageUrl!)
                                    : null,
                                backgroundColor: Colors.grey[300],
                                child: finalProfileImageUrl == null ||
                                        finalProfileImageUrl!.isEmpty
                                    ? const Icon(Icons.person,
                                        color: Colors.white, size: 16)
                                    : null,
                              );
                            },
                          );
                        }
                      } catch (e) {
                        print('채팅방 데이터 파싱 오류: $e');
                      }
                    }

                    return CircleAvatar(
                      radius: 16,
                      backgroundImage: finalProfileImageUrl != null &&
                              finalProfileImageUrl!.isNotEmpty
                          ? NetworkImage(finalProfileImageUrl!)
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: finalProfileImageUrl == null ||
                              finalProfileImageUrl!.isEmpty
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 16)
                          : null,
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isRead ? Icons.done_all : Icons.done,
                          size: 16,
                          color: isRead ? Colors.blue : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final time = timestamp.toDate();
    final now = DateTime.now();

    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return '오늘 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatMessageTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final time = timestamp.toDate();
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildAppBarTitle(String nickname, String? profileImageUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
              ? NetworkImage(profileImageUrl)
              : null,
          backgroundColor: Colors.grey[300],
          child: profileImageUrl == null || profileImageUrl.isEmpty
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nickname,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                '온라인',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
