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
import 'package:zplit/ui/group/widgets/friends_Detail.dart';
import 'package:zplit/ui/nfc/view_model/nfc_bloc.dart';
import 'package:zplit/ui/nfc/view_model/nfc_event.dart';
import 'package:zplit/ui/nfc/view_model/nfc_state.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_event.dart';
import 'package:zplit/ui/transaction/view_model/transaction_state.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_event.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';
import 'package:zplit/ui/users/widgets/friendtile.dart';

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

// The friend page is a full screen, so it (and anything it builds) may look up
// any of the app's blocs. These quiet stand-ins make that safe in this test.
class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class MockBluetoothBloc extends MockBloc<BluetoothEvent, BluetoothState>
    implements BluetoothBloc {}

class MockNfcBloc extends MockBloc<NfcEvent, NfcState> implements NfcBloc {}

class MockDeepLinkBloc extends MockBloc<DeepLinkEvent, DeepLinkState>
    implements DeepLinkBloc {}

/// Quiet BalanceBloc stand-in: stays in BalanceLoading and emits nothing.
///
/// FriendDetailScreen now reads BalanceBloc. The state is deliberately NOT
/// BalanceLoaded: while it is not loaded, the screen keeps showing the
/// `balance:` the test passes in, so existing amount expectations keep
/// working (a loaded list without this friend would mean "settled").
class StubBalanceBloc extends MockBloc<BalanceEvent, BalanceState>
    implements BalanceBloc {}

StubBalanceBloc stubbedBalanceBloc() {
  final bloc = StubBalanceBloc();
  whenListen(
    bloc,
    const Stream<BalanceState>.empty(),
    initialState: BalanceLoading(),
  );
  return bloc;
}

/// Quiet GroupBloc stand-in: stays in GroupInitial and emits nothing.
class StubGroupBloc extends MockBloc<GroupEvent, GroupState>
    implements GroupBloc {}

StubGroupBloc stubbedGroupBloc() {
  final bloc = StubGroupBloc();
  whenListen(
    bloc,
    const Stream<GroupState>.empty(),
    initialState: GroupInitial(),
  );
  return bloc;
}

UserModel _user({
  String key = '0xABC',
  String name = 'Alice',
  String? picture,
}) => UserModel(
  publicKey: key,
  displayName: name,
  cryptoAddress: key,
  profilePicture: picture,
  defaultCurrency: '₹',
);

BalanceModel _balance({
  String key = '0xABC',
  int amount = 100,
  String currency = '₹',
}) => BalanceModel(
  userPublicKey: key,
  netAmount: amount,
  currency: currency,
  updatedAt: DateTime(2024, 6, 15),
);

Widget _wrap(Widget child) => MaterialApp(
  onGenerateRoute: AppRouter.onGenerateRoute,
  home: Scaffold(body: child),
);

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    // FriendDetailScreen (opened by the navigation test) reads pending
    // settlement payments from secure storage.
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('FriendTile – rendering', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: null,
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.byType(FriendTile), findsOneWidget);
    });

    testWidgets('shows display name', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(name: 'Bob'),
            balance: null,
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows first letter of name as avatar when no picture', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(name: 'Charlie'),
            balance: null,
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('shows "?" as avatar when display name is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(name: ''),
            balance: null,
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('shows formatted date when balance is present', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(), // updatedAt: 2024-06-15
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('15 Jun'), findsOneWidget);
    });

    testWidgets('hides date when balance is null', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: null,
            currentUserPublicKey: '0xME',
          ),
        ),
      );

      expect(find.text('15 Jun'), findsNothing);
    });
  });

  group('FriendTile – amount labels', () {
    testWidgets('shows "Settled up" when netAmount is 0', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: 0),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('Settled up'), findsOneWidget);
    });

    testWidgets('shows "Settled up" when balance is null', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: null,
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('Settled up'), findsOneWidget);
    });

    testWidgets('shows "Owes you:" when netAmount is positive', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: 50000),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('Owes you:'), findsOneWidget);
    });

    testWidgets('shows correct amount when positive', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: 50000),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('₹500.00'), findsOneWidget);
    });

    testWidgets('shows "You owe:" when netAmount is negative', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: -20000),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('You owe:'), findsOneWidget);
    });

    testWidgets('shows absolute amount when negative', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: -20000),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      // netAmount is in paise: shows 200.00, not -200.00
      expect(find.text('₹200.00'), findsOneWidget);
      expect(find.text('₹-200.00'), findsNothing);
    });

    testWidgets('hides amount text when settled', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: 0),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('₹0.00'), findsNothing);
    });

    testWidgets('shows correct currency symbol from balance', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: 30000, currency: '\$'),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('\$300.00'), findsOneWidget);
    });

    testWidgets('converts paise to rupees with two decimals', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: 12345),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('₹123.45'), findsOneWidget);
    });
  });

  group('FriendTile – navigation', () {
    testWidgets('tapping tile opens FriendDetailScreen for that friend', (
      tester,
    ) async {
      // FriendDetailScreen reads TransactionBloc and BalanceBloc from context;
      // the other blocs are provided too so nothing it builds can fail with
      // "Could not find the correct Provider".
      final transactionBloc = MockTransactionBloc();
      when(() => transactionBloc.state).thenReturn(TransactionInitial());
      final balanceBloc = stubbedBalanceBloc();
      final groupBloc = stubbedGroupBloc();
      final userBloc = MockUserBloc();
      when(() => userBloc.state).thenReturn(UserInitial());
      final bluetoothBloc = MockBluetoothBloc();
      when(() => bluetoothBloc.state).thenReturn(const BluetoothState());
      final nfcBloc = MockNfcBloc();
      when(() => nfcBloc.state).thenReturn(const NfcState());
      final deepLinkBloc = MockDeepLinkBloc();
      when(() => deepLinkBloc.state).thenReturn(DeepLinkInitial());

      final user = _user(name: 'Alice');
      final balance = _balance(amount: 100);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<TransactionBloc>.value(value: transactionBloc),
            BlocProvider<BalanceBloc>.value(value: balanceBloc),
            BlocProvider<GroupBloc>.value(value: groupBloc),
            BlocProvider<UserBloc>.value(value: userBloc),
            BlocProvider<BluetoothBloc>.value(value: bluetoothBloc),
            BlocProvider<NfcBloc>.value(value: nfcBloc),
            BlocProvider<DeepLinkBloc>.value(value: deepLinkBloc),
          ],
          child: _wrap(
            FriendTile(
              user: user,
              balance: balance,
              currentUserPublicKey: '0xME',
            ),
          ),
        ),
      );
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final detail = tester.widget<FriendDetailScreen>(
        find.byType(FriendDetailScreen),
      );
      expect(detail.friend, same(user));
      expect(detail.balance, same(balance));
      expect(detail.currentUserPublicKey, '0xME');
    });
  });
}
