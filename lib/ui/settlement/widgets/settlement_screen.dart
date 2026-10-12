import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/core/services/settlement_service.dart';
import 'package:zplit/ui/settlement/view_model/settlement_bloc.dart';
import 'package:zplit/ui/settlement/view_model/settlement_event.dart';
import 'package:zplit/ui/settlement/view_model/settlement_state.dart';

class SettlementScreen extends StatelessWidget {
  final String friendName;
  final String friendWalletAddress;

  final double balanceInInr;

  final double balanceInUsdc;

  const SettlementScreen({
    super.key,
    required this.friendName,
    required this.friendWalletAddress,
    required this.balanceInInr,
    required this.balanceInUsdc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettlementBloc(),
      child: _SettlementView(
        friendName: friendName,
        friendWalletAddress: friendWalletAddress,
        balanceInInr: balanceInInr,
        balanceInUsdc: balanceInUsdc,
      ),
    );
  }
}

class _SettlementView extends StatelessWidget {
  final String friendName;
  final String friendWalletAddress;
  final double balanceInInr;
  final double balanceInUsdc;

  const _SettlementView({
    required this.friendName,
    required this.friendWalletAddress,
    required this.balanceInInr,
    required this.balanceInUsdc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settle Balance')),
      body: BlocConsumer<SettlementBloc, SettlementState>(
        listener: (context, state) {
          if (state is SettlementLaunched) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final isLaunching = state is SettlementLaunching;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      _row(theme, 'Settling with', friendName),
                      const SizedBox(height: 12),
                      _row(
                        theme,
                        'Current balance',
                        '₹${balanceInInr.abs().toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _row(
                        theme,
                        'You will send',
                        '${balanceInUsdc.toStringAsFixed(2)} USDC',
                        highlight: true,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tapping below opens your wallet app (MetaMask, Trust '
                  'Wallet, etc.) with the USDC transfer pre-filled. Confirm '
                  'the send inside your wallet app — Zplit does not custody '
                  'or move funds directly.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                if (state is SettlementNoWalletFound) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: colors.error),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No wallet app found on this device.',
                            style: TextStyle(color: colors.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: SettlementService.redirectToWalletInstall,
                    child: const Text('Install MetaMask'),
                  ),
                  const SizedBox(height: 12),
                ],
                if (state is SettlementError) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Something went wrong opening your wallet app.',
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                ],
                ElevatedButton(
                  onPressed: isLaunching
                      ? null
                      : () => context.read<SettlementBloc>().add(
                          SettleRequested(
                            friendWalletAddress: friendWalletAddress,
                            usdcAmount: balanceInUsdc,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLaunching
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Settle with Wallet'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(
    ThemeData theme,
    String label,
    String value, {
    bool highlight = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.55),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: highlight ? color : null,
          ),
        ),
      ],
    );
  }
}
