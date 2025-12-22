import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';
import '../../../models/user_model.dart';
import '../function/profile_function.dart';
import 'custom_text_field.dart';

class UpdateProfileWidget extends StatefulWidget {
  final UserModel userModel;

  UpdateProfileWidget(this.userModel, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UpdateProfileWidget();
  }
}

class _UpdateProfileWidget extends State<UpdateProfileWidget> {
  final TextEditingController _nameController  = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();

    if (widget.userModel.name == "" || widget.userModel.name == "name") {
      _nameController.text = 'No Name';
    } else {
      _nameController.text = widget.userModel.name;
    }

    _phoneController.text = widget.userModel.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


  Future<void> _pickImageFromGallery() async {
    final picker     = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image selected successfully'.tr),
          backgroundColor: const Color(0xFF07933E),
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker     = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image selected successfully'.tr),
          backgroundColor: const Color(0xFF07933E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: screenHeight * 0.12,
                  bottom: screenHeight * 0.06,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF07933E),
                      Color(0xFF007530),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [

                        Expanded(
                          child: Text(
                            'Edit Profile'.tr,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Update your personal information and profile picture."
                          .tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.032,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              Transform.translate(
                offset: Offset(0, -screenHeight * 0.06),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                  ),
                  child: Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showImageDialog(
                                context,
                                "Please choose image source".tr,
                              );
                            },
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: screenWidth * 0.16,
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    child: _buildProfileImage(screenWidth),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF07933E),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        Colors.black.withOpacity(0.20),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          Text(
                            _nameController.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontSize: screenWidth * 0.052,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF222222),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.004),
                          Text(
                            widget.userModel.type.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontSize: screenWidth * 0.038,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Transform.translate(
                offset: Offset(0, -screenHeight * 0.05),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                  ),
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildTextField(
                            context,
                            label: 'Full Name'.tr,
                            icon: Icons.person_outline,
                            controller: _nameController,
                            show: false,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          buildTextField(
                            context,
                            label: 'Phone Number'.tr,
                            icon: Icons.phone_outlined,
                            controller: _phoneController,
                            show: false,
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.065,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_image == null) {
                                  updateProfile2(
                                    _nameController.text,
                                    _phoneController.text,
                                    context,
                                  );
                                } else {
                                  updateProfile(
                                    _nameController.text,
                                    _phoneController.text,
                                    _image!,
                                    context,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFCE232B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.05,
                                  ),
                                ),
                                elevation: 6,
                              ),
                              child: Text(
                                'Update Profile'.tr,
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,
                                  fontSize: screenWidth * 0.047,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProfileImage(double screenWidth) {
    if (_image != null) {
      return Image.file(
        _image!,
        width: screenWidth * 0.32,
        height: screenWidth * 0.32,
        fit: BoxFit.cover,
      );
    }

    if (widget.userModel.pic.isNotEmpty &&
        widget.userModel.pic != "pic") {
      return CachedNetworkImage(
        imageUrl: widget.userModel.pic,
        width: screenWidth * 0.32,
        height: screenWidth * 0.32,
        fit: BoxFit.cover,
      );
    }

    return Icon(
      Icons.person,
      size: screenWidth * 0.18,
      color: Colors.grey[300],
    );
  }


  void showImageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: Colors.white,
          titlePadding:
          const EdgeInsets.only(top: 16, left: 20, right: 20),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actionsPadding:
          const EdgeInsets.only(bottom: 10, right: 10, left: 10),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFCE232B).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_camera_back_rounded,
                  color: Color(0xFFCE232B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'تنبيه'.tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    color: const Color(0xFFCE232B),
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontFamily: ManagerFontFamily.fontFamily,
              color: const Color(0xFF333333),
              fontSize: screenWidth * 0.037,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'كاميرا'.tr,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  color: const Color(0xFF07933E),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Get.back();
                _pickImageFromCamera();
              },
            ),
            TextButton(
              child: Text(
                'معرض الصور'.tr,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  color: const Color(0xFF07933E),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Get.back();
                _pickImageFromGallery();
              },
            ),
          ],
        );
      },
    );
  }
}
