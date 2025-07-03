// chat_rooms 컬렉션 (1:1 채팅방 정보)
// 문서 ID: chatRoomId (자동 생성)
// {
//   traveler_id: string,
//   local_id: string,
//   related_match_id: string, // 어떤 매칭 요청에 의해 생성되었는지
//   created_at: timestamp
// }

class ChatRoom {
  constructor(data) {
    this.traveler_id = data.traveler_id;
    this.local_id = data.local_id;
    this.related_match_id = data.related_match_id;
    this.created_at = data.created_at;
  }
}

module.exports = ChatRoom;
