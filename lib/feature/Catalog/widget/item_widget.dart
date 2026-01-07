import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Utils/xfile_image_provider.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/catalog_item_model.dart';
import '../Funcation/catalog_function.dart';

class ItemWidget extends StatefulWidget {
  final CatalogItemModel itemModel;
  final String path;

  const ItemWidget(
      this.itemModel,
      this.path, {
        Key? key,
      }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ItemWidgetState();
  }
}

class _ItemWidgetState extends State<ItemWidget> {
  final TextEditingController _name  = TextEditingController();
  final TextEditingController _des   = TextEditingController();
  final TextEditingController _price = TextEditingController();

  XFile? _image;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _name.text  = widget.itemModel.name;
    _des.text   = widget.itemModel.des;
    _price.text = widget.itemModel.price;
  }

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
    final screenWidth  = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ModalProgressHUD(
        inAsyncCall: _show,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: screenHeight * 0.19,
                width: double.infinity,
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
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: screenHeight * 0.08,
                      left: screenWidth * 0.08,
                      child: Text(
                        'Edit Item'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,

                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.01),

              GestureDetector(
                onTap: () => _showImageDialog(
                  context,
                  "برجاء اختيار مصدر الصورة",
                ),
                child: CircleAvatar(
                  radius: screenWidth * 0.15,
                  backgroundColor: Colors.white,
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
                      imageUrl: widget.itemModel.path,
                      width: screenWidth * 0.3,
                      height: screenWidth * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,

                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: 14
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
                          borderRadius:
                          BorderRadius.circular(screenWidth * 0.03),
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

                    Text(
                      'Description'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,

                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: 14
                      ),
                      controller: _des,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.text_fields),
                        hintText: 'Description OF Item'.tr,
                        filled: true,
                        hintStyle: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 14
                        ),
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(screenWidth * 0.03),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.05,
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      minLines: 3,
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    Text(
                      'Price'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,

                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: 14
                      ),
                      controller: _price,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.monetization_on),
                        hintText: 'Price OF Item'.tr,
                        filled: true,
                        hintStyle: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 14
                        ),
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(screenWidth * 0.03),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.05,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.07,
                        child: ElevatedButton(
                          onPressed: _onSavePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCE232B),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Save Edit Item'.tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,

                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.07,
                        child: ElevatedButton(
                          onPressed: _onDeletePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCE232B),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Delete Item'.tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,

                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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


  void _onSavePressed() {
    setState(() {
      _show = true;
    });

    if (_image != null) {
      EditItem2(
        context,
        _name,
        _des,
        _price,
        widget.itemModel.doc,
        widget.path,
        _image!,
      );
    } else {
      EditItem(
        context,
        _name,
        _des,
        _price,
        widget.itemModel.doc,
        widget.path,
      );
    }
  }

  void _onDeletePressed() {
    setState(() {
      _show = true;
    });

    DeleteItem(
      context,
      widget.path,
      widget.itemModel.doc,
    );
  }


  void _pickFromGallery() async {
    final picker     = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _image = pickedFile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم اختيار الصورة من المعرض'.tr,style: TextStyle(
            fontFamily: ManagerFontFamily.fontFamily,

          ),),
          backgroundColor: const Color(0xFF07933E),
        ),
      );
    }
  }

  void _pickFromCamera() async {
    final picker     = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _image = pickedFile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم التقاط الصورة بالكاميرا'.tr,style: TextStyle(
            fontFamily: ManagerFontFamily.fontFamily,

          ),),
          backgroundColor: const Color(0xFF07933E),
        ),
      );
    }
  }

  void _showImageDialog(BuildContext context, String msg) {
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
            msg,
            style:  TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,

                color: Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
                _pickFromCamera();
              },
              child: Text(
                'كاميرا'.tr,
                style:  TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  color: Color(0xFF07933E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _pickFromGallery();
              },
              child: Text(
                'معرض الصور'.tr,
                style:  TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  color: Color(0xFF07933E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
