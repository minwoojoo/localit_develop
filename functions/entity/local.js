// locals 컬렉션 (현지인 전용 정보)
// 문서 ID: userId
// {
//   certified: boolean,
//   age: number,
//   gender: '남' | '여' | '기타',
//   preferred_meetup: '온' | '오프' | '둘 다',
//   preferred_location: string,
//   interests: string[],
//   hobbies: string,
//   verification_data: { ocr_id_image: string },
//   verification_status: 'pending' | 'approved' | 'rejected',
//   created_at: timestamp,
//   updated_at: timestamp
// }

class Local {
  constructor(data) {
    this.certified = data.certified;
    this.age = data.age;
    this.gender = data.gender; // '남' | '여' | '기타'
    this.preferred_meetup = data.preferred_meetup; // '온' | '오프' | '둘 다'
    this.preferred_location = data.preferred_location;
    this.interests = data.interests;
    this.hobbies = data.hobbies;
    this.verification_data = data.verification_data;
    this.verification_status = data.verification_status; // 'pending' | 'approved' | 'rejected'
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }
}

module.exports = Local; 