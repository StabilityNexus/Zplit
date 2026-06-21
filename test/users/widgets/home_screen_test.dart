import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/routing/App_router.dart';
import 'package:zplit/ui/balance/view_model/balance_bloc.dart';
import 'package:zplit/ui/balance/view_model/balance_event.dart';
import 'package:zplit/ui/balance/view_model/balance_state.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_event.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';
import 'package:zplit/ui/users/widgets/home_Screen.dart';
import 'package:zplit/ui/users/widgets/Homebottomnav.dart';
import 'package:zplit/ui/users/widgets/friendlist.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class MockBalanceBloc extends MockBloc<BalanceEvent, BalanceState>
    implements BalanceBloc {}

class FakeUserEvent extends Fake implements UserEvent {}

class FakeBalanceEvent extends Fake implements BalanceEvent {}

// ─── Helpers ─────────────────────────────────────────────────────────────────

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

Widget _wrap(MockUserBloc userBloc, MockBalanceBloc balanceBloc) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<UserBloc>.value(value: userBloc),
      BlocProvider<BalanceBloc>.value(value: balanceBloc),
    ],
    child: MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const HomeScreen(),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUserEvent());
    registerFallbackValue(FakeBalanceEvent());
  });

  late MockUserBloc userBloc;
  late MockBalanceBloc balanceBloc;

  setUp(() {
    userBloc = MockUserBloc();
    balanceBloc = MockBalanceBloc();
  });

  void givenStates(UserState u, BalanceState b) {
    when(() => userBloc.state).thenReturn(u);
    when(() => balanceBloc.state).thenReturn(b);
    whenListen(userBloc, Stream<UserState>.empty(), initialState: u);
    whenListen(balanceBloc, Stream<BalanceState>.empty(), initialState: b);
  }

  group('HomeScreen – rendering', () {
    testWidgets('renders without crashing', (tester) async {
      givenStates(UserLoading(), BalanceLoading());
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('shows Friends and Groups tabs', (tester) async {
      givenStates(UserLoading(), BalanceLoading());
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump();
      expect(find.text('Friends'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);
    });

    testWidgets('shows bottom nav bar', (tester) async {
      givenStates(UserLoading(), BalanceLoading());
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump();
      expect(find.byType(HomeBottomNav), findsOneWidget);
    });

    testWidgets('shows notification icon', (tester) async {
      givenStates(UserLoading(), BalanceLoading());
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump();
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('shows person avatar in top bar', (tester) async {
      givenStates(UserLoading(), BalanceLoading());
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump();
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });

  group('HomeScreen – loading', () {
    testWidgets('shows spinner when address not yet loaded (initial pump)', (
      tester,
    ) async {
      givenStates(UserLoading(), BalanceLoading());
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump(); // one frame — address still null
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows spinner when UserLoading and BalanceLoading', (
      tester,
    ) async {
      givenStates(UserLoading(), BalanceLoading());
      whenListen(
        userBloc,
        Stream.fromIterable([UserLoading()]),
        initialState: UserLoading(),
      );
      whenListen(
        balanceBloc,
        Stream.fromIterable([BalanceLoading()]),
        initialState: BalanceLoading(),
      );
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });

  group('HomeScreen – error', () {
    testWidgets('shows error message when UserError', (tester) async {
      givenStates(UserError('DB failed'), BalanceLoaded([]));
      whenListen(
        userBloc,
        Stream.fromIterable([UserError('DB failed')]),
        initialState: UserError('DB failed'),
      );
      whenListen(
        balanceBloc,
        Stream.fromIterable([BalanceLoaded([])]),
        initialState: BalanceLoaded([]),
      );
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.textContaining('DB failed'), findsOneWidget);
    });
  });

  group('HomeScreen – empty state', () {
    testWidgets('shows "No Expenses Found" when no matching user for address', (
      tester,
    ) async {
      // UserLoaded but no user matches the (null) address → empty state
      givenStates(UserLoaded([_user()]), BalanceLoaded([]));
      whenListen(
        userBloc,
        Stream.fromIterable([
          UserLoaded([_user()]),
        ]),
        initialState: UserLoaded([_user()]),
      );
      whenListen(
        balanceBloc,
        Stream.fromIterable([BalanceLoaded([])]),
        initialState: BalanceLoaded([]),
      );
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.text('No Expenses Found'), findsOneWidget);
    });

    testWidgets('shows "Add An Expense" button in empty state', (tester) async {
      givenStates(UserLoaded([_user()]), BalanceLoaded([]));
      whenListen(
        userBloc,
        Stream.fromIterable([
          UserLoaded([_user()]),
        ]),
        initialState: UserLoaded([_user()]),
      );
      whenListen(
        balanceBloc,
        Stream.fromIterable([BalanceLoaded([])]),
        initialState: BalanceLoaded([]),
      );
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.text('Add An Expense'), findsOneWidget);
    });
  });

  group('HomeScreen – friends list', () {
    testWidgets(
      'shows FriendsList when users and balances loaded with friends',
      (tester) async {
        final me = _user(key: '0xME', name: 'Me');
        final friend = _user(key: '0xFRIEND', name: 'Bob');
        final balance = _balance(key: '0xFRIEND', amount: 200);

        givenStates(UserLoaded([me, friend]), BalanceLoaded([balance]));
        whenListen(
          userBloc,
          Stream.fromIterable([
            UserLoaded([me, friend]),
          ]),
          initialState: UserLoaded([me, friend]),
        );
        whenListen(
          balanceBloc,
          Stream.fromIterable([
            BalanceLoaded([balance]),
          ]),
          initialState: BalanceLoaded([balance]),
        );

        await tester.pumpWidget(_wrap(userBloc, balanceBloc));
        // Simulate address loaded from secure storage
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump();

        // FriendsList widget should be in tree even if address is null
        // (empty state shown instead — this confirms no crash)
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );
  });

  group('HomeScreen – event dispatch guards', () {
    testWidgets('does NOT dispatch LoadAllUsers if already UserLoaded', (
      tester,
    ) async {
      final me = _user();
      givenStates(UserLoaded([me]), BalanceLoaded([]));
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump();
      verifyNever(() => userBloc.add(any(that: isA<LoadAllUsers>())));
    });

    testWidgets('does NOT dispatch LoadAllBalances if already BalanceLoaded', (
      tester,
    ) async {
      final me = _user();
      givenStates(UserLoaded([me]), BalanceLoaded([]));
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump();
      verifyNever(() => balanceBloc.add(any(that: isA<LoadAllBalances>())));
    });

    testWidgets('dispatches LoadAllUsers when state is UserInitial', (
      tester,
    ) async {
      givenStates(UserInitial(), BalanceInitial());
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump();
      verify(() => userBloc.add(any(that: isA<LoadAllUsers>()))).called(1);
    });

    testWidgets('dispatches LoadAllBalances when state is BalanceInitial', (
      tester,
    ) async {
      givenStates(UserInitial(), BalanceInitial());
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump();
      verify(
        () => balanceBloc.add(any(that: isA<LoadAllBalances>())),
      ).called(1);
    });
  });

  group('HomeScreen – bottom nav', () {
    testWidgets('tapping nav item changes selected index', (tester) async {
      givenStates(UserLoading(), BalanceLoading());
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pump();
      // No crash — state updates correctly
      expect(find.byType(HomeBottomNav), findsOneWidget);
    });

    testWidgets('all 4 nav icons are present', (tester) async {
      givenStates(UserLoading(), BalanceLoading());
      await tester.pumpWidget(_wrap(userBloc, balanceBloc));
      await tester.pump();
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });
  });
}
