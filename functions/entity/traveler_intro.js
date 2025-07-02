// traveler_intros 컬렉션 (여행객 소개글)
// 문서 ID: introId (자동 생성)
// {
//   traveler_id: string,
//   title: string,
//   content: string,
//   location: string,
//   preferred_meetup: '온' | '오프' | '둘 다',
//   travel_theme: string[],
//   created_at: timestamp,
//   updated_at: timestamp
// }

class TravelerIntro {
  constructor(data) {
    this.traveler_id = data.traveler_id;
    this.title = data.title;
    this.content = data.content;
    this.location = data.location;
    this.preferred_meetup = data.preferred_meetup;
    this.travel_theme = data.travel_theme;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }
}

module.exports = TravelerIntro;
