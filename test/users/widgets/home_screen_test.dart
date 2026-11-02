import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/routing/App_router.dart';
import 'package:zplit/ui/balance/view_model/balance_bloc.dart';
import 'package:zplit/ui/balance/view_model/balance_event.dart';
import 'package:zplit/ui/balance/view_model/balance_state.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_bloc.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_event.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_state.dart';
import 'package:zplit/ui/deep_link/view_model/deep_link_bloc.dart';
import 'package:zplit/ui/group/view_models/group_bloc.dart';
import 'package:zplit/ui/group/view_models/group_event.dart';
import 'package:zplit/ui/group/view_models/group_state.dart';
import 'package:zplit/ui/nfc/view_model/nfc_bloc.dart';
import 'package:zplit/ui/nfc/view_model/nfc_event.dart';
import 'package:zplit/ui/nfc/view_model/nfc_state.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_event.dart';
import 'package:zplit/ui/transaction/view_model/transaction_state.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_event.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';
import 'package:zplit/ui/users/widgets/friendlist.dart';
import 'package:zplit/ui/users/widgets/home_Screen.dart';
import 'package:zplit/ui/users/widgets/profile_screen.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class MockBalanceBloc extends MockBloc<BalanceEvent, BalanceState>
    implements BalanceBloc {}

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

class MockDeepLinkBloc extends MockBloc<DeepLinkEvent, DeepLinkState>
    implements DeepLinkBloc {}

class MockNfcBloc extends MockBloc<NfcEvent, NfcState> implements NfcBloc {}

class MockBluetoothBloc extends MockBloc<BluetoothEvent, BluetoothState>
    implements BluetoothBloc {}

// HomeScreen now loads groups for its Groups tab.
class MockGroupBloc extends MockBloc<GroupEvent, GroupState>
    implements GroupBloc {}

class FakeUserEvent extends Fake implements UserEvent {}

class FakeBalanceEvent extends Fake implements BalanceEvent {}

class FakeTransactionEvent extends Fake implements TransactionEvent {}

class FakeNfcEvent extends Fake implements NfcEvent {}

class FakeGroupEvent extends Fake implements GroupEvent {}

const _myAddress = '0xME000000000000';

UserModel _user({String key = '0xABC', String name = 'Alice'}) => UserModel(
  publicKey: key,
  displayName: name,
  cryptoAddress: key,
  profilePicture: null,
  defaultCurrency: '₹',
);

BalanceModel _balance({String key = '0xABC', int amount = 100}) => BalanceModel(
  userPublicKey: key,
  netAmount: amount,
  currency: '₹',
  updatedAt: DateTime(2024, 6, 1),
);

