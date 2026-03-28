class OnboardingModel {
  final String title;
  final String description;
  final String imagePath;
  
  OnboardingModel({
    required this.title,
    required this.description,
    required this.imagePath,
  });
  
  // Future API payload mapping example (deserializer)
  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      title: json['title'] as String,
      description: json['desc'] as String,
      imagePath: json['image'] as String,
    );
  }

  // Future API serializer example
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'desc': description,
      'image': imagePath,
    };
  }
}
