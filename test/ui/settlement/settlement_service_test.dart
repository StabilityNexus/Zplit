import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/core/services/settlement_service.dart';

class _FakeUrlLauncher {
  static const _channel = MethodChannel('plugins.flutter.io/url_launcher');

  final calls = <MethodCall>[];
  bool canLaunchResult = true;
  bool launchResult = true;
  PlatformException? canLaunchError;
  PlatformException? launchError;

  Iterable<MethodCall> callsTo(String method) =>
      calls.where((c) => c.method == method);

  static String urlOf(MethodCall call) =>
      (call.arguments as Map)['url'] as String;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'canLaunch':
              if (canLaunchError != null) throw canLaunchError!;
              return canLaunchResult;
            case 'launch':
              if (launchError != null) throw launchError!;
              return launchResult;
          }
          return null;
        });
  }

  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }
}

void main() {
  late _FakeUrlLauncher launcher;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    launcher = _FakeUrlLauncher()..install();
  });

  tearDown(() {
    launcher.uninstall();
  });

  group('constants', () {
    test('target USDC on Ethereum mainnet with 6 decimals', () {
      expect(
        SettlementService.usdcContractAddress,
        '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
      );
      expect(SettlementService.chainId, 1);
      expect(SettlementService.usdcDecimals, 6);
    });
  });

  group('buildTransferUri', () {
    test('builds an EIP-681 ERC-20 transfer URI', () {
      final uri = SettlementService.buildTransferUri(
        recipientAddress: '0xFriend',
        usdcAmount: 25.5,
      );

      expect(uri.scheme, 'ethereum');
      expect(uri.path, '${SettlementService.usdcContractAddress}@1/transfer');
      expect(uri.queryParameters, {
        'address': '0xFriend',
        'uint256': '25500000',
      });
    });

    final amounts = <double, String>{
      1.0: '1000000',
      100: '100000000',
      25.5: '25500000',
      0.000001: '1', // smallest USDC unit
      0.1: '100000', // 0.1 * 1e6 is not exact in floating point
      0.30000000000000004: '300000', // classic 0.1 + 0.2 result
      1234.567891: '1234567891',
      1000000000.0: '1000000000000000', // no scientific notation
    };
    for (final entry in amounts.entries) {
      test('converts ${entry.key} USDC to ${entry.value} base units', () {
        final uri = SettlementService.buildTransferUri(
          recipientAddress: '0xFriend',
          usdcAmount: entry.key,
        );

        expect(uri.queryParameters['uint256'], entry.value);
      });
    }
  });

  group('launchWalletTransfer', () {
    Future<bool> launch() => SettlementService.launchWalletTransfer(
      recipientAddress: '0xFriend',
      usdcAmount: 25.5,
    );

    final expectedUrl = SettlementService.buildTransferUri(
      recipientAddress: '0xFriend',
      usdcAmount: 25.5,
    ).toString();

    test('returns true and launches the transfer URI when a wallet can '
        'handle it', () async {
      final result = await launch();

      expect(result, isTrue);
      expect(launcher.callsTo('canLaunch').map(_FakeUrlLauncher.urlOf), [
        expectedUrl,
      ]);
      expect(launcher.callsTo('launch').map(_FakeUrlLauncher.urlOf), [
        expectedUrl,
      ]);
    });

    test(
      'returns false without launching when no app can handle the URI',
      () async {
        launcher.canLaunchResult = false;

        final result = await launch();

        expect(result, isFalse);
        expect(launcher.callsTo('launch'), isEmpty);
      },
    );

    test('returns false when the launch itself reports failure', () async {
      launcher.launchResult = false;

      final result = await launch();

      expect(result, isFalse);
      expect(launcher.callsTo('launch'), hasLength(1));
    });

    test('lets a canLaunch platform error propagate', () async {
      launcher.canLaunchError = PlatformException(
        code: 'ERROR',
        message: 'query failed',
      );

      await expectLater(launch(), throwsA(isA<PlatformException>()));
      expect(launcher.callsTo('launch'), isEmpty);
    });

    test('lets a launch platform error propagate', () async {
      launcher.launchError = PlatformException(
        code: 'ACTIVITY_NOT_FOUND',
        message: 'no activity',
      );

      await expectLater(launch(), throwsA(isA<PlatformException>()));
    });
  });

  group('redirectToWalletInstall', () {
    test(
      'opens the Play Store MetaMask search without a canLaunch check',
      () async {
        await SettlementService.redirectToWalletInstall();

        expect(launcher.callsTo('canLaunch'), isEmpty);
        expect(launcher.callsTo('launch').map(_FakeUrlLauncher.urlOf), [
          'https://play.google.com/store/search?q=metamask&c=apps',
        ]);
      },
    );
  });
}
