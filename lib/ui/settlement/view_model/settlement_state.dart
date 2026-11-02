class SettlementResult {
  final bool verified;
  final String? txHash;

  final bool pending;

  const SettlementResult({
    required this.verified,
    this.txHash,
    this.pending = false,
  });
}

abstract class SettlementState {
  const SettlementState();
}

class SettlementInitial extends SettlementState {
  const SettlementInitial();
}

class SettlementLaunching extends SettlementState {
  const SettlementLaunching();
}

class SettlementAwaitingReturn extends SettlementState {
  const SettlementAwaitingReturn();
}

class SettlementConfirming extends SettlementState {
  final String? notice;
  const SettlementConfirming({this.notice});
}

class SettlementVerifying extends SettlementState {
  const SettlementVerifying();
}

class SettlementVerified extends SettlementState {
  final String txHash;
  final String message;
  const SettlementVerified(this.txHash, this.message);
}

class SettlementPending extends SettlementState {
  final String txHash;
  final String message;
  const SettlementPending(this.txHash, this.message);
}

class SettlementSelfReported extends SettlementState {
  const SettlementSelfReported();
}

class SettlementNoWalletFound extends SettlementState {
  const SettlementNoWalletFound();
}

class SettlementError extends SettlementState {
  final String message;
  const SettlementError(this.message);
}
