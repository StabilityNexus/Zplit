import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/core/services/settlement_service.dart';
import 'package:zplit/ui/settlement/view_model/settlement_bloc.dart';
import 'package:zplit/ui/settlement/view_model/settlement_event.dart';
import 'package:zplit/ui/settlement/view_model/settlement_state.dart';

/// Stands in for the url_launcher platform channel. Zplit opens the wallet
/// with launchUrl only (it deliberately never calls canLaunchUrl, which
/// returns false for custom schemes on Android 11+ unless declared in
/// `<queries>`), so only the 'launch' call is expected.
class _FakeUrlLauncher {
  static const _channel = MethodChannel('plugins.flutter.io/url_launcher');

  final calls = <MethodCall>[];
  bool launchResult = true;
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
            case 'launch':
              if (launchError != null) throw launchError!;
              return launchResult;
            case 'canLaunch':
              return true;
          }
          return null;
        });
  }

  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }
}

/// In-memory stand-in for the flutter_secure_storage platform channel.
///
/// SettlementTracker reads and writes through flutter_secure_storage, which
/// has no implementation inside `flutter test`. Without this, every tracker
/// call throws MissingPluginException (printed as "SettlementTracker.… failed")
/// and slows the bloc down, so state changes can arrive after blocTest has
/// already finished and closed the bloc.
class _FakeSecureStorage {
  static const _channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  final Map<String, String> store = {};

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          final args = (call.arguments as Map?) ?? const {};
          final key = args['key'] as String?;
          switch (call.method) {
            case 'read':
              return store[key];
            case 'write':
              store[key!] = args['value'] as String;
              return null;
            case 'delete':
              store.remove(key);
              return null;
            case 'containsKey':
              return store.containsKey(key);
            case 'readAll':
              return Map<String, String>.from(store);
            case 'deleteAll':
              store.clear();
              return null;
          }
          return null;
        });
  }

  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }
}

/// A syntactically valid EVM address (0x + 40 hex characters).
const _friend = '0x1111111111111111111111111111111111111111';

/// 830 INR is exactly 10 USDC at the configured 83 INR per USD.
const _balanceInInr = 830.0;

