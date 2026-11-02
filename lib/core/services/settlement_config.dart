/// Settings for USDC settlement: which chain / token / FX rate to use.
///
/// Zplit opens the user's wallet app with a pre-filled transfer, then looks
/// for the payment on-chain through the public [rpcUrl] node.
///
/// IMPORTANT: [active] defaults to the Sepolia TESTNET so nobody can lose real
/// money while testing. Switch to [mainnet] (or add Y Chain) only when ready,
/// and verify every address against Circle's / the chain's official docs.
class SettlementNetwork {
  final int chainId;
  final String name;

  /// Public JSON-RPC node used to look up receipts and logs.
  final String rpcUrl;

  /// Block explorer base URL, used for the "View transaction" link.
  final String explorerUrl;

  final String usdcAddress;
  final bool isTestnet;

  const SettlementNetwork({
    required this.chainId,
    required this.name,
    required this.rpcUrl,
    required this.explorerUrl,
    required this.usdcAddress,
    required this.isTestnet,
  });

  String txUrl(String hash) => '$explorerUrl/tx/$hash';
}

class SettlementConfig {
  SettlementConfig._();

  /// TODO: replace with a live INR -> USD rate. Kept in ONE place so the
  /// friend screen and the settlement screen can never disagree.
  static const double inrPerUsd = 83.0;

  /// true once [inrPerUsd] is fetched from a live API instead of the
  /// constant. The settlement screen shows the "Rates By Exchange Rate API"
  /// credit only when this is true.
  static const bool rateIsLive = false;

  static const int usdcDecimals = 6;

  /// Kept so any code that references it keeps compiling.
  static const bool clearPayerBalanceImmediately = true;

  static const SettlementNetwork sepolia = SettlementNetwork(
    chainId: 11155111,
    name: 'Sepolia',
    rpcUrl: 'https://ethereum-sepolia-rpc.publicnode.com',
    explorerUrl: 'https://sepolia.etherscan.io',
    // Circle's test USDC on Sepolia.
    usdcAddress: '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238',
    isTestnet: true,
  );

  static const SettlementNetwork mainnet = SettlementNetwork(
    chainId: 1,
    name: 'Ethereum',
    rpcUrl: 'https://ethereum-rpc.publicnode.com',
    explorerUrl: 'https://etherscan.io',
    usdcAddress: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
    isTestnet: false,
  );

  // TODO(Y Chain): add a SettlementNetwork for Y Chain here (chainId, rpc,
  // explorer, USDC contract on that chain) and point [active] at it.

  /// The network settlements are sent on.
  static const SettlementNetwork active = sepolia;
}
