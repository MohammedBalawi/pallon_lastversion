import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Utils/xfile_image_provider.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../Funcation/catalog_function.dart';

class ItemDetailsCatalogWidget extends StatefulWidget {
  final Catalog cat;
  final SubCatModel sub;
  final SubSubCatModel subsub;
  final CatalogItemModel itemModel;

  const ItemDetailsCatalogWidget(
      this.cat,
      this.sub,
      this.subsub,
      this.itemModel, {
        Key? key,
      }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ItemDetailsCatalogWidgetState();
  }
}

class _ItemDetailsCatalogWidgetState extends State<ItemDetailsCatalogWidget> {
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
                height: screenHeight * 0.22,
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
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.05,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: screenHeight * 0.04,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Edit Item'.tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,

                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              GestureDetector(
                onTap: () {
                  _showImageDialog(context, "برجاء اختيار مصدر الصورة");
                },
                child: CircleAvatar(
                  radius: screenWidth * 0.18,
                  backgroundColor: Colors.white,
                  child: _image != null
                      ? ClipOval(
                    child: Image(
                      image: imageProviderForXFile(_image!),
                      width: screenWidth * 0.36,
                      height: screenWidth * 0.36,
                      fit: BoxFit.cover,
                    ),
                  )
                      : ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: widget.itemModel.path,
                      width: screenWidth * 0.36,
                      height: screenWidth * 0.36,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

                    SizedBox(height: screenHeight * 0.03),

                    // ---------- الوصف ----------
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
                        prefixIcon: const Icon(Icons.notes),
                        hintText: 'Description of Item'.tr,
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

                    SizedBox(height: screenHeight * 0.03),

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
                        hintStyle: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 14
                        ),
                        filled: true,
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

                    SizedBox(height: screenHeight * 0.04),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
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
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.07,
                        child: ElevatedButton(
                          onPressed: _onDeletePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                            ),
                            elevation: 3,
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
    final name  = _name.text.trim();
    final des   = _des.text.trim();
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

    setState(() {
      _show = true;
    });

    if (_image != null) {
      EditItemCataglog2(
        context,
        _name,
        _des,
        _price,
        widget.itemModel.doc,
        widget.cat,
        widget.sub,
        _image!,
        widget.subsub,
      );
    } else {
      EditItemCataglog(
        context,
        _name,
        _des,
        _price,
        widget.itemModel.doc,
        widget.cat,
        widget.sub,
        widget.subsub,
      );
    }
  }

  void _onDeletePressed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'تنبيه'.tr,
          style:  TextStyle(
            fontFamily: ManagerFontFamily.fontFamily,

            color: Color(0xFFCE232B),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا العنصر؟'.tr,
          style: TextStyle(
            fontFamily: ManagerFontFamily.fontFamily,

          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'إلغاء'.tr,
              style:  TextStyle(color: Colors.black87,
                fontFamily: ManagerFontFamily.fontFamily,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'حذف'.tr,
              style:  TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,

                color: Color(0xFFCE232B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _show = true;
    });

    DeleteItemCatalog(
      context,
      widget.itemModel.doc,
      widget.cat,
      widget.sub,
      widget.subsub,
    );
  }

  void _showImageDialog(BuildContext context, String error) {
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
            style:  TextStyle(color: Colors.black87,
              fontFamily: ManagerFontFamily.fontFamily,
            ),
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
                _pickImage(ImageSource.camera);
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
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker     = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Image Selection'.tr),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
