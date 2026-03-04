import '../models/onboarding_model.dart';
import 'dart:async';

class OnboardingService {
  // Simulating an API call to fetch onboarding payload from a remote server
  Future<List<OnboardingModel>> fetchOnboardingData() async {
    // Artificial delay to mimic a network request
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Future expansion: This static list gets replaced with proper
    // http client fetching and parsing json into the models.
    final mockResponse = [
      {
        "title": "Effortless Splitting",
        "desc": "Automatically split bills with friends,\nno manual math needed. Track who\nowes whom what.",
        "image": "assets/images/onboarding1.png"
      },
      {
        "title": "Total Control",
        "desc": "Zplit does not collect any personal data.\nAll data remains in your own device.",
        "image": "assets/images/onboarding2.png"
      },
      {
        "title": "Smart Spending Insights",
        "desc": "Get real-time expense reports and group\nspending patterns.",
        "image": "assets/images/onboarding3.png"
      }
    ];

    return mockResponse.map((json) => OnboardingModel.fromJson(json)).toList();
  }
}
