import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart' hide State;
import 'package:web3dart/credentials.dart';
import 'package:zplit/routing/App_router.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';

import 'package:zplit/ui/users/view_model/user_event.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';

const _storage = FlutterSecureStorage();
const _privateKeyStorageKey = 'evm_private_key';
const _addressStorageKey = 'evm_address';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    _initWalletAndLoad();
  }

  Future<void> _initWalletAndLoad() async {
    await _ensureWalletExists();

    if (mounted) {
      context.read<UserBloc>().add(LoadAllUsers());
    }
  }

  Future<void> _ensureWalletExists() async {
    try {
      final existing = await _storage.read(key: _privateKeyStorageKey);
      if (existing != null) return; // already generated

      // Generate EVM-compatible key pair using pointycastle
      final keyParams = ECKeyGeneratorParameters(ECCurve_secp256k1());
      final secureRandom = FortunaRandom();

      final seedSource = Random.secure();
      final seed = List<int>.generate(32, (_) => seedSource.nextInt(256));
      secureRandom.seed(KeyParameter(Uint8List.fromList(seed)));

      final generator = ECKeyGenerator()
        ..init(ParametersWithRandom(keyParams, secureRandom));

      final keyPair = generator.generateKeyPair();
      final privateKey = keyPair.privateKey as ECPrivateKey;
      final privateKeyHex = privateKey.d!.toRadixString(16).padLeft(64, '0');

      // Derive EVM address from private key using web3dart
      final credentials = EthPrivateKey.fromHex(privateKeyHex);
      final address = credentials.address.hex;

      // Store securely — never exposed to user unless they opt into settlement
      await _storage.write(key: _privateKeyStorageKey, value: privateKeyHex);
      await _storage.write(key: _addressStorageKey, value: address);

      debugPrint('EVM wallet generated silently ✓');
    } catch (e) {
      debugPrint('Wallet generation error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoaded) {
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (!mounted) return;
            if (state.users.isEmpty) {
              Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          });
        }
        if (state is UserError) {
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
          });
        }
      },
      child: Scaffold(
        backgroundColor: primaryColor,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: const _ZplitLogo(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ZplitLogo extends StatelessWidget {
  const _ZplitLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Image.asset(
        'assets/images/zplitLogo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/zplit-logo.png',
            fit: BoxFit.contain,
          );
        },
      ),
    );
  }
}
