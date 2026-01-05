import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../Core/Utils/image_picker_utils.dart';
import '../../../models/banner_model.dart';
import '../functions/banner_function.dart';

class EditBannerWidget extends StatefulWidget {
  final BannerModel _bannerModel;

  EditBannerWidget(this._bannerModel);

  @override
  State<StatefulWidget> createState() {
    return _EditBannerWidget();
  }
}

class _EditBannerWidget extends State<EditBannerWidget> {
  String _typeaction = "";
  bool _show = false;
  File? _image;
  File? _image2;
  TextEditingController _link = TextEditingController();

  @override
  void initState() {
    super.initState();
    _typeaction = widget._bannerModel.typeaction;
    if (_typeaction == "link") {
      _link = TextEditingController(text: widget._bannerModel.action);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: ModalProgressHUD(
        inAsyncCall: _show,
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: screenWidth * 0.06,
                  right: screenWidth * 0.06,
                  top: screenHeight * 0.12,
                  bottom: screenHeight * 0.03,
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
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Banner'.tr,
                        style: TextStyle(
                          fontSize: screenWidth * 0.065,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Update banner image and action'.tr,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 20),
                          child: Column(
                            children: [
                              Text(
                                'Main Banner Image'.tr,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 14),
                              GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: screenWidth * 0.18,
                                  backgroundColor: Colors.white,
                                  child: _image != null
                                      ? ClipOval(
                                    child: Image.file(
                                      _image!,
                                      width: screenWidth * 0.36,
                                      height: screenWidth * 0.36,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: widget._bannerModel.path,
                                      width: screenWidth * 0.36,
                                      height: screenWidth * 0.36,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to change banner image'.tr,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Card(
                        color: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Action".tr,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField2<String>(
                                value: _typeaction,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: "Action".tr,
                                  labelStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),

                                items: ["same", "image", "link"]
                                    .map(
                                      (value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                )
                                    .toList(),

                                onChanged: (value) {
                                  setState(() {
                                    _typeaction = value!;
                                  });
                                },

                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: MediaQuery.of(context).size.width * 0.90,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  offset: const Offset(0, -5),
                                ),

                                menuItemStyleData: const MenuItemStyleData(
                                  height: 48,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),


                              const SizedBox(height: 20),

                              if (_typeaction == "same")
                                Center(
                                  child: Text(
                                    'This banner will open the same image only.'
                                        .tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.038,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                              else if (_typeaction == "image")
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Second Image (Action Target)'.tr,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.042,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: _pickImage2,
                                      child: CircleAvatar(
                                        radius: screenWidth * 0.18,
                                        backgroundColor: Colors.white,
                                        child: _image2 != null
                                            ? ClipOval(
                                          child: Image.file(
                                            _image2!,
                                            width: screenWidth * 0.36,
                                            height: screenWidth * 0.36,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                            widget._bannerModel.action,
                                            width: screenWidth * 0.36,
                                            height: screenWidth * 0.36,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Tap to change action image'.tr,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Link'.tr,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF333333),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    TextFormField(
                                      controller: _link,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.link),
                                        hintText: 'Url link'.tr,
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              screenWidth * 0.035),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              screenWidth * 0.035),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.018,
                                          horizontal: screenWidth * 0.04,
                                        ),
                                      ),
                                      keyboardType: TextInputType.url,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'This link will open when user taps the banner.'
                                          .tr,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: screenHeight * 0.065,
                              child: ElevatedButton(
                                onPressed: _onUpdatePressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF07933E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.05),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  'Update Banner'.tr,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.047,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: screenHeight * 0.065,
                              child: ElevatedButton(
                                onPressed: _onDeletePressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCE232B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.05),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  'Delete Banner'.tr,
                                  style: TextStyle(
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

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _onUpdatePressed() {
    if (_typeaction == "same") {
      if (_image != null) {
        setState(() => _show = true);
        UpdateSame(context, _image!, widget._bannerModel.doc);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload image first'.tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (_typeaction == "image") {
      if (_image != null && _image2 != null) {
        setState(() => _show = true);
        UpdateImage3(context, _image!, _image2!, widget._bannerModel.doc);
      } else if (_image2 != null) {
        setState(() => _show = true);
        UpdateImage(context, _image2!, widget._bannerModel.doc);
      } else {
        setState(() => _show = true);
        UpdateImage2(context, _image!, widget._bannerModel.doc);
      }
    } else {
      if (_image != null && _link.text != "") {
        setState(() => _show = true);
        UpdateLink3(context, widget._bannerModel.doc, _image!, _link);
      } else if (_image != null) {
        setState(() => _show = true);
        UpdateLink2(context, widget._bannerModel.doc, _image!);
      } else {
        setState(() => _show = true);
        UpdateLink(context, widget._bannerModel.doc, _link);
      }
    }
  }

  void _onDeletePressed() {
    setState(() => _show = true);
    DeleteBanner(context, widget._bannerModel);
  }


  void _pickImage() async {
    final pickedFile = await pickImageWithPermission(
      context,
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image selection simulated!'.tr),
          backgroundColor: const Color(0xFF07933E),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Image Selection'.tr),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _pickImage2() async {
    final pickedFile = await pickImageWithPermission(
      context,
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image2 = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image selection simulated!'.tr),
          backgroundColor: const Color(0xFF07933E),
        ),
      );
    }
  }
}
