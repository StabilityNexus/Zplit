import 'package:flutter/material.dart';
import 'package:zplit/routing/App_router.dart';

import 'package:zplit/ui/onboarding/widgets/onboardingpage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    OnboardingPage(
      title: 'Effortless Splitting',
      body:
          'Automatically split bills with friends, no manual math needed. Track who owes whom what.',
      imagePath: 'assets/images/onboarding-1.png',
    ),
    OnboardingPage(
      title: 'Total Control',
      body:
          'Zplit does not collect any personal data. All data remains in your own device.',
      imagePath: 'assets/images/onboarding-2.png',
    ),
    OnboardingPage(
      title: 'Smart Spending Insights',
      body: 'Get real-time expense reports and group spending patterns.',
      imagePath: 'assets/images/onboarding-3.png',
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.accountSetup);
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, AppRoutes.accountSetup);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button alignment
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 24),
                child: TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    'skip',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Onboarding display contents
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _pages[i],
              ),
            ),

            // Fixed bottom control layer using Stack for perfect centering
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Centered tracking page indicator dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // 2. Next circular button pulled exclusively to the right edge
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _onNext,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(
                                0.15,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
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
}
