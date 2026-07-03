import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/balances_dao.dart';
import 'package:zplit/core/database/daos/transactions_dao.dart';
import 'package:zplit/core/database/daos/users_dao.dart';
import 'package:zplit/core/services/deep_link_service.dart';
import 'package:zplit/data/balance/balance_repository.dart';
import 'package:zplit/data/transaction/transaction_repository.dart';
import 'package:zplit/data/user/user_repository.dart';
import 'package:zplit/routing/App_router.dart';
import 'package:zplit/ui/balance/view_model/balance_bloc.dart';
import 'package:zplit/ui/deep_link/view_model/deep_link_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_event.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/core/theme/app_theme.dart';
import 'package:zplit/ui/users/view_model/user_event.dart';

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
final _deepLinkService = DeepLinkService();
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
    // Create shared instances so all blocs use the same DAOs
    final usersDao = UsersDao(_db);
    final balancesDao = BalancesDao(_db);
    final transactionsDao = TransactionsDao(_db);

    final userRepository = UserRepositoryImpl(usersDao: usersDao);
    final balanceRepository = BalanceRepositoryImpl(balancesDao: balancesDao);
    final transactionRepository = TransactionRepositoryImpl(
      transactionsDao: transactionsDao,
      balancesDao: balancesDao,
    );

    // Create BalanceBloc first since TransactionBloc depends on it
    final balanceBloc = BalanceBloc(balanceRepository: balanceRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UserBloc(userRepository: userRepository)),
        BlocProvider.value(value: balanceBloc),
        BlocProvider(
          create: (_) => TransactionBloc(
            transactionRepository: transactionRepository,
            balanceBloc: balanceBloc, // ✅ injected
          ),
        ),
        BlocProvider(
          create: (_) => DeepLinkBloc(
            userRepository: userRepository,
            transactionRepository: transactionRepository,
          ),
        ),
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
          return DeepLinkListener(
            deepLinkService: _deepLinkService,
            child: child!,
          );
        },
      ),
    );
  }
}

class DeepLinkListener extends StatefulWidget {
  final DeepLinkService deepLinkService;
  final Widget child;

  const DeepLinkListener({
    super.key,
    required this.deepLinkService,
    required this.child,
  });

  @override
  State<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends State<DeepLinkListener> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final bloc = context.read<DeepLinkBloc>();

    final initial = await widget.deepLinkService.getInitialLink();
    if (initial != null) bloc.add(DeepLinkReceived(initial));

    widget.deepLinkService.listen((uri) {
      bloc.add(DeepLinkReceived(uri));
    });
  }

  @override
  void dispose() {
    widget.deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeepLinkBloc, DeepLinkState>(
      listener: (context, state) {
        final nav = _navigatorKey.currentState!;
        final messenger = ScaffoldMessenger.of(_navigatorKey.currentContext!);

        if (state is InviteHandled) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('${state.displayName} added to your contacts!'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          // Refresh users after invite
          context.read<UserBloc>().add(LoadAllUsers());
          nav.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        } else if (state is TransactionReceived) {
          // Navigate home first, then the HomeScreen BlocListener shows the popup
          nav.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        } else if (state is DeepLinkUnknownSender) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Transaction from unknown contact. Ask them to share their invite link first.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is DeepLinkError) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Deep link error: ${state.message}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: widget.child,
    );
  }
}
