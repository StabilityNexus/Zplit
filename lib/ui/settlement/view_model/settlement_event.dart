abstract class SettlementEvent {}

/// User tapped "Pay". The USDC amount is derived from [balanceInInr] inside
/// the service with integer maths, so the UI never passes a double of money.
class SettleRequested extends SettlementEvent {
  final String friendWalletAddress;
  final double balanceInInr;

  /// The payer's own wallet address (the account that will pay from MetaMask).
  /// When given, Zplit notes the current block and, after the user returns,
  /// looks up a USDC transfer FROM this address TO the friend — so there is
  /// no hash to paste. Empty = the paste-a-hash flow only.
  final String payerAddress;

  /// Used to save a session so the payment can still be found if Android
  /// kills Zplit while the wallet is open. Empty = no session.
  final String friendPublicKey;
  final String friendName;

  /// true = open MetaMask's own link instead of a generic `ethereum:` link.
  final bool useMetaMask;

  SettleRequested({
    required this.friendWalletAddress,
    required this.balanceInInr,
    this.payerAddress = '',
    this.friendPublicKey = '',
    this.friendName = '',
    this.useMetaMask = false,
  });
}

/// The app came back to the foreground after the wallet was opened
/// (or the user tapped "I've finished in my wallet").
class SettlementReturned extends SettlementEvent {}

/// The automatic lookup did not find the payment yet (e.g. not mined): look
/// again by payer address.
class SettlementCheckAgainRequested extends SettlementEvent {}

/// User pasted a tx hash to verify on-chain.
class SettlementVerifyRequested extends SettlementEvent {
  final String txHash;
  final String friendWalletAddress;
  final double balanceInInr;

  SettlementVerifyRequested({
    required this.txHash,
    required this.friendWalletAddress,
    required this.balanceInInr,
  });
}

/// User says they paid but has no hash. Recorded as NOT verified.
class SettlementPaidClaimed extends SettlementEvent {}

class SettlementReset extends SettlementEvent {}