void main() {
  late _FakeUrlLauncher launcher;
  late _FakeSecureStorage secureStorage;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    launcher = _FakeUrlLauncher()..install();
    secureStorage = _FakeSecureStorage()..install();
  });

  tearDown(() {
    launcher.uninstall();
    secureStorage.uninstall();
  });

  SettlementBloc buildBloc() => SettlementBloc();

  /// Adds a SettleRequested and waits for the first state that is not
  /// "Launching". The launcher round-trips through a platform channel, so
  /// this is more reliable than blocTest's default zero-length wait.
  Future<void> requestAndSettle(
    SettlementBloc bloc, {
    String address = _friend,
    double inr = _balanceInInr,
  }) async {
    bloc.add(SettleRequested(friendWalletAddress: address, balanceInInr: inr));
    await bloc.stream
        .firstWhere((s) => s is! SettlementLaunching)
        .timeout(const Duration(seconds: 2));
  }

  String expectedUrlFor(double inr) => SettlementService.buildTransferUri(
    recipientAddress: _friend,
    rawAmount: SettlementService.usdcRawFromInr(inr),
  ).toString();

  test('initial state is SettlementInitial', () {
    final bloc = buildBloc();
    addTearDown(bloc.close);

    expect(bloc.state, isA<SettlementInitial>());
  });

  group('SettleRequested', () {
    blocTest<SettlementBloc, SettlementState>(
      'emits Launching then AwaitingReturn and opens the transfer URI',
      build: buildBloc,
      act: requestAndSettle,
      expect: () => [
        isA<SettlementLaunching>(),
        isA<SettlementAwaitingReturn>(),
      ],
      verify: (_) {
        expect(launcher.callsTo('launch').map(_FakeUrlLauncher.urlOf), [
          expectedUrlFor(_balanceInInr),
        ]);
      },
    );

    blocTest<SettlementBloc, SettlementState>(
      'sends exactly 10 USDC (10000000 base units) for 830 INR',
      build: buildBloc,
      act: requestAndSettle,
      expect: () => [
        isA<SettlementLaunching>(),
        isA<SettlementAwaitingReturn>(),
      ],
      verify: (_) {
        final url = _FakeUrlLauncher.urlOf(launcher.callsTo('launch').single);
        expect(url, contains('uint256=10000000'));
        expect(url, contains('address=$_friend'));
      },
    );

    blocTest<SettlementBloc, SettlementState>(
      'uses the absolute amount when the balance is negative',
      build: buildBloc,
      act: (bloc) => requestAndSettle(bloc, inr: -_balanceInInr),
      expect: () => [
        isA<SettlementLaunching>(),
        isA<SettlementAwaitingReturn>(),
      ],
      verify: (_) {
        expect(launcher.callsTo('launch').map(_FakeUrlLauncher.urlOf), [
          expectedUrlFor(_balanceInInr),
        ]);
      },
    );

    blocTest<SettlementBloc, SettlementState>(
      'does not call canLaunch before launching the wallet',
      build: buildBloc,
      act: requestAndSettle,
      expect: () => [
        isA<SettlementLaunching>(),
        isA<SettlementAwaitingReturn>(),
      ],
      verify: (_) {
        expect(launcher.callsTo('canLaunch'), isEmpty);
      },
    );

    blocTest<SettlementBloc, SettlementState>(
      'emits NoWalletFound when the launch reports failure',
      setUp: () => launcher.launchResult = false,
      build: buildBloc,
      act: requestAndSettle,
      expect: () => [
        isA<SettlementLaunching>(),
        isA<SettlementNoWalletFound>(),
      ],
      verify: (_) {
        expect(launcher.callsTo('launch'), hasLength(1));
      },
    );

    // The service swallows launch errors and returns false, so a failing
    // launch looks the same as "no wallet installed" to the screen.
    blocTest<SettlementBloc, SettlementState>(
      'emits NoWalletFound when launching the wallet throws',
      setUp: () => launcher.launchError = PlatformException(
        code: 'ACTIVITY_NOT_FOUND',
        message: 'no activity',
      ),
      build: buildBloc,
      act: requestAndSettle,
      expect: () => [
        isA<SettlementLaunching>(),
        isA<SettlementNoWalletFound>(),
      ],
    );

    blocTest<SettlementBloc, SettlementState>(
      'rejects an invalid recipient address without launching',
      build: buildBloc,
      act: (bloc) => requestAndSettle(bloc, address: 'not-an-address'),
      expect: () => [
        isA<SettlementError>().having(
          (s) => s.message,
          'message',
          contains('not valid'),
        ),
      ],
      verify: (_) {
        expect(launcher.calls, isEmpty);
      },
    );

    blocTest<SettlementBloc, SettlementState>(
      'rejects an amount too small to settle without launching',
      build: buildBloc,
      act: (bloc) => requestAndSettle(bloc, inr: 0),
      expect: () => [
        isA<SettlementError>().having(
          (s) => s.message,
          'message',
          contains('too small'),
        ),
      ],
      verify: (_) {
        expect(launcher.calls, isEmpty);
      },
    );

    blocTest<SettlementBloc, SettlementState>(
      'can be retried after a failure',
      build: buildBloc,
      seed: () => const SettlementError('previous failure'),
      act: requestAndSettle,
      expect: () => [
        isA<SettlementLaunching>(),
        isA<SettlementAwaitingReturn>(),
      ],
    );
  });

  group('SettlementReturned', () {
    blocTest<SettlementBloc, SettlementState>(
      'moves from AwaitingReturn to Confirming',
      build: buildBloc,
      seed: () => const SettlementAwaitingReturn(),
      act: (bloc) => bloc.add(SettlementReturned()),
      expect: () => [isA<SettlementConfirming>()],
    );

    blocTest<SettlementBloc, SettlementState>(
      'is ignored when the user was never sent to a wallet',
      build: buildBloc,
      act: (bloc) => bloc.add(SettlementReturned()),
      expect: () => <SettlementState>[],
    );
  });

  group('SettlementPaidClaimed', () {
    blocTest<SettlementBloc, SettlementState>(
      'records the payment as self-reported (unverified)',
      build: buildBloc,
      seed: () => const SettlementConfirming(),
      act: (bloc) => bloc.add(SettlementPaidClaimed()),
      expect: () => [isA<SettlementSelfReported>()],
    );
  });

  // Only the path that needs no network is covered here. Verifying a real
  // hash reads the chain through Web3Client, which this bloc creates
  // internally, so the verified / not-found / network-error paths need the
  // client to be injectable before they can be unit tested.
  group('SettlementVerifyRequested', () {
    blocTest<SettlementBloc, SettlementState>(
      'rejects a malformed transaction hash without any network call',
      build: buildBloc,
      seed: () => const SettlementConfirming(),
      act: (bloc) => bloc.add(
        SettlementVerifyRequested(
          txHash: '0x1234',
          friendWalletAddress: _friend,
          balanceInInr: _balanceInInr,
        ),
      ),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<SettlementVerifying>(),
        isA<SettlementConfirming>().having(
          (s) => s.notice,
          'notice',
          contains('transaction hash'),
        ),
      ],
    );
  });

  group('SettlementReset', () {
    final seeds = <String, SettlementState Function()>{
      'AwaitingReturn': () => const SettlementAwaitingReturn(),
      'Confirming': () => const SettlementConfirming(),
      'SelfReported': () => const SettlementSelfReported(),
      'NoWalletFound': () => const SettlementNoWalletFound(),
      'Error': () => const SettlementError('boom'),
    };
    for (final entry in seeds.entries) {
      blocTest<SettlementBloc, SettlementState>(
        'returns to Initial from ${entry.key}',
        build: buildBloc,
        seed: entry.value,
        act: (bloc) => bloc.add(SettlementReset()),
        // Give any async work in the handler time to finish before blocTest
        // closes the bloc; a state emitted after close is dropped, which is
        // what made these tests report "Actual: []".
        wait: const Duration(milliseconds: 200),
        expect: () => [isA<SettlementInitial>()],
        verify: (_) {
          // Reset must not touch the launcher.
          expect(launcher.calls, isEmpty);
        },
      );
    }
  });
}
