import 'package:flutter/material.dart';

import '../../../core/models/profile_model.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/kwan_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController countryController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.profile.fullName);

    phoneController =
        TextEditingController(text: widget.profile.phone);

    countryController =
        TextEditingController(text: widget.profile.country);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    countryController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {

    setState(() {
      isSaving = true;
    });

    try {

      await ProfileService().updateProfile(
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        country: countryController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(

          padding: AppSpacing.pagePadding,

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              Text(
                "Update Your Profile",
                style: AppTextStyles.headline,
              ),

              const SizedBox(height: 10),

              const Text(
                "Keep your personal information up to date.",
                style: AppTextStyles.body,
              ),

              const SizedBox(height: 40),

              KwanTextField(
                label: "Full Name",
                icon: Icons.person_outline,
                controller: nameController,
              ),

              const SizedBox(height: 20),

              KwanTextField(
                label: "Phone Number",
                icon: Icons.phone_outlined,
                controller: phoneController,
              ),

              const SizedBox(height: 20),

              KwanTextField(
                label: "Country",
                icon: Icons.public,
                controller: countryController,
              ),

              const SizedBox(height: 50),

              isSaving

                  ? const Center(
                      child: CircularProgressIndicator(),
                    )

                  : PrimaryButton(
                      text: "Save Changes",
                      onPressed: saveProfile,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
