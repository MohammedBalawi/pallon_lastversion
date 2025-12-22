import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../Funcation/catalog_function.dart';

class AddNewItemWidget extends StatefulWidget {
  final String path;
  final String path2;

  const AddNewItemWidget(
      this.path,
      this.path2, {
        Key? key,
      }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddNewItemWidget();
  }
}

class _AddNewItemWidget extends State<AddNewItemWidget> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _des = TextEditingController();
  final TextEditingController _price = TextEditingController();

  File? _image;
  bool _show = false;

  @override
  void dispose() {
    _name.dispose();
    _des.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ModalProgressHUD(
      inAsyncCall: _show,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F8F8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                Text(
                  'Add New Item'.tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please fill item details'.tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    fontSize: screenWidth * 0.032,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showImageDialog(context, "برجاء اختيار مصدر الصورة");
                        },
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[100],
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: _image != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 32,
                                    color: Color(0xFF07933E),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tap to add image'.tr,
                                  style: TextStyle(
                                    fontFamily: ManagerFontFamily.fontFamily,

                                    color: Colors.grey[600],
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      _buildLabeledField(
                        context: context,
                        label: 'Name'.tr,
                        hint: 'Name OF Item'.tr,
                        controller: _name,
                        icon: Icons.title,
                        keyboardType: TextInputType.name,
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      _buildLabeledField(
                        context: context,
                        label: 'Description'.tr,
                        hint: 'Description OF Item'.tr,
                        controller: _des,
                        icon: Icons.description_outlined,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      _buildLabeledField(
                        context: context,
                        label: 'Price'.tr,
                        hint: 'Price OF Item'.tr,
                        controller: _price,
                        icon: Icons.monetization_on_outlined,
                        keyboardType: TextInputType.number,
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.065,
                        child: ElevatedButton.icon(
                          onPressed: _onAddPressed,
                          icon: const Icon(Icons.check_rounded),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 6,
                            backgroundColor: const Color(0xFFCE232B),
                          ),
                          label: Text(
                            'Add New Item'.tr,
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: ManagerFontFamily.fontFamily,

            fontSize: screenWidth * 0.038,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF444444),
          ),
        ),
        SizedBox(height: screenHeight * 0.006),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Colors.grey[600],
            ),
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: ManagerFontFamily.fontFamily,

              color: Colors.grey[400],
              fontSize: screenWidth * 0.035,
            ),
            filled: true,
            fillColor: const Color(0xFFF6F6F6),
            contentPadding: EdgeInsets.symmetric(
              vertical: maxLines == 1 ? screenHeight * 0.018 : 12,
              horizontal: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  void _onAddPressed() {
    final name = _name.text.trim();
    final des = _des.text.trim();
    final price = _price.text.trim();

    if (name.isEmpty) {
      showErrorDialog(context, "Please Enter Name".tr);
      return;
    }
    if (des.isEmpty) {
      showErrorDialog(context, "Please Enter Description".tr);
      return;
    }
    if (price.isEmpty) {
      showErrorDialog(context, "Please Enter Price".tr);
      return;
    }
    if (_image == null) {
      showErrorDialog(context, "Please insert image".tr);
      return;
    }

    setState(() {
      _show = true;
    });

    CreateItemWidgetFunction(
      context,
      widget.path,
      widget.path2,
      _name,
      _des,
      _price,
      _image!,
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم اختيار الصورة من المعرض'.tr),
          backgroundColor: const Color(0xFF07933E),
        ),
      );
    }
  }

  void _pickImage2() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم التقاط الصورة بالكاميرا'.tr),
          backgroundColor: const Color(0xFF07933E),
        ),
      );
    }
  }

  void showImageDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Choose Image Source'.tr,
                  style:  TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    color: Color(0xFFCE232B),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style:  TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          _pickImage2();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFF5F5F5),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.photo_camera_outlined,
                                color: Color(0xFF07933E),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'كاميرا'.tr,
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,

                                  color: const Color(0xFF07933E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          _pickImage();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFF5F5F5),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.photo_library_outlined,
                                color: Color(0xFF07933E),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'معرض الصور'.tr,
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,

                                  color: const Color(0xFF07933E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
