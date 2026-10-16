import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;

/// Low level NFC read/write wrapper.
///
/// Mirrors the role of `bluetooth_service.dart` — NfcBloc talks to this,
/// UI never talks to FlutterNfcKit directly.
class NfcService {
  Future<bool> isAvailable() async {
    final availability = await FlutterNfcKit.nfcAvailability;
    return availability == NFCAvailability.available;
  }

  /// Waits for a tag/device tap, then writes [jsonPayload] to it.
  /// Throws on timeout, unsupported tag, or write failure.
  Future<void> shareViaNfc(
    String jsonPayload, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    await FlutterNfcKit.poll(
      timeout: timeout,
      iosAlertMessage: 'Hold your phone near the other device',
    );
    try {
      final record = ndef.TextRecord(text: jsonPayload, language: 'en');
      await FlutterNfcKit.writeNDEFRecords([record]);
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  Future<String?> receiveViaNfc({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    await FlutterNfcKit.poll(
      timeout: timeout,
      iosAlertMessage: 'Hold your phone near the other device',
    );
    try {
      final records = await FlutterNfcKit.readNDEFRecords();
      if (records.isEmpty) return null;
      final record = records.first;
      if (record is ndef.TextRecord) return record.text;
      return null;
    } finally {
      await FlutterNfcKit.finish();
    }
  }
}
