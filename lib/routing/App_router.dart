import 'package:flutter/material.dart';
import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';

import 'package:zplit/ui/onboarding/widgets/Account_setup_screen.dart';
import 'package:zplit/ui/onboarding/widgets/Onboarding_screen.dart';
import 'package:zplit/ui/onboarding/widgets/Splash_screen.dart';
import 'package:zplit/ui/transaction/widgets/analytics_screen.dart';
import 'package:zplit/ui/transaction/widgets/expense.dart';
import 'package:zplit/ui/group/widgets/friends_Detail.dart';
import 'package:zplit/ui/transaction/widgets/qr_screen.dart';
import 'package:zplit/ui/users/widgets/home_Screen.dart';
import 'package:zplit/ui/group/widgets/invite_friends.dart';
import 'package:zplit/ui/users/widgets/profile_screen.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const accountSetup = '/account-setup';
  static const home = '/home';
  static const inviteFriends = '/invite-friends';
  static const addExpense = '/add-expense';
  static const friendDetail = '/friend-detail';
  static const profile = '/profile';
  static const analytics = '/analytics';
  static const qrScanner = '/qr-scanner';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(const SplashScreen());

      case AppRoutes.onboarding:
        return _slide(const OnboardingScreen());

      case AppRoutes.accountSetup:
        return _slide(const AccountSetupScreen());

      case AppRoutes.home:
        return _fade(const HomeScreen());
      case AppRoutes.inviteFriends:
        final args = settings.arguments as Map<String, dynamic>;
        return _slide(
          InviteFriendsScreen(
            userId: args['id'] as String,
            name: args['name'] as String,
            address: args['address'] as String,
          ),
        );
      case AppRoutes.addExpense:
        return _slide(const AddExpenseScreen());
      case AppRoutes.friendDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return _slide(
          FriendDetailScreen(
            friend: args['friend'] as UserModel,
            balance: args['balance'] as BalanceModel?,
            currentUserPublicKey: args['currentUserPublicKey'] as String,
          ),
        );
      case AppRoutes.qrScanner:
        return _slide(const QrScannerScreen());
      case AppRoutes.profile:
        return _slide(const ProfileScreen());
      case AppRoutes.analytics:
        return _slide(const AnalyticsScreen());

      default:
        return _fade(const SplashScreen());
    }
  }

  static PageRouteBuilder _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        return FadeTransition(opacity: anim, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: anim.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
