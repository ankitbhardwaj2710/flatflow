class SettlementModel {
  final String memberId;
  final String memberName;

  final double youOwe;
  final double owesYou;

  final bool shouldPay;
  final bool shouldReceive;
  final bool isSettled;

  const SettlementModel({
    required this.memberId,
    required this.memberName,
    required this.youOwe,
    required this.owesYou,
    required this.shouldPay,
    required this.shouldReceive,
    required this.isSettled,
  });

  double get netBalance => owesYou - youOwe;

  SettlementModel copyWith({
    String? memberId,
    String? memberName,
    double? youOwe,
    double? owesYou,
    bool? shouldPay,
    bool? shouldReceive,
    bool? isSettled,
  }) {
    return SettlementModel(
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      youOwe: youOwe ?? this.youOwe,
      owesYou: owesYou ?? this.owesYou,
      shouldPay: shouldPay ?? this.shouldPay,
      shouldReceive:
          shouldReceive ?? this.shouldReceive,
      isSettled:
          isSettled ?? this.isSettled,
    );
  }
}