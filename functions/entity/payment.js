// payments 컬렉션 (결제 내역)
// 문서 ID: paymentId (자동 생성)
// {
//   payer_id: string, // 결제한 사용자 (여행객)
//   receiver_id: string, // 결제를 받는 현지인 (해당 없으면 null)
//   type: 'guide_fee' | 'reservation_fee',
//   amount: number,
//   status: 'completed' | 'pending' | 'failed' | 'refunded',
//   method: 'card' | 'kakaopay' | 'naverpay',
//   related_matching_id?: string,
//   related_guide_id?: string,
//   paid_at: string, // ISO8601
//   created_at: string, // ISO8601
//   updated_at: string // ISO8601
// }

class Payment {
  constructor(data) {
    this.payer_id = data.payer_id;
    this.receiver_id = data.receiver_id;
    this.type = data.type;
    this.amount = data.amount;
    this.status = data.status;
    this.method = data.method;
    this.related_matching_id = data.related_matching_id;
    this.related_guide_id = data.related_guide_id;
    this.paid_at = data.paid_at;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }
}
module.exports = Payment; 