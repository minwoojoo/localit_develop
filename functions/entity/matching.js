// matchings 컬렉션 (매칭 요청)
// 문서 ID: matchingId (자동 생성)
// {
//   requester_id: string, // traveler
//   receiver_id: string,  // local
//   status: 'pending' | 'accepted' | 'rejected',
//   preferred_date: string, // YYYY-MM-DD
//   location: string,
//   message: string,
//   created_at: timestamp,
//   updated_at: timestamp
// }

class Matching {
  constructor(data) {
    this.requester_id = data.requester_id;
    this.receiver_id = data.receiver_id;
    this.status = data.status; // 'pending' | 'accepted' | 'rejected'
    this.preferred_date = data.preferred_date;
    this.location = data.location;
    this.message = data.message;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }
}

module.exports = Matching;
