import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../controllers/onboarding_controller.dart';
import '../profile/profile_setup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController();
    _controller.addListener(_onStateChange);
  }

  void _onStateChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Handling future loading states (Mocking API interactions)
    if (_controller.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SafeArea(
            child: Column(
              children: [
                // Top Bar View
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_controller.currentPageIndex < _controller.pages.length - 1)
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
                            );
                          },
                          child: const Text(
                            'skip',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 48), // Padding equivalent to TextButton metrics
                    ],
                  ),
                ),
                
                // PageView injected through the View model logic
                Expanded(
                  child: PageView.builder(
                    controller: _controller.pageController,
                    physics: const NeverScrollableScrollPhysics(), // Prevent horizontal swipe gesture
                    onPageChanged: _controller.onPageChanged,
                    itemCount: _controller.pages.length,
                    itemBuilder: (context, index) {
                      final page = _controller.pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Flawlessly centers content between Nav & Bottom components
                          children: [
                            // Illustration Component
                            SizedBox(
                              width: double.infinity,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final double size = constraints.maxWidth;
                                  final double trimRatio = 0.82; // Set clean trim at precisely 82% of the circle height
                                  return SizedBox(
                                    width: size,
                                    height: size * trimRatio, // Bound perfectly to the flat horizontal clip line
                                    child: Stack(
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Background shape and Image merged inside the same exact Flat ClipPath
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          height: size, // Force exact 1:1 circular boundary 
                                          child: ClipPath(
                                            clipper: _FlatTrimClipper(trimHeightRatio: trimRatio),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  decoration: const BoxDecoration(
                                                    color: AppColors.lightGreenBg,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                // Image perfectly sheared by the same exact boundary
                                                Positioned(
                                                  bottom: size * 0.05, // Pull the graphic down to ensure the visible bottom crosses the 0.82 trim line
                                                  child: SizedBox(
                                                    width: size * 0.95, // Ideal proportional width inside the circle
                                                    child: Image.asset(
                                                      page.imagePath,
                                                      fit: BoxFit.contain,
                                                      alignment: Alignment.bottomCenter,
                                                      errorBuilder: (context, error, stackTrace) =>
                                                          const Center(
                                                        child: Text('Image Error', style: TextStyle(color: Colors.grey)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Bring typography spacing uniformly flush with new baseline sizing
                            const SizedBox(height: 16),
                            // Typography configured to Strict SF Pro mapping constraints
                            Text(
                              page.title, 
                              style: const TextStyle(
                                fontSize: 28, 
                                fontWeight: FontWeight.w600, // Explicit Semibold
                                letterSpacing: -0.5,
                                color: AppColors.primaryGreen,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                page.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1C1C1E), // Soft dark for optimal contrast
                                  height: 1.45,
                                  fontWeight: FontWeight.w400, // Explicit Regular
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Elevated spacer trick to shift the complete focal point of the Column upwards
                            const SizedBox(height: 60),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom Interactions handled by Controller
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Fixed width container for back arrow to preserve true centering of dots
                      SizedBox(
                        width: 60,
                        child: _controller.currentPageIndex > 0
                            ? IconButton(
                                icon: const Icon(Icons.arrow_back, color: Color(0xFF9E9E9E), size: 28),
                                onPressed: _controller.previousPage,
                              )
                            : null,
                      ),
                          
                      // Dot View Generator aligned safely
                      Row(
                        mainAxisSize: MainAxisSize.min, // Prevents expanding and breaking center boundary
                        children: List.generate(
                          _controller.pages.length,
                          (index) => _buildDot(index, _controller.currentPageIndex),
                        ),
                      ),
                      
                      // Forward Navigation Action
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: FloatingActionButton(
                          onPressed: () {
                            _controller.nextPage(() {
                              debugPrint("Done onboarding — navigating to Profile Setup...");
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
                              );
                            });
                          },
                          backgroundColor: AppColors.primaryGreen,
                          elevation: 1, // Almost flat to match native iOS paradigm
                          shape: const CircleBorder(),
                          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Purely UI View builder component decoupled from state
  Widget _buildDot(int index, int currentIndex) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 9, // Slightly smaller scaling for visual hierarchy
      width: 9,
      decoration: BoxDecoration(
        color: currentIndex == index ? AppColors.primaryGreen : const Color(0xFFE5E7EB), // Custom light muted grey
        shape: BoxShape.circle,
      ),
    );
  }
}

class _FlatTrimClipper extends CustomClipper<Path> {
  final double trimHeightRatio;

  _FlatTrimClipper({required this.trimHeightRatio});

  @override
  Path getClip(Size size) {
    final path = Path();
    // Flat horizontal line at exactly the trim ratio
    path.lineTo(0, size.height * trimHeightRatio); 
    path.lineTo(size.width, size.height * trimHeightRatio);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _FlatTrimClipper oldClipper) {
    return oldClipper.trimHeightRatio != trimHeightRatio;
  }
}
