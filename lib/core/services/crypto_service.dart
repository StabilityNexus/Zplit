import 'dart:convert';
import 'dart:typed_data';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class CryptoService {
  static const _storage = FlutterSecureStorage();

  static Future<Uint8List> _loadPrivateKeyBytes() async {
    final hex = await _storage.read(key: 'evm_private_key');
    if (hex == null) throw Exception('No private key in secure storage');
    final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
    return hexToBytes(clean);
  }

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
      'desc': description ?? '',
      'from': fromPublicKey,
      'id': id,
      'tag': tag ?? '',
      'to': toPublicKey,
      'ts': timestamp,
    };
    return jsonEncode(map);
  }

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
  }) async {
    final p = buildTransactionPayload(
      id: id,
      fromPublicKey: fromPublicKey,
      toPublicKey: toPublicKey,
      amount: amount,
      currency: currency,
      description: description,
      tag: tag,
      timestamp: timestamp,
    );
    final sig = await sign(p);
    assert(() {
      // ignore: avoid_print
      print('SIGN PAYLOAD: $p');
      return true;
    }());
    return sig;
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

  static bool verify({
    required String payload,
    required String signatureHex,
    required String expectedAddress,
  }) {
    try {
      final recovered = EthSigUtil.recoverPersonalSignature(
        signature: signatureHex,
        message: Uint8List.fromList(utf8.encode(payload)),
      );

      assert(() {
        print(' RECOVERED: $recovered');

        print(' EXPECTED:  $expectedAddress');
        return true;
      }());

      return recovered.toLowerCase() == expectedAddress.toLowerCase();
    } catch (e) {
      assert(() {
        // ignore: avoid_print
        print(' VERIFY ERROR: $e');
        return true;
      }());
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

  static bool verifyBalance({
    required String fromPublicKey,
    required String toPublicKey,
    required BigInt netAmount,
    required String currency,
    required int timestamp,
    required String signatureHex,
    required String expectedAddress,
  }) {
    final payload = buildBalancePayload(
      fromPublicKey: fromPublicKey,
      toPublicKey: toPublicKey,
      netAmount: netAmount,
      currency: currency,
      timestamp: timestamp,
    );
    return verify(
      payload: payload,
      signatureHex: signatureHex,
      expectedAddress: expectedAddress,
    );
  }
}
