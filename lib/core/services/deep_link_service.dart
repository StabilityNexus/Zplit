import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:zplit/core/services/crypto_service.dart';

/// Result of parsing + verifying an incoming deep link.
class DeepLinkTransaction {
  final String id;
  final String fromPublicKey;
  final String toPublicKey;
  final double amount; // split amount (not total)
  final double totalAmount;
  final String splitType;
  final String description;
  final String? tag;
  final int timestamp;
  final String senderSignature;
  final bool isVerified; // ✅ false = reject immediately on receiver side

  const DeepLinkTransaction({
    required this.id,
    required this.fromPublicKey,
    required this.toPublicKey,
    required this.amount,
    required this.totalAmount,
    required this.splitType,
    required this.description,
    this.tag,
    required this.timestamp,
    required this.senderSignature,
    required this.isVerified,
  });
}

class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<Uri?> getInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      print('INITIAL LINK: $uri');
      return uri;
    } catch (e) {
      print('INITIAL LINK ERROR: $e');
      return null;
    }
  }

  Stream<Uri> get linkStream => _appLinks.uriLinkStream;

  /// Call this to start listening — passes each URI to [onLink]
  void listen(void Function(Uri uri) onLink) {
    _sub = _appLinks.uriLinkStream.listen((uri) {
      print('STREAM LINK: $uri');
      onLink(uri);
    });
  }

  void dispose() {
    _sub?.cancel();
  }

  /// [DeepLinkTransaction.isVerified] will be false if signature is missing

  static DeepLinkTransaction? parseAndVerify(Uri uri) {
    try {
      final encoded = uri.queryParameters['d'];
      if (encoded == null) return null;

      final json = jsonDecode(utf8.decode(base64Url.decode(encoded)));

      final id = json['id'] as String? ?? '';
      final fromPublicKey = json['from'] as String? ?? '';
      final toPublicKey = json['to'] as String? ?? '';
      final amount = (json['amount'] as num?)?.toDouble() ?? 0.0;
      final totalAmount = (json['totalAmount'] as num?)?.toDouble() ?? amount;
      final splitType = json['split'] as String? ?? 'Split Equally';
      final description = json['desc'] as String? ?? '';
      final tag = json['tag'] as String?;
      final timestamp = (json['ts'] as num?)?.toInt() ?? 0;
      final senderSignature = json['sig'] as String? ?? '';

      print(
        'PARSED TX: id=$id from=$fromPublicKey amount=$amount sig=${senderSignature.isNotEmpty ? '' : ' MISSING'}',
      );

      bool isVerified = false;
      if (senderSignature.isEmpty) {
        print('No signature in payload — rejecting');
      } else {
        final amountBigInt = BigInt.from((amount * 100).round());
        isVerified = CryptoService.verifyTransaction(
          id: id,
          fromPublicKey: fromPublicKey,
          toPublicKey: toPublicKey,
          amount: amountBigInt,
          currency: 'INR',
          description: description,
          tag: tag,
          timestamp: timestamp,
          signatureHex: senderSignature,
          expectedAddress: fromPublicKey,
        );
        print(isVerified ? 'Signature valid' : 'Signature INVALID');
      }

      return DeepLinkTransaction(
        id: id,
        fromPublicKey: fromPublicKey,
        toPublicKey: toPublicKey,
        amount: amount,
        totalAmount: totalAmount,
        splitType: splitType,
        description: description,
        tag: tag,
        timestamp: timestamp,
        senderSignature: senderSignature,
        isVerified: isVerified,
      );
    } catch (e) {
      print(' PARSE ERROR: $e');
      return null;
    }
  }
}
