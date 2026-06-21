import 'package:flutter/material.dart';
import 'package:zplit/ui/transaction/widgets/Owe-toggle.dart';

/// Analytics screen: currently just the "I owe / Owes me" summary.
/// The expense trend and spending breakdown cards (see expense_chart_card.dart
/// and spending_breakdown_card.dart) are built but intentionally not wired in
/// here yet — add them back to the ListView below once real data is ready.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _showOwedToMe = true;

  static const _oweToMeAmount = 0;
  static const _iOweAmount = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = _showOwedToMe ? _oweToMeAmount : _iOweAmount;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Center(
                    child: OweToggle(
                      showOwedToMe: _showOwedToMe,
                      onChanged: (val) => setState(() => _showOwedToMe = val),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${amount.toInt()}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_upward_rounded,
                          color: Color(0xFF16A34A),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 28,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          Expanded(
            child: Text(
              'Analytics',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(
            width: 48,
          ), // balances the back button for true centering
        ],
      ),
    );
  }
}
