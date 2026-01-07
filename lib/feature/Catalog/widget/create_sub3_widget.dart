import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Utils/xfile_image_provider.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../Funcation/catalog_function.dart';

class CreateSub3Widget extends StatefulWidget {
  final Catalog catalog;
  final SubCatModel sub;
  final SubSubCatModel subsub;

  const CreateSub3Widget(
      this.catalog,
      this.sub,
      this.subsub, {
        Key? key,
      }) : super(key: key);

  @override
  State<CreateSub3Widget> createState() => _CreateSub3WidgetState();
}

class _CreateSub3WidgetState extends State<CreateSub3Widget> {
  final TextEditingController _name = TextEditingController();
  XFile? _image;
  bool _loading = false;

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
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 60,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            Text(
              'إضافة مستوى ثالث جديد'.tr,
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,

                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'قم بإضافة تصنيف فرعي في المستوى الثالث ضمن هذا القسم'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,

                fontSize: screenWidth * 0.038,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                _showImageDialog(context, "برجاء اختيار مصدر الصورة".tr);
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

            SizedBox(height: screenHeight * 0.035),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'اسم المستوى الثالث'.tr,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,
                fontSize: 14
              ),
              controller: _name,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.text_fields),
                hintText: 'مثال: نكهات، أحجام، أنواع إضافية...'.tr,
                filled: true,
                hintStyle: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  fontSize: 14
                ),
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
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(
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

            SizedBox(height: screenHeight * 0.035),

            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.065,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _onSavePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 4,
                ),
                icon: _loading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  _loading ? 'جارٍ الحفظ...'.tr : 'حفظ'.tr,
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
    );
  }


  Future<void> _onSavePressed() async {
    if (_name.text.trim().isEmpty) {
      showErrorDialog(context, "Please Add Name".tr);
      return;
    }
    if (_image == null) {
      showErrorDialog(context, "Please Insert Image".tr);
      return;
    }

    setState(() => _loading = true);

    await CreateSub3Catalog(
      context,
      widget.catalog,
      widget.sub,
      widget.subsub,
      _image!,
      _name,
    );

    if (mounted) {
      setState(() => _loading = false);
    }
  }


  void _showImageDialog(BuildContext context, String error) {
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
              style: const TextStyle(color: Colors.black87),
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
                  _pickImage(ImageSource.camera);
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
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'تم التقاط الصورة بالكاميرا'.tr
                : 'تم اختيار الصورة من المعرض'.tr,
          ),
          backgroundColor: const Color(0xFF07933E),
        ),
      );
    }
  }
}
