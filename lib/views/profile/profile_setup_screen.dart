import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zplit/controllers/profile_setup_controller.dart';
import 'package:zplit/core/constants/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zplit/views/profile/add_friends_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final ProfileSetupController _controller = ProfileSetupController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF2C2C2E), // Apple Dark Mode gray
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280), // Mobile dimensions 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDialogOption(
                  context,
                  title: 'Photo Library',
                  icon: Icons.photo_library_outlined,
                  onTap: () {
                    Navigator.of(context).pop();
                    _controller.pickImage(ImageSource.gallery);
                  },
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFF3A3A3C)),
                _buildDialogOption(
                  context,
                  title: 'Take Photo',
                  icon: Icons.camera_alt_outlined,
                  onTap: () {
                    Navigator.of(context).pop();
                    _controller.pickImage(ImageSource.camera);
                  },
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFF3A3A3C)),
                _buildDialogOption(
                  context,
                  title: 'Choose File',
                  icon: Icons.folder_open_outlined,
                  onTap: () {
                    Navigator.of(context).pop();
                    _controller.pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogOption(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16), // So splash matches dialog corners
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2, // Tighter for iOS feel
              ),
            ),
            Icon(icon, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            constraints: const BoxConstraints(maxWidth: 430), // Standard mobile-first dimensions boundary
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 28, // Matches screenshot proportion
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: AppColors.textDark,
                            ),
                            children: [
                              TextSpan(text: 'Welcome to '),
                              TextSpan(
                                text: 'Z',
                                style: TextStyle(color: AppColors.primaryGreen),
                              ),
                              TextSpan(text: 'plit'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Avatar Placeholder
                      Center(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showImageSourceDialog(context),
                            customBorder: const CircleBorder(),
                            splashColor: AppColors.primaryGreen.withOpacity(0.2),
                            highlightColor: AppColors.primaryGreen.withOpacity(0.1),
                            child: ValueListenableBuilder<XFile?>(
                              valueListenable: _controller.selectedImage,
                              builder: (context, imageFile, child) {
                                return Ink(
                                  width: 120, // Scaled slightly down to match iPhone reference
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.avatarBgGrey,
                                    shape: BoxShape.circle,
                                    image: imageFile != null
                                        ? DecorationImage(
                                            image: kIsWeb 
                                                ? NetworkImage(imageFile.path) as ImageProvider
                                                : FileImage(File(imageFile.path)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: imageFile == null
                                      ? Center(
                                          child: SvgPicture.asset(
                                            'assets/icons/add_photo.svg',
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.contain,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.primaryGreen,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Display Name Field
                      const Text(
                        'Display Name',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A4A4A), // Slightly muted dark grey to match reference
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller.displayNameController,
                        style: const TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Aradhya',
                          hintStyle: const TextStyle(
                            fontFamily: 'SF Pro',
                            color: AppColors.textGrey,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.inputBgGrey,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Username Field
                      const Text(
                        'Username',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller.usernameController,
                        style: const TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Aradhya21',
                          hintStyle: const TextStyle(
                            fontFamily: 'SF Pro',
                            color: AppColors.textGrey,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.inputBgGrey,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Continue Button
                      ValueListenableBuilder<bool>(
                        valueListenable: _controller.isFormValid,
                        builder: (context, isValid, child) {
                          return SizedBox(
                            height: 52, // Slightly thinner to match native look
                            child: ElevatedButton(
                              onPressed: isValid
                                  ? () async {
                                      // Request OS native contacts permission
                                      await Permission.contacts.request();
                                      
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const AddFriendsScreen(),
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isValid ? AppColors.primaryGreen : AppColors.buttonDisabled,
                                disabledBackgroundColor: AppColors.buttonDisabled,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                elevation: isValid ? 8 : 0,
                                shadowColor: isValid ? AppColors.primaryGreen.withOpacity(0.4) : Colors.transparent,
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
