import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupController {
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
  final ValueNotifier<XFile?> selectedImage = ValueNotifier<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

  ProfileSetupController() {
    displayNameController.addListener(_validateForm);
    usernameController.addListener(_validateForm);
  }

  void _validateForm() {
    isFormValid.value = displayNameController.text.trim().isNotEmpty && 
                        usernameController.text.trim().isNotEmpty;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        selectedImage.value = image;
      }
    } catch (e) {
      debugPrint("Failed to pick image: $e");
    }
  }

  void dispose() {
    displayNameController.removeListener(_validateForm);
    usernameController.removeListener(_validateForm);
    displayNameController.dispose();
    usernameController.dispose();
    isFormValid.dispose();
    selectedImage.dispose();
  }
}
