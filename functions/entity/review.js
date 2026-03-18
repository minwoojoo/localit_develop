// reviews 컬렉션 (후기 및 평점)
// 문서 ID: reviewId (자동 생성)
// {
//   from_user_id: string,
//   to_user_id: string,
//   related_service: 'guide' | 'purchase',
//   related_id: string,
//   rating: number,
//   comment: string,
//   created_at: timestamp
// }

class Review {
  constructor(data) {
    this.from_user_id = data.from_user_id;
    this.to_user_id = data.to_user_id;
    this.related_service = data.related_service;
    this.related_id = data.related_id;
    this.rating = data.rating;
    this.comment = data.comment;
    this.created_at = data.created_at;
  }
}
module.exports = Review;
