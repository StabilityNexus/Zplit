import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zplit/core/services/bluetooth_service.dart' show BtEndpoint;
import 'package:zplit/core/services/crypto_service.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_bloc.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_event.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_state.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_event.dart';
import 'package:zplit/ui/transaction/view_model/transaction_state.dart';
import 'package:zplit/ui/transaction/widgets/TransactionSentscreen.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _paidForController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedSplit = '';
  String _selectedCategory = '';
  String? _selectedFriendPublicKey;
  String? _selectedFriendName;
  bool _isSending = false;

  final List<String> _categories = [
    'Grocery',
    'Rent',
    'Uber',
    'Drinks',
    'Food',
    'Fuel',
  ];

  final List<String> _splitOptions = [
    'Split Equally',
    'You Paid',
    'They Paid',
    'Custom',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _paidForController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  void _openFriendPicker() {
    final userState = context.read<UserBloc>().state;
    if (userState is! UserLoaded) return;

    const FlutterSecureStorage().read(key: 'evm_address').then((me) {
      final friends = userState.users.where((u) => u.publicKey != me).toList();

      if (friends.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No contacts yet — share your invite link first'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) {
          final theme = Theme.of(context);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Split with',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...friends.map(
                    (f) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.12,
                        ),
                        child: Text(
                          f.displayName.isNotEmpty
                              ? f.displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      title: Text(f.displayName),
                      trailing: _selectedFriendPublicKey == f.publicKey
                          ? Icon(Icons.check, color: theme.colorScheme.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedFriendPublicKey = f.publicKey;
                          _selectedFriendName = f.displayName;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  double _calculateSplitAmount(double totalAmount) {
    switch (_selectedSplit) {
      case 'Split Equally':
        return -(totalAmount / 2);
      case 'You Paid':
        return -totalAmount;
      case 'They Paid':
        return totalAmount;
      case 'Custom':
        return -(totalAmount / 2);
      default:
        return -(totalAmount / 2);
    }
  }

  BtEndpoint? _findConnectedEndpointForFriend(
    BluetoothState btState,
    String friendDisplayName,
  ) {
    for (final endpoint in btState.nearbyEndpoints) {
      final status = btState.connectionStatus[endpoint.id];
      if (endpoint.name == friendDisplayName &&
          status == BtConnectionStatus.connected) {
        return endpoint;
      }
    }
    return null;
  }

  Future<void> _sendExpense() async {
    final totalAmount = double.tryParse(_amountController.text.trim());
    if (totalAmount == null || totalAmount <= 0) {
      _showSnack('Enter a valid amount');
      return;
    }
    if (_selectedFriendPublicKey == null) {
      _showSnack('Select a friend to split with');
      return;
    }
    if (_paidForController.text.trim().isEmpty) {
      _showSnack('Enter what this expense was for');
      return;
    }

    setState(() => _isSending = true);

    try {
      final storage = const FlutterSecureStorage();
      final me = await storage.read(key: 'evm_address') ?? '';
      final txnId = DateTime.now().millisecondsSinceEpoch.toString();
      final desc = _paidForController.text.trim();
      final tag = _selectedCategory.isEmpty ? null : _selectedCategory;
      final splitType = _selectedSplit.isEmpty
          ? 'Split Equally'
          : _selectedSplit;
      final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final splitAmount = _calculateSplitAmount(totalAmount);
      final signedAmountBigInt = BigInt.from((splitAmount * 100).round());

      final senderSignature = await CryptoService.signTransaction(
        id: txnId,
        fromPublicKey: me,
        toPublicKey: _selectedFriendPublicKey!,
        amount: signedAmountBigInt,
        currency: 'INR',
        description: desc,
        tag: tag,
        timestamp: ts,
      );

      context.read<TransactionBloc>().add(
        CreateTransaction(
          fromUserPublicKey: me,
          toUserPublicKey: _selectedFriendPublicKey!,
          amount: signedAmountBigInt,
          currency: 'INR',
          description: desc,
          tag: tag,
        ),
      );

      context.read<TransactionBloc>().add(
        SignAsSender(transactionId: txnId, senderSignature: senderSignature),
      );

      final payload = {
        'id': txnId,
        'from': me,
        'to': _selectedFriendPublicKey,
        'amount': splitAmount,
        'split': splitType,
        'totalAmount': totalAmount,
        'desc': desc,
        'tag': tag,
        'ts': ts,
        'sig': senderSignature,
      };

      bool sentViaBluetooth = false;
      String? bluetoothEndpointId;
      final jsonPayload = jsonEncode(payload);
      final btState = context.read<BluetoothBloc>().state;
      final endpoint = _findConnectedEndpointForFriend(
        btState,
        _selectedFriendName!,
      );
      if (endpoint != null) {
        context.read<BluetoothBloc>().add(
          BluetoothSendPayload(endpoint.id, jsonPayload),
        );
        sentViaBluetooth = true;
        bluetoothEndpointId = endpoint.id;
      }

      final encoded = base64Url.encode(utf8.encode(jsonPayload));
      final link = 'https://zplit.aossie.org/tx?d=$encoded';

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionSentScreen(
            friendName: _selectedFriendName!,
            totalAmount: totalAmount,
            splitAmount: splitAmount,
            splitType: splitType,
            description: desc,
            tag: tag,
            deepLink: link,
            sentViaBluetooth: sentViaBluetooth,
            bluetoothEndpointId: bluetoothEndpointId,
            bluetoothJsonPayload: sentViaBluetooth ? jsonPayload : null,
            nfcJsonPayload: jsonPayload,
          ),
        ),
      );
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionError)
          _showSnack('Transaction error: ${state.message}');
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 28,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Add an Expense',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.camera_alt_outlined,
                color: colors.primary,
                size: 24,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(theme, 'Total Amount'),
              const SizedBox(height: 8),
              _buildInputField(
                theme,
                controller: _amountController,
                hint: '₹ 0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                suffix: Icon(
                  Icons.receipt_outlined,
                  color: colors.primary,
                  size: 20,
                ),
              ),

              const SizedBox(height: 20),
              _buildLabel(theme, 'On Date'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: _fieldDecoration(theme),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate != null
                              ? _formatDate(_selectedDate!)
                              : 'Select date',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _selectedDate != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_outlined,
                        color: colors.primary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _buildLabel(theme, 'Splitting With'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _openFriendPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: _fieldDecoration(theme),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colors.primary.withOpacity(0.12),
                        child: Icon(
                          Icons.person,
                          color: colors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'You',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_selectedFriendName != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: colors.primary.withOpacity(0.12),
                          child: Text(
                            _selectedFriendName![0].toUpperCase(),
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedFriendName!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Icon(
                        _selectedFriendName != null
                            ? Icons.edit_outlined
                            : Icons.person_add_outlined,
                        color: colors.primary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _buildLabel(theme, 'How was this expense split?'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showSplitPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: _fieldDecoration(theme),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedSplit.isEmpty
                              ? 'Select (defaults to Split Equally)'
                              : _selectedSplit,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _selectedSplit.isEmpty
                                ? theme.colorScheme.onSurface.withOpacity(0.4)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),

              if (_amountController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildSplitPreview(theme, colors),
              ],

              const SizedBox(height: 20),
              _buildLabel(theme, 'Paid for'),
              const SizedBox(height: 8),
              _buildInputField(
                theme,
                controller: _paidForController,
                hint: 'e.g. Dinner, Groceries',
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            if (_paidForController.text == cat) {
                              _paidForController.clear();
                            }
                            _selectedCategory = '';
                          } else {
                            final canAutoFill =
                                _paidForController.text.isEmpty ||
                                _paidForController.text == _selectedCategory;
                            if (canAutoFill) {
                              _paidForController.text = cat;
                            }
                            _selectedCategory = cat;
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? colors.primary
                                : theme.dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? colors.primary
                                : theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),
              _buildLabel(theme, 'Notes'),
              const SizedBox(height: 8),
              Container(
                decoration: _fieldDecoration(theme),
                child: TextField(
                  controller: _notesController,
                  maxLines: 4,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintText: 'Optional notes...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Send Expense',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitPreview(ThemeData theme, ColorScheme colors) {
    final total = double.tryParse(_amountController.text.trim()) ?? 0;
    if (total <= 0) return const SizedBox.shrink();
    final split = _calculateSplitAmount(total);
    String previewText;
    if (_selectedSplit == 'They Paid') {
      previewText =
          'You owe ${_selectedFriendName ?? 'friend'} ₹${total.toStringAsFixed(2)}';
    } else if (_selectedSplit == 'You Paid') {
      previewText =
          '${_selectedFriendName ?? 'Friend'} owes you ₹${total.toStringAsFixed(2)}';
    } else {
      previewText =
          '${_selectedFriendName ?? 'Friend'} owes you ₹${split.abs().toStringAsFixed(2)}';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            previewText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withOpacity(0.55),
        fontSize: 12,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildInputField(
    ThemeData theme, {
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Container(
      decoration: _fieldDecoration(theme),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: theme.textTheme.bodyLarge,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintText: hint,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.35),
          ),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffix,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
      ),
    );
  }

  BoxDecoration _fieldDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.dividerColor.withOpacity(0.7)),
    );
  }

  void _showSplitPicker(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How was this split?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ..._splitOptions.map(
                (option) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option),
                  subtitle: Text(
                    _splitSubtitle(option),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  trailing: _selectedSplit == option
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedSplit = option);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _splitSubtitle(String option) {
    switch (option) {
      case 'Split Equally':
        return 'Each person pays half';
      case 'You Paid':
        return 'You paid everything, friend owes you full amount';
      case 'They Paid':
        return 'They paid everything, you owe them full amount';
      case 'Custom':
        return 'Split equally for now — custom amounts coming soon';
      default:
        return '';
    }
  }
}
