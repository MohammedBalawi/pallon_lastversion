import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/item_model.dart';
import '../function/item_action.dart';




class AddItemWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _AddItemWidget();
  }

}


class _AddItemWidget extends State<AddItemWidget>{
  TextEditingController id=TextEditingController();
  TextEditingController name=TextEditingController();
  TextEditingController number=TextEditingController();
  TextEditingController price=TextEditingController();
  TextEditingController priceOfbuy=TextEditingController();
  TextEditingController _des=TextEditingController();
  File? _image;
  bool _showprice=false;
  bool load=false;
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
      body: ModalProgressHUD(
        inAsyncCall:load ,
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
                        'Add New Item'.tr,
                        style: TextStyle(
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
                onTap: (){
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
                  ) :Icon(
                    Icons.storefront_sharp,
                    size: screenWidth * 0.15,
                    color: Colors.grey[300],
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
                    TextFormField(
                      controller: priceOfbuy,
                      obscureText: false,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.monetization_on),
                        hintText: 'Price Buy OF Item'.tr,
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
                        if(id.text!=""){
                          if(name.text!=""){
                            if(price.text!=""){
                              if(priceOfbuy.text!=""){
                                if(number.text!=""){
                                  if(_des.text!=""){
                                    setState(() {
                                      load=true;
                                    });
                                    ItemModel item=ItemModel(
                                        doc: "", id: id.text, name: name.text, count: int.parse(number.text), price: double.parse(price.text),
                                        pic: "", show: _showprice);
                                    item.des=_des.text;
                                    item.pricebuy=double.parse(priceOfbuy.text);
                                    SaveNewItem(item,_image!, context);
                                  }
                                  else{
                                    showErrorDialog(context,"برجاء ادخال الوصف");
                                  }
                                }
                                else{
                                  showErrorDialog(context,"Please Enter Count".tr);
                                }
                              }
                              else{
                                showErrorDialog(context,"Please Enter Price Of Buy".tr);
                              }
                            }
                            else{
                              showErrorDialog(context,"Please Enter Price".tr);
                            }
                          }
                          else{
                            showErrorDialog(context,"Please Enter Name".tr);
                          }
                        }
                        else{
                          showErrorDialog(context,"Please Enter ID".tr);
                        }
                      }
                      else{
                        showErrorDialog(context,"Please Upload Image".tr);
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
                      'Add Item'.tr,
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