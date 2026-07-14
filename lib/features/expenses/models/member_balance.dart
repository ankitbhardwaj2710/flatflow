class MemberBalance {
  final String memberId;
  final String memberName;
  final double amount;

  const MemberBalance({
    required this.memberId,
    required this.memberName,
    required this.amount,
  });

  bool get owesYou => amount > 0;

  bool get youOwe => amount < 0;
}