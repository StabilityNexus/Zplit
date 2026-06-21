import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/balances_dao.dart';
import 'package:zplit/core/database/daos/transactions_dao.dart';
import 'package:zplit/core/database/daos/users_dao.dart';
import 'package:zplit/data/balance/balance_repository.dart';
import 'package:zplit/data/transaction/transaction_repository.dart';
import 'package:zplit/data/user/user_repository.dart';
import 'package:zplit/routing/App_router.dart';
import 'package:zplit/ui/balance/view_model/balance_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/core/theme/app_theme.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print('onError -- ${bloc.runtimeType}, $error');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- ${bloc.runtimeType}');
  }
}

// Create db at top level — safe for Drift's LazyDatabase
final _db = AppDatabase();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ← back to const, no parameter needed

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserBloc(
            userRepository: UserRepositoryImpl(usersDao: UsersDao(_db)),
          ),
        ),
        BlocProvider(
          create: (_) => BalanceBloc(
            balanceRepository: BalanceRepositoryImpl(
              balancesDao: BalancesDao(_db),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => TransactionBloc(
            transactionRepository: TransactionRepositoryImpl(
              transactionsDao: TransactionsDao(_db),
              balancesDao: BalancesDao(_db),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Zplit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // ← your exact theme
        darkTheme: AppTheme.darkTheme, // ← dark mode too
        themeMode: ThemeMode.system, // ← follows device setting
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRoutes.splash,
      ),
    );
  }
}
