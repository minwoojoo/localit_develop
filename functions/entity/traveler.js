// travelers 컬렉션 (여행객 추가 정보)
// 문서 ID: userId
// {
//   preferred_regions: string[],
//   travel_style: string[],
//   created_at: timestamp,
//   updated_at: timestamp
// }

class Traveler {
  constructor(data) {
    this.preferred_regions = data.preferred_regions;
    this.travel_style = data.travel_style;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }
}

module.exports = Traveler;
