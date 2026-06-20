import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';
import '../services/onboarding_service.dart';

class OnboardingController extends ChangeNotifier {
  final OnboardingService _service = OnboardingService();
  final PageController pageController = PageController();
  
  List<OnboardingModel> _pages = [];
  bool _isLoading = true;
  int _currentPageIndex = 0;
  
  List<OnboardingModel> get pages => _pages;
  bool get isLoading => _isLoading;
  int get currentPageIndex => _currentPageIndex;
  
  OnboardingController() {
    _loadData();
  }
  
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Data fetch from the mocked backend service layer
      _pages = await _service.fetchOnboardingData();
    } catch (e) {
      // Future API integrations: Error state handler can go here
      debugPrint("Failed to load onboarding payload: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onPageChanged(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }
  
  // Navigation controllers encapsulating the page logic
  void skipToLast() {
    if (_pages.isNotEmpty) {
      pageController.animateToPage(
        _pages.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void previousPage() {
    if (_currentPageIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void nextPage(VoidCallback onDone) {
    if (_currentPageIndex < _pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Signal UI that controller task flow is finished
      onDone();
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
