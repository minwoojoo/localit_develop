// purchase_requests 컬렉션 (구매/예약 대행 요청)
// 문서 ID: 자동 생성
// {
//   from_user_id: string,
//   to_user_id: string,
//   type: string, // ticket_purchase, restaurant_reservation 등
//   item_description: string,
//   status: 'pending' | 'accepted' | 'rejected' | 'completed',
//   payment_id: string,
//   created_at: timestamp
// }

class PurchaseRequest {
  constructor(data) {
    this.from_user_id = data.from_user_id;
    this.to_user_id = data.to_user_id;
    this.type = data.type;
    this.item_description = data.item_description;
    this.status = data.status; // 'pending' | 'accepted' | 'rejected' | 'completed'
    this.payment_id = data.payment_id;
    this.created_at = data.created_at;
  }
}

module.exports = PurchaseRequest;
