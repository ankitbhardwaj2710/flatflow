class SettlementModel {
  final String memberId;
  final String memberName;

  final double youOwe;
  final double owesYou;

  const SettlementModel({
    required this.memberId,
    required this.memberName,
    required this.youOwe,
    required this.owesYou,
  });

  double get netBalance => owesYou - youOwe;

  bool get isSettled =>
      youOwe == 0 && owesYou == 0;

  bool get shouldPay =>
      netBalance < 0;

  bool get shouldReceive =>
      netBalance > 0;
}