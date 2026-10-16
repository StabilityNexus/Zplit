import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/domain/repositories/transaction/transaction_repository.dart';
import 'package:zplit/domain/repositories/user/user_repository.dart';
// DeepLinkEvent / DeepLinkState are `part of` this file, so this one import
// is all that's needed for every event and state class.
import 'package:zplit/ui/deep_link/view_model/deep_link_bloc.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

typedef PayloadEventFactory = DeepLinkEvent Function(String payload);

/// base64url-encodes [json] the same way the QR / deep-link payloads are.
String encodePayload(Map<String, dynamic> json) =>
    base64Url.encode(utf8.encode(jsonEncode(json)));

Uri linkFor(String route, Map<String, dynamic> json) =>
    Uri.parse('https://zplit.app/$route?d=${encodePayload(json)}');

/// A transaction-shaped payload with NO signature. parseAndVerify() returns
/// it as unverified without ever touching CryptoService.
Map<String, dynamic> unsignedTx() => {
  'id': 'txn-1',
  'from': '0xsender',
  'to': '0xme',
  'amount': 12.5,
  'desc': 'Lunch',
  'ts': 1700000000,
};

Matcher isError(Object messageMatcher) =>
    isA<DeepLinkError>().having((s) => s.message, 'message', messageMatcher);

