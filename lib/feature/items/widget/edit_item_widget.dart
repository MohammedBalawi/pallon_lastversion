import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/item_model.dart';
import '../function/item_action.dart';


class EditItemWidget extends StatefulWidget{
  ItemModel itemModel;
  EditItemWidget(this.itemModel);
  @override
  State<StatefulWidget> createState() {
    return _EditItemWidget();
  }

}


class _EditItemWidget extends State<EditItemWidget>{
  TextEditingController id=TextEditingController();
  TextEditingController name=TextEditingController();
  TextEditingController number=TextEditingController();
  TextEditingController price=TextEditingController();
  TextEditingController _des=TextEditingController();
  int lastcount=0;
  String doc="";
  File? _image;
  bool _showprice=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _showprice=widget.itemModel.show;
    doc=widget.itemModel.doc;
    _des=TextEditingController(text: widget.itemModel.des.toString());
    price=TextEditingController(
      text: widget.itemModel.price.toString()
    );
    lastcount=widget.itemModel.count;
    id=TextEditingController(
      text: widget.itemModel.id
    );
    name=TextEditingController(
      text: widget.itemModel.name
    );
    number=TextEditingController(
      text: widget.itemModel.count.toString()
    );
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
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
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            GestureDetector(
              onTap:  (){
                showImageDialog(context,"برجاء اختيار مصدر الصورة");
              },
              child: CircleAvatar(
                radius: screenWidth * 0.15,
                backgroundColor: Colors.white,
                child: _image != null
                    ? ClipOval(
                  child: Image.file(
                    _image!,
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.3,
                    fit: BoxFit.cover,
                  ),
                ) :ClipOval(
                  child: CachedNetworkImage(
                      imageUrl: widget.itemModel.pic,
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.3,
                    fit: BoxFit.cover,
                  ),
                )
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID'.tr,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextFormField(
                    controller: id,
                    obscureText: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.qr_code),
                      hintText: 'ID OF Item'.tr,
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.05),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    'Name'.tr,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextFormField(
                    controller: name,
                    obscureText: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.text_fields),
                      hintText: 'Name OF Item'.tr,
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.05),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    'Price'.tr,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextFormField(
                    controller: price,
                    obscureText: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.monetization_on),
                      hintText: 'Price OF Item'.tr,
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.05),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    'Count'.tr,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextFormField(
                    controller: number,
                    obscureText: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.numbers),
                      hintText: 'Count OF Item'.tr,
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.05),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description'.tr,
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _des,
                          obscureText: false,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.text_fields),
                            hintText: 'Description OF Item'.tr,
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                                horizontal: screenWidth * 0.05),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.06),
                  Row(
                    children: [
                      Text(
                        'Show Price'.tr,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Checkbox(value: _showprice, onChanged: (value){
                        setState(() {
                          _showprice=!_showprice;
                        });
                      })
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                width: double.infinity,
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  onPressed: () {
                    if(_image!=null){
                      widget.itemModel=ItemModel(
                          doc: doc, id: id.text, name: name.text, count: int.parse(number.text), price: double.parse(price.text),
                          pic: "", show: _showprice);
                      widget.itemModel.des=_des.text;
                      EditItemAction(widget.itemModel,_image!, context,lastcount);
                    }
                    else{
                      String pic =widget.itemModel.pic;
                      widget.itemModel=ItemModel(
                          doc: doc, id: id.text, name: name.text, count: int.parse(number.text), price: double.parse(price.text),
                          pic: pic, show: _showprice);
                      widget.itemModel.des=_des.text;
                      EditItemAction2(widget.itemModel, context,lastcount);
                    }

                  },
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
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
                  onPressed: () {
                    RemoveItem(widget.itemModel, context);
                  },
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
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text('Image selection simulated!'.tr),
        backgroundColor: Color(0xFF07933E),
      ),
    );
  }
  void showImageDialog(BuildContext context , String Error){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            title:  Text(
              'تنبيه'.tr,
              style: TextStyle(
                color: Color(0xFFCE232B),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              Error,
              style: const TextStyle(color: Colors.black87),
            ),
            actions: <Widget>[
              TextButton(
                child:  Text(
                  'كاميرا'.tr,
                  style: TextStyle(
                    color: Color(0xFF07933E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Get.back();
                  _pickImage2();
                },
              ),
              TextButton(
                child:  Text(
                  'معرض الصور'.tr,
                  style: TextStyle(
                    color: Color(0xFF07933E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Get.back();
                  _pickImage();

                },
              ),
            ],
          );
        }
    );
  }
  void _pickImage2() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image selection simulated!'.tr),
        backgroundColor: Color(0xFF07933E),
      ),
    );
  }

}