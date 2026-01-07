import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../Core/Utils/image_picker_utils.dart';
import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Utils/xfile_image_provider.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../Funcation/catalog_function.dart';

class CreateCatalogWidget extends StatefulWidget {
  const CreateCatalogWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CreateCatalogWidget();
  }
}

class _CreateCatalogWidget extends State<CreateCatalogWidget> {
  final TextEditingController _name = TextEditingController();
  XFile? _image;
  bool _show = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

    const Color mainColor   = Color(0xFF07933E);
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
                  "إضافة تصنيف جديد".tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "قم بإضافة قسم جديد إلى الكتالوج".tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    showImageDialog(context, "برجاء اختيار مصدر الصورة".tr);
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.18,
                        backgroundColor: Colors.grey[200],
                        child: _image != null
                            ? ClipOval(
                          child: Image(
                            image: imageProviderForXFile(_image!),
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

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'اسم التصنيف'.tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,

                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(

                  style: TextStyle(fontSize: 14, fontFamily: ManagerFontFamily.fontFamily,),
                  controller: _name,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.text_fields),
                    hintText: 'مثال: حلويات، مشروبات، سندويشات...'.tr,
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
                        color: mainColor,
                        width: 1.4,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.016,
                      horizontal: screenWidth * 0.04,
                    ),
                  ),
                  keyboardType: TextInputType.name,
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
                      'إضافة التصنيف'.tr,
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


  void _onAddPressed() {
    final name = _name.text.trim();

    if (name.isEmpty) {
      showErrorDialog(context, "Please Enter Name".tr);
      return;
    }
    if (_image == null) {
      showErrorDialog(context, "Please insert image".tr);
      return;
    }

    setState(() {
      _show = true;
    });

    createCategory(_name, _image!, context);
  }

  void _pickImageGallery() async {
    final pickedFile = await pickImageWithPermission(
      context,
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
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
    final pickedFile = await pickImageWithPermission(
      context,
      source: ImageSource.camera,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
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

              style:  TextStyle(color: Colors.black87,fontFamily: ManagerFontFamily.fontFamily,),
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