void main() {
  late MockUserRepository userRepo;
  late MockTransactionRepository txRepo;
  late Directory tempDir;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(BigInt.zero);
  });

  setUp(() {
    userRepo = MockUserRepository();
    txRepo = MockTransactionRepository();

    // No local user by default, so the "is this my own invite?" check passes.
    when(() => userRepo.getCurrentUser()).thenAnswer((_) async => null);
    when(
      () => userRepo.upsertUser(
        publicKey: any(named: 'publicKey'),
        displayName: any(named: 'displayName'),
        cryptoAddress: any(named: 'cryptoAddress'),
        profilePicture: any(named: 'profilePicture'),
        defaultCurrency: any(named: 'defaultCurrency'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => txRepo.applyRemoteAck(
        transactionId: any(named: 'transactionId'),
        outcome: any(named: 'outcome'),
      ),
    ).thenAnswer((_) async {});
  });

  DeepLinkBloc buildBloc() =>
      DeepLinkBloc(userRepository: userRepo, transactionRepository: txRepo);

  void verifyNoIncomingTransaction() {
    verifyNever(
      () => txRepo.receiveIncoming(
        id: any(named: 'id'),
        fromUserPublicKey: any(named: 'fromUserPublicKey'),
        toUserPublicKey: any(named: 'toUserPublicKey'),
        amount: any(named: 'amount'),
        currency: any(named: 'currency'),
        description: any(named: 'description'),
        tag: any(named: 'tag'),
      ),
    );
  }

  void verifyNoUpsert() {
    verifyNever(
      () => userRepo.upsertUser(
        publicKey: any(named: 'publicKey'),
        displayName: any(named: 'displayName'),
        cryptoAddress: any(named: 'cryptoAddress'),
        profilePicture: any(named: 'profilePicture'),
        defaultCurrency: any(named: 'defaultCurrency'),
      ),
    );
  }

  final inviteEvents = <String, PayloadEventFactory>{
    'Bluetooth': BluetoothInviteReceived.new,
    'Nfc': NfcInviteReceived.new,
    'Wifi': WifiInviteReceived.new,
  };
  final ackEvents = <String, PayloadEventFactory>{
    'Bluetooth': BluetoothAckReceived.new,
    'Nfc': NfcAckReceived.new,
    'Wifi': WifiAckReceived.new,
  };
  final transactionEvents = <String, PayloadEventFactory>{
    'Bluetooth': BluetoothTransactionReceived.new,
    'Nfc': NfcTransactionReceived.new,
    'Wifi': WifiTransactionReceived.new,
  };

  test('initial state is DeepLinkInitial', () {
    final bloc = buildBloc();
    addTearDown(bloc.close);

    expect(bloc.state, isA<DeepLinkInitial>());
  });

  // ────────────────────────────────────────────────────────────────────
  // Ack payloads (no Loading state is emitted on this path)
  // ────────────────────────────────────────────────────────────────────
  group('ack payloads', () {
    for (final entry in ackEvents.entries) {
      blocTest<DeepLinkBloc, DeepLinkState>(
        '${entry.key}AckReceived applies the ack and emits TransactionAckReceived',
        build: buildBloc,
        act: (bloc) => bloc.add(
          entry.value(jsonEncode({'id': 'txn-1', 'outcome': 'accepted'})),
        ),
        expect: () => [
          isA<TransactionAckReceived>()
              .having((s) => s.txnId, 'txnId', 'txn-1')
              .having((s) => s.outcome, 'outcome', 'accepted'),
        ],
        verify: (_) {
          verify(
            () => txRepo.applyRemoteAck(
              transactionId: 'txn-1',
              outcome: 'accepted',
            ),
          ).called(1);
        },
      );
    }

    final invalidAcks = <String, String>{
      'missing id': jsonEncode({'outcome': 'accepted'}),
      'missing outcome': jsonEncode({'id': 'txn-1'}),
      'empty id and outcome': jsonEncode({'id': '', 'outcome': ''}),
    };
    for (final entry in invalidAcks.entries) {
      blocTest<DeepLinkBloc, DeepLinkState>(
        'rejects an ack with ${entry.key} without touching the repository',
        build: buildBloc,
        act: (bloc) => bloc.add(BluetoothAckReceived(entry.value)),
        expect: () => [isError('Invalid ack payload')],
        verify: (_) {
          verifyNever(
            () => txRepo.applyRemoteAck(
              transactionId: any(named: 'transactionId'),
              outcome: any(named: 'outcome'),
            ),
          );
        },
      );
    }

    final unreadableAcks = <String, String>{
      'not JSON': 'not json',
      'JSON that is not an object': '[1,2,3]',
    };
    for (final entry in unreadableAcks.entries) {
      blocTest<DeepLinkBloc, DeepLinkState>(
        'emits DeepLinkError for an ack that is ${entry.key}',
        build: buildBloc,
        act: (bloc) => bloc.add(NfcAckReceived(entry.value)),
        expect: () => [isA<DeepLinkError>()],
        verify: (_) {
          verifyNever(
            () => txRepo.applyRemoteAck(
              transactionId: any(named: 'transactionId'),
              outcome: any(named: 'outcome'),
            ),
          );
        },
      );
    }

    blocTest<DeepLinkBloc, DeepLinkState>(
      'emits DeepLinkError when the repository throws',
      setUp: () {
        when(
          () => txRepo.applyRemoteAck(
            transactionId: any(named: 'transactionId'),
            outcome: any(named: 'outcome'),
          ),
        ).thenAnswer((_) async => throw Exception('db down'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        WifiAckReceived(jsonEncode({'id': 'txn-1', 'outcome': 'rejected'})),
      ),
      expect: () => [isError(contains('db down'))],
    );
  });

  // ────────────────────────────────────────────────────────────────────
  // Invite payloads over Bluetooth / NFC / WiFi
  // ────────────────────────────────────────────────────────────────────
  group('invite payloads', () {
    for (final entry in inviteEvents.entries) {
      blocTest<DeepLinkBloc, DeepLinkState>(
        '${entry.key}InviteReceived upserts the user and emits InviteHandled',
        build: buildBloc,
        act: (bloc) => bloc.add(
          entry.value(
            jsonEncode({'id': 'user-1', 'name': 'Alex', 'addr': '0xabc'}),
          ),
        ),
        expect: () => [
          isA<DeepLinkLoading>(),
          isA<InviteHandled>().having(
            (s) => s.displayName,
            'displayName',
            'Alex',
          ),
        ],
        verify: (_) {
          verify(
            () => userRepo.upsertUser(
              publicKey: 'user-1',
              displayName: 'Alex',
              cryptoAddress: '0xabc',
              profilePicture: null,
              defaultCurrency: 'INR',
            ),
          ).called(1);
        },
      );
    }

    blocTest<DeepLinkBloc, DeepLinkState>(
      'falls back to the id as display name and an empty address',
      build: buildBloc,
      act: (bloc) => bloc.add(WifiInviteReceived(jsonEncode({'id': 'user-1'}))),
      expect: () => [
        isA<DeepLinkLoading>(),
        isA<InviteHandled>().having(
          (s) => s.displayName,
          'displayName',
          'user-1',
        ),
      ],
      verify: (_) {
        verify(
          () => userRepo.upsertUser(
            publicKey: 'user-1',
            displayName: 'user-1',
            cryptoAddress: '',
            profilePicture: null,
            defaultCurrency: 'INR',
          ),
        ).called(1);
      },
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'rejects an invite with a missing id',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(BluetoothInviteReceived(jsonEncode({'name': 'Alex'}))),
      expect: () => [
        isA<DeepLinkLoading>(),
        isError('Invalid invite: missing id'),
      ],
      verify: (_) => verifyNoUpsert(),
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'ignores a transaction-shaped payload ("sig") on the invite path',
      build: buildBloc,
      act: (bloc) => bloc.add(
        NfcInviteReceived(jsonEncode({'id': 'user-1', 'sig': 'abc123'})),
      ),
      expect: () => [
        isA<DeepLinkLoading>(),
        isError(contains('transaction-shaped')),
      ],
      verify: (_) => verifyNoUpsert(),
    );

    final unreadableInvites = <String, String>{
      'not JSON': 'not json',
      'JSON that is not an object': '[1,2,3]',
    };
    for (final entry in unreadableInvites.entries) {
      blocTest<DeepLinkBloc, DeepLinkState>(
        'emits DeepLinkError for an invite that is ${entry.key}',
        build: buildBloc,
        act: (bloc) => bloc.add(WifiInviteReceived(entry.value)),
        expect: () => [isA<DeepLinkLoading>(), isA<DeepLinkError>()],
        verify: (_) => verifyNoUpsert(),
      );
    }

    blocTest<DeepLinkBloc, DeepLinkState>(
      'emits DeepLinkError when the repository throws',
      setUp: () {
        when(
          () => userRepo.upsertUser(
            publicKey: any(named: 'publicKey'),
            displayName: any(named: 'displayName'),
            cryptoAddress: any(named: 'cryptoAddress'),
            profilePicture: any(named: 'profilePicture'),
            defaultCurrency: any(named: 'defaultCurrency'),
          ),
        ).thenAnswer((_) async => throw Exception('write failed'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        BluetoothInviteReceived(jsonEncode({'id': 'user-1', 'name': 'Alex'})),
      ),
      expect: () => [isA<DeepLinkLoading>(), isError(contains('write failed'))],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'still saves the user (without a picture) when the picture is not valid base64',
      build: buildBloc,
      act: (bloc) => bloc.add(
        WifiInviteReceived(
          jsonEncode({'id': 'user-1', 'name': 'Alex', 'pic': '%%%not-base64'}),
        ),
      ),
      expect: () => [isA<DeepLinkLoading>(), isA<InviteHandled>()],
      verify: (_) {
        verify(
          () => userRepo.upsertUser(
            publicKey: 'user-1',
            displayName: 'Alex',
            cryptoAddress: '',
            profilePicture: null,
            defaultCurrency: 'INR',
          ),
        ).called(1);
      },
    );

    // The only test that touches path_provider. The platform channel is
    // mocked to point at a temp directory. If it fails with a path_provider
    // platform error on your machine, it is safe to delete.
    blocTest<DeepLinkBloc, DeepLinkState>(
      'saves the profile picture to the documents directory and passes its path to upsertUser',
      setUp: () {
        tempDir = Directory.systemTemp.createTempSync('zplit_pic_test_');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/path_provider'),
              (call) async => call.method == 'getApplicationDocumentsDirectory'
                  ? tempDir.path
                  : null,
            );
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(
          WifiInviteReceived(
            jsonEncode({
              'id': 'user-1',
              'name': 'Alex',
              'pic': base64Encode([1, 2, 3, 4]),
            }),
          ),
        );
        // File I/O is real async work, so wait for the terminal state
        // instead of relying on blocTest's zero-length wait.
        await bloc.stream
            .firstWhere((s) => s is InviteHandled || s is DeepLinkError)
            .timeout(const Duration(seconds: 5));
      },
      expect: () => [isA<DeepLinkLoading>(), isA<InviteHandled>()],
      verify: (_) {
        final expectedPath = '${tempDir.path}/profile_user_1.jpg';
        expect(File(expectedPath).readAsBytesSync(), [1, 2, 3, 4]);
        verify(
          () => userRepo.upsertUser(
            publicKey: 'user-1',
            displayName: 'Alex',
            cryptoAddress: '',
            profilePicture: expectedPath,
            defaultCurrency: 'INR',
          ),
        ).called(1);
      },
      tearDown: () {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/path_provider'),
              null,
            );
        tempDir.deleteSync(recursive: true);
      },
    );
  });

  // ────────────────────────────────────────────────────────────────────
  // DeepLinkReceived (QR / app links): routing + invite + tx rejection
  // ────────────────────────────────────────────────────────────────────
  group('DeepLinkReceived', () {
    blocTest<DeepLinkBloc, DeepLinkState>(
      'invite link upserts the user and emits InviteHandled',
      build: buildBloc,
      act: (bloc) => bloc.add(
        DeepLinkReceived(
          linkFor('invite', {'id': 'user-1', 'name': 'Alex', 'addr': '0xabc'}),
        ),
      ),
      expect: () => [
        isA<DeepLinkLoading>(),
        isA<InviteHandled>().having(
          (s) => s.displayName,
          'displayName',
          'Alex',
        ),
      ],
      verify: (_) {
        verify(
          () => userRepo.upsertUser(
            publicKey: 'user-1',
            displayName: 'Alex',
            cryptoAddress: '0xabc',
            profilePicture: null,
            defaultCurrency: 'INR',
          ),
        ).called(1);
      },
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'invite link without a d parameter emits "Missing payload"',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(DeepLinkReceived(Uri.parse('https://zplit.app/invite'))),
      expect: () => [isA<DeepLinkLoading>(), isError('Missing payload')],
      verify: (_) => verifyNoUpsert(),
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'invite link with an undecodable d parameter emits DeepLinkError',
      build: buildBloc,
      act: (bloc) => bloc.add(
        DeepLinkReceived(Uri.parse('https://zplit.app/invite?d=***')),
      ),
      expect: () => [isA<DeepLinkLoading>(), isA<DeepLinkError>()],
      verify: (_) => verifyNoUpsert(),
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'unknown route emits DeepLinkError naming the route',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(DeepLinkReceived(Uri.parse('https://zplit.app/foo?d=x'))),
      expect: () => [isA<DeepLinkLoading>(), isError('Unknown route: foo')],
    );

    // Documents current behaviour: the route is read from pathSegments, so a
    // host-form link has no route. If your QR codes / app links use this
    // shape, this is a bug worth fixing rather than a test worth keeping.
    blocTest<DeepLinkBloc, DeepLinkState>(
      'treats host-form links (zplit://invite?d=...) as an unknown route',
      build: buildBloc,
      act: (bloc) => bloc.add(
        DeepLinkReceived(
          Uri.parse('zplit://invite?d=${encodePayload({'id': 'user-1'})}'),
        ),
      ),
      expect: () => [
        isA<DeepLinkLoading>(),
        isError(startsWith('Unknown route')),
      ],
      verify: (_) => verifyNoUpsert(),
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'tx link without a d parameter is rejected as unreadable',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(DeepLinkReceived(Uri.parse('https://zplit.app/tx'))),
      expect: () => [
        isA<DeepLinkLoading>(),
        isError('Invalid or unreadable transaction payload'),
      ],
      verify: (_) => verifyNoIncomingTransaction(),
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'tx link with garbage in d is rejected as unreadable',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(DeepLinkReceived(Uri.parse('https://zplit.app/tx?d=***'))),
      expect: () => [
        isA<DeepLinkLoading>(),
        isError('Invalid or unreadable transaction payload'),
      ],
      verify: (_) => verifyNoIncomingTransaction(),
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'tx link with no signature is rejected and never recorded',
      build: buildBloc,
      act: (bloc) => bloc.add(DeepLinkReceived(linkFor('tx', unsignedTx()))),
      expect: () => [
        isA<DeepLinkLoading>(),
        isError(contains('signature invalid')),
      ],
      verify: (_) {
        verifyNever(() => userRepo.getUserByPublicKey(any()));
        verifyNoIncomingTransaction();
      },
    );

    // Security check: whatever CryptoService does with a bogus signature
    // (return false, or throw and be caught as unreadable), the transaction
    // must be rejected and must never reach the repository.
    blocTest<DeepLinkBloc, DeepLinkState>(
      'tx link with a forged signature is rejected and never recorded',
      build: buildBloc,
      act: (bloc) => bloc.add(
        DeepLinkReceived(linkFor('tx', {...unsignedTx(), 'sig': 'deadbeef'})),
      ),
      expect: () => [isA<DeepLinkLoading>(), isA<DeepLinkError>()],
      verify: (_) => verifyNoIncomingTransaction(),
    );
  });

  // ────────────────────────────────────────────────────────────────────
  // Transaction payloads over Bluetooth / NFC / WiFi (rejection paths)
  // ────────────────────────────────────────────────────────────────────
  group('transaction payloads (rejection paths)', () {
    for (final entry in transactionEvents.entries) {
      blocTest<DeepLinkBloc, DeepLinkState>(
        '${entry.key}TransactionReceived rejects an unsigned transaction',
        build: buildBloc,
        act: (bloc) => bloc.add(entry.value(jsonEncode(unsignedTx()))),
        expect: () => [
          isA<DeepLinkLoading>(),
          isError(contains('signature invalid')),
        ],
        verify: (_) => verifyNoIncomingTransaction(),
      );

      blocTest<DeepLinkBloc, DeepLinkState>(
        '${entry.key}TransactionReceived rejects a forged signature',
        build: buildBloc,
        act: (bloc) => bloc.add(
          entry.value(jsonEncode({...unsignedTx(), 'sig': 'deadbeef'})),
        ),
        expect: () => [isA<DeepLinkLoading>(), isA<DeepLinkError>()],
        verify: (_) => verifyNoIncomingTransaction(),
      );
    }

    blocTest<DeepLinkBloc, DeepLinkState>(
      'rejects a transaction payload that is not JSON',
      build: buildBloc,
      act: (bloc) => bloc.add(const BluetoothTransactionReceived('not json')),
      expect: () => [
        isA<DeepLinkLoading>(),
        isError('Invalid or unreadable transaction payload'),
      ],
      verify: (_) => verifyNoIncomingTransaction(),
    );
  });
}
