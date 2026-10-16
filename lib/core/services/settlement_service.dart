import 'package:url_launcher/url_launcher.dart';

class SettlementService {
  static const String usdcContractAddress =
      '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';

  static const int chainId = 1;

  static const int usdcDecimals = 6;

  static Uri buildTransferUri({
    required String recipientAddress,
    required double usdcAmount,
  }) {
    final rawAmount = BigInt.from((usdcAmount * _pow10(usdcDecimals)).round());

    return Uri.parse(
      'ethereum:$usdcContractAddress@$chainId/transfer'
      '?address=$recipientAddress&uint256=$rawAmount',
    );
  }

  static int _pow10(int exp) {
    int result = 1;
    for (var i = 0; i < exp; i++) {
      result *= 10;
    }
    return result;
  }

  static Future<bool> launchWalletTransfer({
    required String recipientAddress,
    required double usdcAmount,
  }) async {
    final uri = buildTransferUri(
      recipientAddress: recipientAddress,
      usdcAmount: usdcAmount,
    );

    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) return false;

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> redirectToWalletInstall() async {
    final playStoreUri = Uri.parse(
      'https://play.google.com/store/search?q=metamask&c=apps',
    );
    await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
  }
}
