import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class CryptoService {
  static const _storage = FlutterSecureStorage();

  // ─── Key helpers ──────────────────────────────────────────────

  static Future<Uint8List> _loadPrivateKeyBytes() async {
    final hex = await _storage.read(key: 'evm_private_key');
    if (hex == null) throw Exception('No private key in secure storage');
    final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
    return hexToBytes(clean);
  }

  // ─── Payload builders ─────────────────────────────────────────

  /// Deterministic canonical JSON for a transaction — sorted keys, no spaces.
  static String buildTransactionPayload({
    required String id,
    required String fromPublicKey,
    required String toPublicKey,
    required BigInt amount,
    required String currency,
    required String? description,
    required String? tag,
    required int timestamp,
  }) {
    final map = <String, dynamic>{
      'amount': amount.toString(),
      'currency': currency,
      'description': description ?? '',
      'from': fromPublicKey,
      'id': id,
      'tag': tag ?? '',
      'to': toPublicKey,
      'ts': timestamp,
    }; // keys already alphabetical
    return jsonEncode(map);
  }

  /// Deterministic canonical JSON for a signed balance update.
  static String buildBalancePayload({
    required String fromPublicKey,
    required String toPublicKey,
    required BigInt netAmount,
    required String currency,
    required int timestamp,
  }) {
    final map = <String, dynamic>{
      'currency': currency,
      'from': fromPublicKey,
      'netAmount': netAmount.toString(),
      'to': toPublicKey,
      'ts': timestamp,
    };
    return jsonEncode(map);
  }

  // ─── Sign ─────────────────────────────────────────────────────

  /// Sign any UTF-8 string with this device's EVM private key.
  /// Uses Ethereum personal_sign prefix internally.
  /// Returns 0x-prefixed hex signature (65 bytes).
  static Future<String> sign(String payload) async {
    final privateKeyBytes = await _loadPrivateKeyBytes();
    final credentials = EthPrivateKey(privateKeyBytes);
    final messageBytes = Uint8List.fromList(utf8.encode(payload));
    final sig = credentials.signPersonalMessageToUint8List(messageBytes);
    return bytesToHex(sig, include0x: true);
  }

  static Future<String> signTransaction({
    required String id,
    required String fromPublicKey,
    required String toPublicKey,
    required BigInt amount,
    required String currency,
    required String? description,
    required String? tag,
    required int timestamp,
  }) {
    return sign(
      buildTransactionPayload(
        id: id,
        fromPublicKey: fromPublicKey,
        toPublicKey: toPublicKey,
        amount: amount,
        currency: currency,
        description: description,
        tag: tag,
        timestamp: timestamp,
      ),
    );
  }

  static Future<String> signBalance({
    required String fromPublicKey,
    required String toPublicKey,
    required BigInt netAmount,
    required String currency,
  }) {
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return sign(
      buildBalancePayload(
        fromPublicKey: fromPublicKey,
        toPublicKey: toPublicKey,
        netAmount: netAmount,
        currency: currency,
        timestamp: ts,
      ),
    );
  }

  // ─── Verify ───────────────────────────────────────────────────

  /// Verify a signature against a payload.
  /// [expectedAddress] is the 0x EVM address of the expected signer.
  /// Returns true if the signature was made by that address.
  static bool verify({
    required String payload,
    required String signatureHex,
    required String expectedAddress,
  }) {
    try {
      final messageBytes = Uint8List.fromList(utf8.encode(payload));
      final sigHex = signatureHex.startsWith('0x')
          ? signatureHex.substring(2)
          : signatureHex;
      final sigBytes = hexToBytes(sigHex);

      // Recover signer address using web3dart's built-in utility
      final recovered = _recoverAddress(messageBytes, sigBytes);
      return recovered.toLowerCase() == expectedAddress.toLowerCase();
    } catch (_) {
      return false;
    }
  }

  static bool verifyTransaction({
    required String id,
    required String fromPublicKey,
    required String toPublicKey,
    required BigInt amount,
    required String currency,
    required String? description,
    required String? tag,
    required int timestamp,
    required String signatureHex,
    required String expectedAddress,
  }) {
    final payload = buildTransactionPayload(
      id: id,
      fromPublicKey: fromPublicKey,
      toPublicKey: toPublicKey,
      amount: amount,
      currency: currency,
      description: description,
      tag: tag,
      timestamp: timestamp,
    );
    return verify(
      payload: payload,
      signatureHex: signatureHex,
      expectedAddress: expectedAddress,
    );
  }

  static String _recoverAddress(Uint8List message, Uint8List signature) {
    final prefix = '\x19Ethereum Signed Message:\n${message.length}';
    final prefixBytes = utf8.encode(prefix);
    final prefixed = Uint8List.fromList([...prefixBytes, ...message]);
    final hash = keccak256(prefixed);

    if (signature.length != 65) throw Exception('Bad signature length');
    final r = bytesToUnsignedInt(signature.sublist(0, 32));
    final s = bytesToUnsignedInt(signature.sublist(32, 64));
    var v = signature[64];
    if (v >= 27) v -= 27;

    final publicKey = ecRecover(hash, MsgSignature(r, s, v + 27));
    final pubKeyBytes = publicKey.sublist(1); // drop 0x04 prefix
    final addressBytes = keccak256(pubKeyBytes).sublist(12);
    return '0x${bytesToHex(addressBytes)}';
  }
}
