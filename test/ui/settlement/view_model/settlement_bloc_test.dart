import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/core/services/settlement_service.dart';
import 'package:zplit/ui/settlement/view_model/settlement_bloc.dart';
import 'package:zplit/ui/settlement/view_model/settlement_event.dart';
import 'package:zplit/ui/settlement/view_model/settlement_state.dart';

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

  SettlementBloc buildBloc() => SettlementBloc();

  /// Adds a SettleRequested and waits for the terminal state. The launcher
  /// round-trips through a platform channel, so this is more reliable than
  /// blocTest's default zero-length wait.
  Future<void> requestAndSettle(SettlementBloc bloc) async {
    bloc.add(
      SettleRequested(friendWalletAddress: '0xFriend', usdcAmount: 25.5),
    );
    await bloc.stream
        .firstWhere((s) => s is! SettlementLaunching)
        .timeout(const Duration(seconds: 2));
  }

  final expectedUrl = SettlementService.buildTransferUri(
    recipientAddress: '0xFriend',
    usdcAmount: 25.5,
  ).toString();

  test('initial state is SettlementInitial', () {
    final bloc = buildBloc();
    addTearDown(bloc.close);

    expect(bloc.state, isA<SettlementInitial>());
  });

  group('SettleRequested', () {
    blocTest<SettlementBloc, SettlementState>(
      'emits Launching then Launched and opens the transfer URI',
      build: buildBloc,
      act: requestAndSettle,
      expect: () => [isA<SettlementLaunching>(), isA<SettlementLaunched>()],
      verify: (_) {
        expect(launcher.callsTo('canLaunch').map(_FakeUrlLauncher.urlOf), [
          expectedUrl,
        ]);
        expect(launcher.callsTo('launch').map(_FakeUrlLauncher.urlOf), [
          expectedUrl,
        ]);
      },
    );

    blocTest<SettlementBloc, SettlementState>(
      'emits NoWalletFound and does not launch when no app can handle the URI',
      setUp: () => launcher.canLaunchResult = false,
      build: buildBloc,
      act: requestAndSettle,
      expect: () => [
        isA<SettlementLaunching>(),
        isA<SettlementNoWalletFound>(),
      ],
      verify: (_) {
        expect(launcher.callsTo('launch'), isEmpty);
      },
    );

    blocTest<SettlementBloc, SettlementState>(
      'emits NoWalletFound when the launch itself reports failure',
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

    blocTest<SettlementBloc, SettlementState>(
      'emits Error when checking for a wallet throws',
      setUp: () => launcher.canLaunchError = PlatformException(
        code: 'ERROR',
        message: 'query failed',
      ),
      build: buildBloc,
      act: requestAndSettle,
      expect: () => [
        isA<SettlementLaunching>(),
        isA<SettlementError>().having(
          (s) => s.message,
          'message',
          contains('query failed'),
        ),
      ],
      verify: (_) {
        expect(launcher.callsTo('launch'), isEmpty);
      },
    );

    blocTest<SettlementBloc, SettlementState>(
      'emits Error when launching the wallet throws',
      setUp: () => launcher.launchError = PlatformException(
        code: 'ACTIVITY_NOT_FOUND',
        message: 'no activity',
      ),
      build: buildBloc,
      act: requestAndSettle,
      expect: () => [
        isA<SettlementLaunching>(),
        isA<SettlementError>().having(
          (s) => s.message,
          'message',
          contains('no activity'),
        ),
      ],
    );

    blocTest<SettlementBloc, SettlementState>(
      'can be retried after a failure',
      build: buildBloc,
      seed: () => SettlementError('previous failure'),
      act: requestAndSettle,
      expect: () => [isA<SettlementLaunching>(), isA<SettlementLaunched>()],
    );
  });

  group('SettlementReset', () {
    final seeds = <String, SettlementState Function()>{
      'Launched': SettlementLaunched.new,
      'NoWalletFound': SettlementNoWalletFound.new,
      'Error': () => SettlementError('boom'),
    };
    for (final entry in seeds.entries) {
      blocTest<SettlementBloc, SettlementState>(
        'returns to Initial from ${entry.key}',
        build: buildBloc,
        seed: entry.value,
        act: (bloc) => bloc.add(SettlementReset()),
        expect: () => [isA<SettlementInitial>()],
        verify: (_) {
          // Reset must not touch the launcher.
          expect(launcher.calls, isEmpty);
        },
      );
    }
  });
}
