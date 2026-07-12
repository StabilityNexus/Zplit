import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:zplit/core/services/crypto_service.dart';

class DeepLinkTransaction {
  final String id;
  final String fromPublicKey;
  final String toPublicKey;
  final double amount;
  final double totalAmount;
  final String splitType;
  final String description;
  final String? tag;
  final int timestamp;
  final String senderSignature;
  final bool isVerified;

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
      print(' INITIAL LINK: $uri');
      return uri;
    } catch (e) {
      print(' INITIAL LINK ERROR: $e');
      return null;
    }
  }

  Stream<Uri> get linkStream => _appLinks.uriLinkStream;

  void listen(void Function(Uri uri) onLink) {
    _sub = _appLinks.uriLinkStream.listen((uri) {
      print(' STREAM LINK: $uri');
      onLink(uri);
    });
  }

  void dispose() {
    _sub?.cancel();
  }

  static DeepLinkTransaction? parseAndVerify(Uri uri) {
    try {
      final encoded = uri.queryParameters['d'];
      if (encoded == null) return null;

      final decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(encoded)),
      );
      print(' RAW DECODED: $decoded');

      final json = jsonDecode(decoded) as Map<String, dynamic>;

      final id = json['id'] as String? ?? '';
      final fromPublicKey = json['from'] as String? ?? '';
      final toPublicKey = json['to'] as String? ?? '';
      final amount = (json['amount'] as num?)?.toDouble() ?? 0.0;
      final totalAmount = (json['totalAmount'] as num?)?.toDouble() ?? amount;
      final splitType = json['split'] as String? ?? 'Split Equally';
      final description = json['desc'] as String? ?? '';
      final timestamp = (json['ts'] as num?)?.toInt() ?? 0;
      final senderSignature = json['sig'] as String? ?? '';

      final rawTag = json['tag'];
      final String? tag = (rawTag == null || rawTag == 'null')
          ? null
          : rawTag as String?;

      print(
        ' PARSED: id=$id from=$fromPublicKey amount=$amount tag=$tag desc=$description sig=${senderSignature.isNotEmpty ? '' : ' MISSING'}',
      );

      bool isVerified = false;
      if (senderSignature.isEmpty) {
        print(' No signature in payload — rejecting');
      } else {
        final amountBigInt = BigInt.from((amount * 100).round());

        // Build the payload exactly as the sender signed it
        final verifyPayload = CryptoService.buildTransactionPayload(
          id: id,
          fromPublicKey: fromPublicKey,
          toPublicKey: toPublicKey,
          amount: amountBigInt,
          currency: 'INR',
          description: description,
          tag: tag,
          timestamp: timestamp,
        );
        print(' VERIFY PAYLOAD: $verifyPayload');

        isVerified = CryptoService.verify(
          payload: verifyPayload,
          signatureHex: senderSignature,
          expectedAddress: fromPublicKey,
        );
        print(isVerified ? ' Signature valid' : ' Signature INVALID');
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
      print('🔗 PARSE ERROR: $e');
      return null;
    }
  }
}
