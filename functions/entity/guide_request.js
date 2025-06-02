// guide_requests 컬렉션 (오프라인 가이드 요청)
// 문서 ID: guideRequestId (자동 생성)
// {
//   from_user_id: string, // traveler
//   to_user_id: string,   // local
//   meeting_location: string,
//   scheduled_time: string, // ISO8601
//   duration: string, // 예: '3h'
//   status: 'pending' | 'accepted' | 'completed',
//   fee: number,
//   created_at: timestamp
// }

class GuideRequest {
  constructor(data) {
    this.from_user_id = data.from_user_id;
    this.to_user_id = data.to_user_id;
    this.meeting_location = data.meeting_location;
    this.scheduled_time = data.scheduled_time;
    this.duration = data.duration;
    this.status = data.status; // 'pending' | 'accepted' | 'completed'
    this.fee = data.fee;
    this.created_at = data.created_at;
  }
}

module.exports = GuideRequest; 