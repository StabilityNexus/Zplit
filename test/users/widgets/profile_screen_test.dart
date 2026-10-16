import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_event.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';
import 'package:zplit/ui/users/widgets/profile_screen.dart';

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

const _address = '0x1234567890abcdef';

UserModel _user({String key = _address, String name = 'Alice'}) => UserModel(
  publicKey: key,
  displayName: name,
  cryptoAddress: key,
  profilePicture: null,
  defaultCurrency: '₹',
);

/// Makes the screen's `FlutterSecureStorage().read('evm_address')` resolve
/// to [address] (or null) without touching the platform channel.
void _storeAddress(String? address) {
  FlutterSecureStorage.setMockInitialValues(
    address == null ? {} : {'evm_address': address},
  );
}

void main() {
  late MockUserBloc userBloc;

  void givenUserState(UserState state) {
    when(() => userBloc.state).thenReturn(state);
    whenListen(userBloc, const Stream<UserState>.empty(), initialState: state);
  }

  setUp(() {
    userBloc = MockUserBloc();
    givenUserState(UserInitial());
    _storeAddress(null);
  });

  Widget wrap({Widget home = const ProfileScreen()}) {
    return BlocProvider<UserBloc>.value(
      value: userBloc,
      child: MaterialApp(home: home),
    );
  }

  group('ProfileScreen – rendering', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('shows "Profile" in app bar', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('shows "My Profile" heading when no current user', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('shows current user name and short address when loaded', (
      tester,
    ) async {
      _storeAddress(_address);
      givenUserState(
        UserLoaded([
          _user(),
          _user(key: '0xFRIEND0000', name: 'Bob'),
        ]),
      );
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('My Profile'), findsNothing);
      expect(find.text('0x1234...cdef'), findsOneWidget);
    });

    testWidgets('shows person icon avatar', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows empty address text when address is null', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text(''), findsOneWidget);
      expect(find.textContaining('...'), findsNothing);
    });
  });

  group('ProfileScreen – app bar', () {
    testWidgets('shows back (chevron_left) button', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('shows edit icon', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('shows QR code icon', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
    });

    testWidgets('back button pops the screen', (tester) async {
      await tester.pumpWidget(
        wrap(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () => Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: const Text('Go'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsNothing);
      expect(find.text('Go'), findsOneWidget);
    });
  });

  group('ProfileScreen – General section', () {
    testWidgets('shows "General" section header', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('General'), findsOneWidget);
    });

    testWidgets('shows Theme tile', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('shows "Light" as theme trailing value', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Light'), findsOneWidget);
    });

    testWidgets('shows Payment History tile', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Payment History'), findsOneWidget);
    });

    testWidgets('shows Manage Friends and Groups tile', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Manage Friends and Groups'), findsOneWidget);
    });

    testWidgets('shows Invite Friends tile', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Invite Friends'), findsOneWidget);
    });
  });

  group('ProfileScreen – Feedback section', () {
    testWidgets('shows Feedback tile', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Feedback'), 200);
      expect(find.text('Feedback'), findsOneWidget);
    });

    testWidgets('shows Contact Us tile', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Contact Us'), 200);
      expect(find.text('Contact Us'), findsOneWidget);
    });
  });

  group('ProfileScreen – Log Out', () {
    testWidgets('shows Log Out button', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Log Out'), 200);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('Log Out button is red', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Log Out'), 200);

      final textWidget = tester.widget<Text>(find.text('Log Out'));
      expect(textWidget.style?.color, Colors.red);
    });

    testWidgets('tapping Log Out does not crash', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Log Out'), 200);
      await tester.tap(find.text('Log Out'));
      await tester.pump();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });

  group('ProfileScreen – tile interactions', () {
    testWidgets('tapping Theme tile does not crash', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text('Theme'));
      await tester.pump();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('tapping Payment History does not crash', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text('Payment History'));
      await tester.pump();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('tapping edit icon does not crash', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pump();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('tapping QR icon without a current user stays on screen', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.qr_code_2));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });
}
