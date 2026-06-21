import 'dart:io';
import 'package:flutter/material.dart';

class AccountSetupCard extends StatelessWidget {
  final TextEditingController displayNameController;
  final TextEditingController usernameController;
  final File? pickedImage;
  final bool isLoading;
  final bool isValid;
  final VoidCallback onPickImage;
  final VoidCallback onContinue;

  const AccountSetupCard({
    super.key,
    required this.displayNameController,
    required this.usernameController,
    required this.pickedImage,
    required this.isLoading,
    required this.isValid,
    required this.onPickImage,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Text pulling typography directly from Theme TextTheme
          RichText(
            text: TextSpan(
              text: 'Welcome to ',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'Zplit',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.primary, // Zplit Brand Green
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Avatar / Image Picker Node
          GestureDetector(
            onTap: onPickImage,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor, width: 1.5),
              ),
              child: pickedImage != null
                  ? ClipOval(
                      child: Image.file(
                        pickedImage!,
                        fit: BoxFit.cover,
                        width: 88,
                        height: 88,
                      ),
                    )
                  : Icon(
                      Icons.camera_alt_rounded,
                      size: 28,
                      color: theme.hintColor,
                    ),
            ),
          ),

          const SizedBox(height: 28),

          // Display Name Input Field
          TextField(
            controller: displayNameController,
            textCapitalization: TextCapitalization.words,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Display Name',
              hintText: 'e.g. Aarav Shah',
              labelStyle: TextStyle(color: theme.hintColor),
              hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.5)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Username Input Field
          TextField(
            controller: usernameController,
            textCapitalization: TextCapitalization.none,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'e.g. aarav_shah',
              prefixText: '@',
              prefixStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              labelStyle: TextStyle(color: theme.hintColor),
              hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.5)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Action Button Section
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isValid && !isLoading ? onContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                disabledBackgroundColor: theme.dividerColor.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Continue',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isValid ? Colors.white : theme.hintColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
