class Payment {
  final String payerId;
  final String receiverId;
  final String type;
  final int amount;
  final String status;
  final String method;
  final String? relatedMatchingId;
  final String? relatedGuideId;
  final DateTime paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.payerId,
    required this.receiverId,
    required this.type,
    required this.amount,
    required this.status,
    required this.method,
    this.relatedMatchingId,
    this.relatedGuideId,
    required this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        payerId: json['payer_id'],
        receiverId: json['receiver_id'],
        type: json['type'],
        amount: json['amount'],
        status: json['status'],
        method: json['method'],
        relatedMatchingId: json['related_matching_id'],
        relatedGuideId: json['related_guide_id'],
        paidAt: DateTime.parse(json['paid_at']),
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'payer_id': payerId,
        'receiver_id': receiverId,
        'type': type,
        'amount': amount,
        'status': status,
        'method': method,
        'related_matching_id': relatedMatchingId,
        'related_guide_id': relatedGuideId,
        'paid_at': paidAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
