import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Utils/xfile_image_provider.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../Funcation/catalog_function.dart';

class EditSubSubWidget extends StatefulWidget {
  final Catalog cat;
  final SubCatModel sub;
  final SubSubCatModel subsub;

  const EditSubSubWidget({
    Key? key,
    required this.cat,
    required this.sub,
    required this.subsub,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditSubSubWidgetState();
  }
}

class _EditSubSubWidgetState extends State<EditSubSubWidget> {
  final TextEditingController _name = TextEditingController();
  XFile? _image;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _name.text = widget.subsub.subsub;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

    return ModalProgressHUD(
      inAsyncCall: _show,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                Text(
                  'Edit Sub-Sub Category'.tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                GestureDetector(
                  onTap: () {
                    showImageDialog(context, "برجاء اختيار مصدر الصورة");
                  },
                  child: CircleAvatar(
                    radius: screenWidth * 0.15,
                    backgroundColor: Colors.black,
                    child: _image != null
                        ? ClipOval(
                      child: Image(
                        image: imageProviderForXFile(_image!),
                        width: screenWidth * 0.3,
                        height: screenWidth * 0.3,
                        fit: BoxFit.cover,
                      ),
                    )
                        : ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.subsub.pic,
                        width: screenWidth * 0.3,
                        height: screenWidth * 0.3,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Name'.tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,

                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.008),
                TextFormField(
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                   fontSize:  14
                  ),
                  controller: _name,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.text_fields),
                    hintText: 'Name OF Item'.tr,
                    filled: true,
                    hintStyle: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontSize: 14
                    ),
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.05,
                    ),
                  ),
                  keyboardType: TextInputType.name,
                ),

                SizedBox(height: screenHeight * 0.04),

                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.07,
                  child: ElevatedButton(
                    onPressed: _onUpdatePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCE232B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Update'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,

                        fontSize: screenWidth * 0.05,
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

  void _onUpdatePressed() {
    if (_name.text.trim().isEmpty) {
      showErrorDialog(context, "Please Add Name".tr);
      return;
    }

    setState(() {
      _show = true;
    });

    if (_image != null) {
      EditSubSubImage(
        context,
        widget.cat,
        widget.sub,
        widget.subsub,
        _name,
        _image!,
      );
    } else {
      EditSubSub(
        context,
        widget.cat,
        widget.sub,
        widget.subsub,
        _name,
      );
    }
  }

  void _pickImage(bool fromCamera) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          fromCamera
              ? 'تم التقاط الصورة بالكاميرا'.tr
              : 'تم اختيار الصورة من المعرض'.tr,
        ),
        backgroundColor: const Color(0xFF07933E),
      ),
    );
  }

  void showImageDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'تنبيه'.tr,
            style:  TextStyle(
              fontFamily: ManagerFontFamily.fontFamily,

              color: Color(0xFFCE232B),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            error,
            style: const TextStyle(color: Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'كاميرا'.tr,
                style:  TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  color: Color(0xFF07933E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Get.back();
                _pickImage(true);
              },
            ),
            TextButton(
              child: Text(
                'معرض الصور'.tr,
                style:  TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  color: Color(0xFF07933E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Get.back();
                _pickImage(false);
              },
            ),
          ],
        );
      },
    );
  }
}
