import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String body;
  final String imagePath;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.body,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // PNG Illustration Container
          Expanded(
            flex: 5,
            child: Center(
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title pulling directly from theme's headline/title styles
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary, // Green text matching Figma
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Body text pulling natively from theme text styles
          Expanded(
            flex: 2,
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                // Automatically uses the theme's default light/dark body color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
