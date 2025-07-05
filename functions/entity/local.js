// locals 컬렉션 (현지인 전용 정보)
// 문서 ID: userId
// {
//   certified: boolean, // false
//   age: number,
//   gender: '남' | '여' | '기타'
//   profile_image_url: string,
//   preferred_meetup: '온' | '오프' | '둘 다' 중 하나
//   preferred_location: string,
//   interests: string[],
//   hobbies: string,
//   verification_data: { ocr_id_image: string }, // 주민등록 사진을 이용한 인증방법은 mvp단계에서는 부담될 수도 있어 전화번호 인증으로 바꿨습니다.
//   verification_status: 'pending' | 'approved' | 'rejected',
//   introduction: string,
//   created_at: timestamp,
//   updated_at: timestamp
// }

class Local {
  constructor(data) {
    this.certified = data.certified;
    this.age = data.age;
    this.gender = data.gender; // '남' | '여' | '기타'
    this.profile_image_url = data.profile_image_url;
    this.preferred_meetup = data.preferred_meetup; // '온' | '오프' | '둘 다' 중 하나
    this.preferred_location = data.preferred_location;
    this.interests = data.interests;
    this.hobbies = data.hobbies;
    this.verification_data = data.verification_data; // 주민등록 사진을 이용한 인증방법은 mvp단계에서는 부담될 수도 있어 전화번호 인증으로 바꿨습니다.
    this.verification_status = data.verification_status; // 'pending' | 'approved' | 'rejected'
    this.introduction = data.introduction;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }
}

module.exports = Local;