/// Makes the screen's `FlutterSecureStorage().read('evm_address')` resolve
/// to [address] (or null) without touching the platform channel.
void _storeAddress(String? address) {
  FlutterSecureStorage.setMockInitialValues(
    address == null ? {} : {'evm_address': address},
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUserEvent());
    registerFallbackValue(FakeBalanceEvent());
    registerFallbackValue(FakeTransactionEvent());
    registerFallbackValue(FakeNfcEvent());
    registerFallbackValue(FakeGroupEvent());
  });

  late MockUserBloc userBloc;
  late MockBalanceBloc balanceBloc;
  late MockTransactionBloc transactionBloc;
  late MockDeepLinkBloc deepLinkBloc;
  late MockNfcBloc nfcBloc;
  late MockBluetoothBloc bluetoothBloc;
  late MockGroupBloc groupBloc;

  setUp(() {
    userBloc = MockUserBloc();
    balanceBloc = MockBalanceBloc();
    transactionBloc = MockTransactionBloc();
    deepLinkBloc = MockDeepLinkBloc();
    nfcBloc = MockNfcBloc();
    bluetoothBloc = MockBluetoothBloc();
    groupBloc = MockGroupBloc();

    when(() => transactionBloc.state).thenReturn(TransactionInitial());
    when(() => deepLinkBloc.state).thenReturn(DeepLinkInitial());
    when(() => nfcBloc.state).thenReturn(const NfcState());
    when(() => bluetoothBloc.state).thenReturn(const BluetoothState());
    whenListen(
      groupBloc,
      const Stream<GroupState>.empty(),
      initialState: GroupInitial(),
    );

    _storeAddress(null);
  });

  Widget wrap() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>.value(value: userBloc),
        BlocProvider<BalanceBloc>.value(value: balanceBloc),
        BlocProvider<TransactionBloc>.value(value: transactionBloc),
        BlocProvider<DeepLinkBloc>.value(value: deepLinkBloc),
        BlocProvider<NfcBloc>.value(value: nfcBloc),
        BlocProvider<BluetoothBloc>.value(value: bluetoothBloc),
        BlocProvider<GroupBloc>.value(value: groupBloc),
      ],
      child: const MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: HomeScreen(),
      ),
    );
  }

  void givenStates(UserState u, BalanceState b) {
    when(() => userBloc.state).thenReturn(u);
    when(() => balanceBloc.state).thenReturn(b);
    whenListen(userBloc, const Stream<UserState>.empty(), initialState: u);
    whenListen(
      balanceBloc,
      const Stream<BalanceState>.empty(),
      initialState: b,
    );
  }

  /// Pumps the screen and lets the secure-storage read complete.
  Future<void> pumpHome(WidgetTester tester) async {
    // Phone-sized portrait viewport (the default 800x600 landscape surface
    // is too short for the empty-state illustration + button).
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrap());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
  }

  group('HomeScreen – rendering', () {
    testWidgets('renders without crashing', (tester) async {
      givenStates(UserLoading(), BalanceLoading());
      await pumpHome(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('shows Friends and Groups tabs', (tester) async {
      givenStates(UserLoading(), BalanceLoading());
      await pumpHome(tester);
      expect(find.text('Friends'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);
    });

    testWidgets('shows balance summary card with settled total', (
      tester,
    ) async {
      givenStates(UserLoaded([]), BalanceLoaded([]));
      await pumpHome(tester);
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('shows notification icon', (tester) async {
      givenStates(UserLoading(), BalanceLoading());
      await pumpHome(tester);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('shows person avatar in top bar', (tester) async {
      givenStates(UserLoading(), BalanceLoading());
      await pumpHome(tester);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('tapping avatar opens ProfileScreen', (tester) async {
      givenStates(UserLoading(), BalanceLoading());
      await pumpHome(tester);
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });

  group('HomeScreen – loading', () {
    testWidgets('shows spinner when address not stored yet', (tester) async {
      _storeAddress(null);
      givenStates(UserLoaded([_user()]), BalanceLoaded([]));
      await pumpHome(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('No Expenses Found'), findsNothing);
    });

    testWidgets('shows spinner when UserLoading and BalanceLoading', (
      tester,
    ) async {
      _storeAddress(_myAddress);
      givenStates(UserLoading(), BalanceLoading());
      await pumpHome(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('HomeScreen – error', () {
    testWidgets('shows error message when UserError', (tester) async {
      _storeAddress(_myAddress);
      givenStates(UserError('DB failed'), BalanceLoaded([]));
      await pumpHome(tester);
      expect(find.text('Error: DB failed'), findsOneWidget);
    });
  });

  group('HomeScreen – empty state', () {
    testWidgets('shows "No Expenses Found" when no user matches address', (
      tester,
    ) async {
      _storeAddress(_myAddress);
      givenStates(UserLoaded([_user()]), BalanceLoaded([]));
      await pumpHome(tester);
      expect(find.text('No Expenses Found'), findsOneWidget);
    });

    testWidgets('shows "No Expenses Found" when current user has no friends', (
      tester,
    ) async {
      _storeAddress(_myAddress);
      givenStates(
        UserLoaded([_user(key: _myAddress, name: 'Me')]),
        BalanceLoaded([]),
      );
      await pumpHome(tester);
      expect(find.text('No Expenses Found'), findsOneWidget);
      expect(find.byType(FriendsList), findsNothing);
    });

    testWidgets('shows "Add An Expense" button in empty state', (tester) async {
      _storeAddress(_myAddress);
      givenStates(UserLoaded([_user()]), BalanceLoaded([]));
      await pumpHome(tester);
      expect(find.text('Add An Expense'), findsOneWidget);
    });
  });

  group('HomeScreen – friends list', () {
    testWidgets('shows FriendsList when current user has friends', (
      tester,
    ) async {
      _storeAddress(_myAddress);
      final me = _user(key: _myAddress, name: 'Me');
      final friend = _user(key: '0xFRIEND', name: 'Bob');
      final balance = _balance(key: '0xFRIEND', amount: 200);

      givenStates(UserLoaded([me, friend]), BalanceLoaded([balance]));
      await pumpHome(tester);

      expect(find.byType(FriendsList), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('No Expenses Found'), findsNothing);
      // Analytics shortcut on the balance card only appears with friends.
      expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
    });
  });

  group('HomeScreen – event dispatch on init', () {
    testWidgets('dispatches LoadAllUsers on init', (tester) async {
      givenStates(UserInitial(), BalanceInitial());
      await pumpHome(tester);
      verify(
        () => userBloc.add(any(that: isA<LoadAllUsers>())),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('dispatches LoadAllBalances on init', (tester) async {
      givenStates(UserInitial(), BalanceInitial());
      await pumpHome(tester);
      verify(
        () => balanceBloc.add(any(that: isA<LoadAllBalances>())),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('dispatches LoadAllTransactions on init', (tester) async {
      givenStates(UserInitial(), BalanceInitial());
      await pumpHome(tester);
      verify(
        () => transactionBloc.add(any(that: isA<LoadAllTransactions>())),
      ).called(1);
    });

    testWidgets('dispatches LoadAllGroups on init', (tester) async {
      givenStates(UserInitial(), BalanceInitial());
      await pumpHome(tester);
      verify(
        () => groupBloc.add(any(that: isA<LoadAllGroups>())),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('reloads users even if already UserLoaded', (tester) async {
      givenStates(UserLoaded([_user()]), BalanceLoaded([]));
      await pumpHome(tester);
      verify(
        () => userBloc.add(any(that: isA<LoadAllUsers>())),
      ).called(greaterThanOrEqualTo(1));
    });
  });

  group('HomeScreen – top bar actions', () {
    testWidgets('NFC, QR scanner and notification icons are present', (
      tester,
    ) async {
      givenStates(UserLoading(), BalanceLoading());
      await pumpHome(tester);
      expect(find.byIcon(Icons.nfc_rounded), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('tapping NFC icon dispatches NfcStartListening', (
      tester,
    ) async {
      givenStates(UserLoading(), BalanceLoading());
      await pumpHome(tester);
      await tester.tap(find.byIcon(Icons.nfc_rounded));
      await tester.pump();
      verify(() => nfcBloc.add(any(that: isA<NfcStartListening>()))).called(1);
    });

    testWidgets('NFC button shows spinner and is disabled while busy', (
      tester,
    ) async {
      when(() => nfcBloc.state).thenReturn(const NfcState(isBusy: true));
      _storeAddress(_myAddress);
      givenStates(UserLoaded([_user()]), BalanceLoaded([]));
      await pumpHome(tester);
      expect(find.byIcon(Icons.nfc_rounded), findsNothing);
      final nfcButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(IconButton),
        ),
      );
      expect(nfcButton.onPressed, isNull);
    });
  });
}
