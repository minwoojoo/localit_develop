// chat_rooms/{chatRoomId}/messages 서브컬렉션 (메시지)
// 문서 ID: messageId (자동 생성)
// {
//   sender_id: string,
//   message: string,
//   translated_message: string,
//   type: 'text' | 'image' | 'location',
//   created_at: timestamp
// }

class ChatMessage {
  constructor(data) {
    this.sender_id = data.sender_id;
    this.message = data.message;
    this.translated_message = data.translated_message;
    this.type = data.type; // 'text' | 'image' | 'location'
    this.created_at = data.created_at;
  }
}

module.exports = ChatMessage;
