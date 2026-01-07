import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../Core/Utils/image_picker_utils.dart';
import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Utils/xfile_image_provider.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../functions/banner_function.dart';

class AddBannerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddBannerWidget();
  }
}

class _AddBannerWidget extends State<AddBannerWidget> {
  final TextEditingController _link = TextEditingController();

  XFile? _image;
  XFile? _image2;

  String _typeaction = 'same';
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ModalProgressHUD(
      inAsyncCall: _show,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Add New Banner'.tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF07933E),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Banner Image'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF07933E),
                              Color(0xFF007530),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: screenWidth * 0.16,
                          backgroundColor: Colors.white,
                          child: _image != null
                              ? ClipOval(
                            child: Image(
                              image: imageProviderForXFile(_image!),
                              width: screenWidth * 0.32,
                              height: screenWidth * 0.32,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: screenWidth * 0.14,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to upload'.tr,
                                style: TextStyle(
                                  fontFamily:
                                  ManagerFontFamily.fontFamily,
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 6),
                        child: Text(
                          "Action".tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: _typeaction,
                      items: <String>['same', 'image', 'link']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _typeaction = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF07933E),
                            width: 1.2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select action'.tr;
                        }
                        return null;
                      },
                    ),


                    const SizedBox(height: 24),

                    if (_typeaction == "image") ...[
                      Text(
                        'Action Image'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickImage2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: screenWidth * 0.14,
                            backgroundColor: Colors.grey[100],
                            child: _image2 != null
                                ? ClipOval(
                              child: Image(
                                image: imageProviderForXFile(_image2!),
                                width: screenWidth * 0.28,
                                height: screenWidth * 0.28,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: screenWidth * 0.11,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to upload'.tr,
                                  style: TextStyle(
                                    fontFamily:
                                    ManagerFontFamily.fontFamily,
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else if (_typeaction == "link") ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding:
                          const EdgeInsets.only(left: 4.0, bottom: 6, top: 4),
                          child: Text(
                            'Link'.tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF444444),
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _link,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.link),
                          hintText: 'Url link'.tr,
                          hintStyle: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: 13.5,
                            color: Colors.grey[500],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF07933E),
                              width: 1.2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.016,
                            horizontal: screenWidth * 0.04,
                          ),
                        ),
                        keyboardType: TextInputType.url,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 14,
                        ),
                      ),
                    ],

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.065,
                      child: ElevatedButton(
                        onPressed: _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07933E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.06,
                            ),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'Add New Banner'.tr,
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
            ],
          ),
        ),
      ),
    );
  }


  void _onSubmit() {
    if (_image == null) {
      showErrorDialog(context, "Please Upload Image".tr);
      return;
    }

    setState(() {
      _show = true;
    });

    if (_typeaction == "same") {
      AddBannerSame(context, _image!);
    } else if (_typeaction == "image") {
      if (_image2 == null) {
        setState(() => _show = false);
        showErrorDialog(context, "Please Upload Secound Image".tr);
        return;
      }
      AddBannerImage(context, _image!, _image2!);
    } else {
      if (_link.text.isEmpty) {
        setState(() => _show = false);
        showErrorDialog(context, "Please Enter Url".tr);
        return;
      }
      AddBannerLink(context, _image!, _link);
    }
  }

  void _pickImage() async {
    final pickedFile = await pickImageWithPermission(
      context,
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image selection simulated!'.tr),
        backgroundColor: const Color(0xFF07933E),
      ),
    );
  }

  void _pickImage2() async {
    final pickedFile = await pickImageWithPermission(
      context,
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _image2 = pickedFile;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image selection simulated!'.tr),
        backgroundColor: const Color(0xFF07933E),
      ),
    );
  }
}
