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
import 'package:zplit/ui/bluetooth/bluetooth_link_bridge.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_bloc.dart';
import 'package:zplit/ui/deep_link/app_listener.dart';
import 'package:zplit/ui/deep_link/view_model/deep_link_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/core/theme/app_theme.dart';
import 'package:zplit/ui/nfc/view_model/nfc_bloc.dart';
import 'package:zplit/ui/nfc/nfc_link_bridge.dart'; // NEW

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

final _db = AppDatabase();
final _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final usersDao = UsersDao(_db);
    final balancesDao = BalancesDao(_db);
    final transactionsDao = TransactionsDao(_db);

    final userRepository = UserRepositoryImpl(usersDao: usersDao);
    final balanceRepository = BalanceRepositoryImpl(balancesDao: balancesDao);
    final transactionRepository = TransactionRepositoryImpl(
      transactionsDao: transactionsDao,
      balancesDao: balancesDao,
    );

    final balanceBloc = BalanceBloc(balanceRepository: balanceRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UserBloc(userRepository: userRepository)),
        BlocProvider.value(value: balanceBloc),
        BlocProvider(
          create: (_) => TransactionBloc(
            transactionRepository: transactionRepository,
            balanceBloc: balanceBloc,
          ),
        ),
        BlocProvider(
          create: (_) => DeepLinkBloc(
            userRepository: userRepository,
            transactionRepository: transactionRepository,
          ),
        ),
        BlocProvider(create: (_) => BluetoothBloc()),
        BlocProvider(create: (_) => NfcBloc()),
      ],
      child: MaterialApp(
        title: 'Zplit',
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRoutes.splash,
        builder: (context, child) {
          return AppLinkListener(
            child: BluetoothLinkBridge(child: NfcLinkBridge(child: child!)),
          );
        },
      ),
    );
  }
}
