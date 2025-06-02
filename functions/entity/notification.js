// notifications 컬렉션 (알림 메시지 저장)
// 문서 ID: notificationId (자동 생성)
// {
//   user_id: string,
//   title: string,
//   body: string,
//   type: string, // match_request 등
//   is_read: boolean,
//   created_at: timestamp
// }

class Notification {
  constructor(data) {
    this.user_id = data.user_id;
    this.title = data.title;
    this.body = data.body;
    this.type = data.type;
    this.is_read = data.is_read;
    this.created_at = data.created_at;
  }
}
module.exports = Notification; 