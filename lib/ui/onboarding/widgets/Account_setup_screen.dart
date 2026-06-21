import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zplit/routing/App_router.dart';

import 'package:zplit/ui/onboarding/widgets/account_card.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_event.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';

class AccountSetupScreen extends StatefulWidget {
  const AccountSetupScreen({super.key});

  @override
  State<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends State<AccountSetupScreen> {
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  File? _pickedImage;
  bool _isPickingImage = false;

  bool get _isValid =>
      _displayNameController.text.trim().isNotEmpty &&
      _usernameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _displayNameController.addListener(_onFieldsChanged);
    _usernameController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() => setState(() {});

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  void _onContinue() async {
    if (!_isValid) return;
    final address = await const FlutterSecureStorage().read(key: 'evm_address');
    if (address == null) return;

    context.read<UserBloc>().add(
      UpsertUser(
        publicKey: address, // ← use real EVM address
        displayName: _displayNameController.text.trim(),
        profilePicture: _pickedImage?.path,
        defaultCurrency: 'INR',
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.removeListener(_onFieldsChanged);
    _usernameController.removeListener(_onFieldsChanged);
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoaded && state.users.isNotEmpty) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
        if (state is UserError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  return AccountSetupCard(
                    displayNameController: _displayNameController,
                    usernameController: _usernameController,
                    pickedImage: _pickedImage,
                    isLoading: state is UserLoading,
                    isValid: _isValid,
                    onPickImage: _pickImage,
                    onContinue: _onContinue,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
