class PurchaseRequest {
  final String fromUserId;
  final String toUserId;
  final String type;
  final String itemDescription;
  final String status;
  final String paymentId;
  final DateTime createdAt;

  PurchaseRequest({
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.itemDescription,
    required this.status,
    required this.paymentId,
    required this.createdAt,
  });

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) =>
      PurchaseRequest(
        fromUserId: json['from_user_id'],
        toUserId: json['to_user_id'],
        type: json['type'],
        itemDescription: json['item_description'],
        status: json['status'],
        paymentId: json['payment_id'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'type': type,
        'item_description': itemDescription,
        'status': status,
        'payment_id': paymentId,
        'created_at': createdAt.toIso8601String(),
      };
}
