// locals 컬렉션 (현지인 전용 정보)
// 문서 ID: userId
// {
//   "nickname": "",
//   "certified": true, // false
//   "age": 28,
//   "gender": "남",   // '남' | '여' | '기타'
//   "profile_image_url": "",
//   "preferred_meetup": "오프",  // '온' | '오프' | '둘 다' 중 하나
//   "preferred_location": "Hongdae",
//   "interests": ["food", "culture"], 
//   "hobbies": "등산, 사진",
//   "verification_status": "approved",  // 'pending' | 'approved' | 'rejected'
//   "introduction": "",
//   "created_at": "timestamp",
//   "updated_at": "timestamp",
//   "manner_score": 60.0, // 매너 온도: 0.0 ~ 100.0  기본값 60
//   "school_or_company": "", // 예시) "연세대학교", "삼성전자"
//   "match_count": 0, // 지금까지 완료된 매칭 횟수  기본값 0
//   "tags": [],  // 예시) ["#친절한", "#사진잘찍는", "#맛집고수"]
//   "personal_info": ""
// }

class Local {
  constructor(data) {
    this.nickname = data.nickname || "";
    this.certified = data.certified || false;
    this.age = data.age;
    this.gender = data.gender; // '남' | '여' | '기타'
    this.profile_image_url = data.profile_image_url || "";
    this.preferred_meetup = data.preferred_meetup; // '온' | '오프' | '둘 다' 중 하나
    this.preferred_location = data.preferred_location || "";
    this.interests = data.interests || [];
    this.hobbies = data.hobbies || "";
    this.verification_status = data.verification_status || 'pending'; // 'pending' | 'approved' | 'rejected'
    this.introduction = data.introduction || "";
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
    this.manner_score = data.manner_score || 60.0; // 매너 온도: 0.0 ~ 100.0  기본값 60
    this.school_or_company = data.school_or_company || ""; // 예시) "연세대학교", "삼성전자"
    this.match_count = data.match_count || 0; // 지금까지 완료된 매칭 횟수  기본값 0
    this.tags = data.tags || []; // 예시) ["#친절한", "#사진잘찍는", "#맛집고수"]
    this.personal_info = data.personal_info || "";
  }
}

module.exports = Local;
