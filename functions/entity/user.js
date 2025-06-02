// users 컬렉션 (공통 사용자 정보)
// 문서 ID: Firebase Auth UID (userId)
// {
//   email: string,
//   nickname: string,
//   phone_number: string,
//   type: 'traveler' | 'local',
//   profileImageUrl: string,
//   languages: string[],
//   trust_score: number,
//   created_at: timestamp,
//   updated_at: timestamp
// }

class User {
  constructor(data) {
    this.email = data.email;
    this.nickname = data.nickname;
    this.phone_number = data.phone_number;
    this.type = data.type; // 'traveler' | 'local'
    this.profileImageUrl = data.profileImageUrl;
    this.languages = data.languages;
    this.trust_score = data.trust_score;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }
}

module.exports = User; 