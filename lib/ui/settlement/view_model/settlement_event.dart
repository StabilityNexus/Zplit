abstract class SettlementEvent {}

class SettleRequested extends SettlementEvent {
  final String friendWalletAddress;
  final double usdcAmount;

  SettleRequested({
    required this.friendWalletAddress,
    required this.usdcAmount,
  });
}

class SettlementReset extends SettlementEvent {}
