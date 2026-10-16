import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/core/services/deep_link_service.dart';

Uri txUri(Map<String, dynamic> json) => Uri.parse(
  'https://zplit.app/tx?d=${base64Url.encode(utf8.encode(jsonEncode(json)))}',
);

void main() {
  group('DeepLinkService.parseAndVerify', () {
    test('returns null when the d parameter is missing', () {
      expect(
        DeepLinkService.parseAndVerify(Uri.parse('https://zplit.app/tx')),
        isNull,
      );
    });

    test('returns null when d is not valid base64', () {
      expect(
        DeepLinkService.parseAndVerify(Uri.parse('https://zplit.app/tx?d=***')),
        isNull,
      );
    });

    test('returns null when the decoded payload is not JSON', () {
      final uri = Uri.parse(
        'https://zplit.app/tx?d=${base64Url.encode(utf8.encode('not json'))}',
      );

      expect(DeepLinkService.parseAndVerify(uri), isNull);
    });

    test('returns null when the JSON is not an object', () {
      final uri = Uri.parse(
        'https://zplit.app/tx?d=${base64Url.encode(utf8.encode('[1,2,3]'))}',
      );

      expect(DeepLinkService.parseAndVerify(uri), isNull);
    });

    test('parses required fields and applies defaults for optional ones', () {
      final tx = DeepLinkService.parseAndVerify(
        txUri({
          'id': 'txn-1',
          'from': '0xsender',
          'to': '0xme',
          'amount': 12.5,
          'ts': 99,
        }),
      );

      expect(tx, isNotNull);
      expect(tx!.id, 'txn-1');
      expect(tx.fromPublicKey, '0xsender');
      expect(tx.toPublicKey, '0xme');
      expect(tx.amount, 12.5);
      expect(tx.totalAmount, 12.5); // defaults to amount
      expect(tx.splitType, 'Split Equally');
      expect(tx.description, '');
      expect(tx.tag, isNull);
      expect(tx.timestamp, 99);
      expect(tx.senderSignature, '');
    });

    test('reads explicit totalAmount, split, desc and tag', () {
      final tx = DeepLinkService.parseAndVerify(
        txUri({
          'id': 'txn-1',
          'from': '0xsender',
          'to': '0xme',
          'amount': 10,
          'totalAmount': 30,
          'split': 'Split by percentage',
          'desc': 'Dinner',
          'tag': 'food',
          'ts': 5,
        }),
      );

      expect(tx, isNotNull);
      expect(tx!.amount, 10.0); // int input is widened to double
      expect(tx.totalAmount, 30.0);
      expect(tx.splitType, 'Split by percentage');
      expect(tx.description, 'Dinner');
      expect(tx.tag, 'food');
    });

    test('treats a null tag and the string "null" as no tag', () {
      final withNull = DeepLinkService.parseAndVerify(
        txUri({'id': 'a', 'from': 'f', 'amount': 1, 'tag': null}),
      );
      final withString = DeepLinkService.parseAndVerify(
        txUri({'id': 'a', 'from': 'f', 'amount': 1, 'tag': 'null'}),
      );

      expect(withNull!.tag, isNull);
      expect(withString!.tag, isNull);
    });

    test('marks a payload with no sig key as unverified', () {
      final tx = DeepLinkService.parseAndVerify(
        txUri({'id': 'txn-1', 'from': '0xsender', 'amount': 1}),
      );

      expect(tx, isNotNull);
      expect(tx!.isVerified, isFalse);
    });

    test('marks a payload with an empty sig as unverified', () {
      final tx = DeepLinkService.parseAndVerify(
        txUri({'id': 'txn-1', 'from': '0xsender', 'amount': 1, 'sig': ''}),
      );

      expect(tx, isNotNull);
      expect(tx!.isVerified, isFalse);
    });

    test('never reports a forged signature as verified', () {
      final tx = DeepLinkService.parseAndVerify(
        txUri({
          'id': 'txn-1',
          'from': '0xsender',
          'to': '0xme',
          'amount': 1,
          'ts': 1,
          'sig': 'deadbeef',
        }),
      );

      expect(tx?.isVerified ?? false, isFalse);
    });
  });
}
