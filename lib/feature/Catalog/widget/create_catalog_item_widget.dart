import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../Funcation/catalog_function.dart';

class CreateCatalogItemWidget extends StatefulWidget {
  final Catalog cat;
  final SubCatModel sub;
  final SubSubCatModel subsub;

  const CreateCatalogItemWidget(
      this.cat,
      this.sub,
      this.subsub, {
        Key? key,
      }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CreateCatalogItemWidget();
  }
}

class _CreateCatalogItemWidget extends State<CreateCatalogItemWidget> {
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

    const Color mainColor = Color(0xFF07933E);
    const Color accentColor = Color(0xFFCE232B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ModalProgressHUD(
        inAsyncCall: _show,
        child: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Text(
                  "إضافة عنصر جديد".tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subsub.subsub,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    showImageDialog(context, "برجاء اختيار مصدر الصورة");
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.18,
                        backgroundColor: Colors.grey[200],
                        child: _image != null
                            ? ClipOval(
                          child: Image.file(
                            _image!,
                            width: screenWidth * 0.36,
                            height: screenWidth * 0.36,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.image,
                          size: screenWidth * 0.16,
                          color: Colors.grey[400],
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: mainColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                _buildLabel("الاسم".tr, screenWidth),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _name,
                  hint: "اسم العنصر".tr,
                  icon: Icons.text_fields,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),

                SizedBox(height: screenHeight * 0.02),

                _buildLabel("الوصف".tr, screenWidth),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _des,
                  hint: "وصف العنصر".tr,
                  icon: Icons.description_outlined,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  maxLines: 3,
                ),

                SizedBox(height: screenHeight * 0.02),

                _buildLabel("السعر".tr, screenWidth),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _price,
                  hint: "سعر العنصر".tr,
                  icon: Icons.monetization_on_outlined,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: screenHeight * 0.03),

                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.065,
                  child: ElevatedButton.icon(
                    onPressed: _onAddPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                    label: Text(
                      'إضافة العنصر'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,

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
        ),
      ),
    );
  }


  Widget _buildLabel(String text, double screenWidth) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: ManagerFontFamily.fontFamily,

          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required double screenHeight,
    required double screenWidth,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      style: TextStyle(
        fontFamily: ManagerFontFamily.fontFamily,
        fontSize: 14
      ),
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF07933E),
            width: 1.4,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.016,
          horizontal: screenWidth * 0.04,
        ),
      ),
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

    CreateCatalogItems(
      context,
      widget.cat,
      widget.sub,
      widget.subsub,
      _name,
      _des,
      _price,
      _image!,
    );
  }

  void _pickImageGallery() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

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

  void _pickImageCamera() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.camera, imageQuality: 75);

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
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                const Icon(
                  Icons.image_outlined,
                  color: Color(0xFFCE232B),
                ),
                const SizedBox(width: 8),
                Text(
                  'اختيار صورة'.tr,
                  style:  TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    color: Color(0xFFCE232B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              error,
              style:  TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  color: Colors.black87),
            ),
            actionsPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            actions: <Widget>[
              TextButton.icon(
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF07933E),
                ),
                label: Text(
                  'كاميرا'.tr,
                  style:  TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    color: Color(0xFF07933E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Get.back();
                  _pickImageCamera();
                },
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF07933E),
                ),
                label: Text(
                  'معرض الصور'.tr,
                  style:  TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    color: Color(0xFF07933E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Get.back();
                  _pickImageGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
