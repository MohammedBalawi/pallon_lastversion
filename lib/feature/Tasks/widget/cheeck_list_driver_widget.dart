import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pallon_lastversion/feature/Tasks/funcation/task_function.dart';
import 'package:pallon_lastversion/models/item_model.dart';

import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/order_model.dart';


class CheeckListDriverWidget extends StatefulWidget{
  OrderModel _orderModel;
  bool ins;
  CheeckListDriverWidget(this._orderModel,this.ins);
  @override
  State<StatefulWidget> createState() {
    return _CheeckListDriverWidget();
  }
}


class _CheeckListDriverWidget extends State<CheeckListDriverWidget>{
  List<ItemModel> items=[];
  List<TextEditingController> controllers=[];
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  File? _image;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetOrderItems();
  }
  void GetOrderItems()async{
    items = await getorderitem(context, widget._orderModel);
    setState(() {
      items;
      for(int i=0;i<items.length;i++){
        controllers.add(
          TextEditingController(text: items[i].count.toString())
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            children: [
              SizedBox(height: screenHeight*0.03,),
              GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                      radius: screenWidth * 0.05,
                      backgroundColor: Colors.black,
                      child: _image != null
                          ? ClipOval(
                        child: Image.file(
                          _image!,
                          width: screenWidth * 0.3,
                          height: screenWidth * 0.3,
                          fit: BoxFit.cover,
                        ),
                      ) :Icon(
                        Icons.image,
                        size: screenWidth * 0.05,
                        color: Colors.grey[300],
                      )
                  )
              ),
              SizedBox(height: screenHeight*0.03,),
             items.length!=0? Column(
                children:List.generate(
                  items.length,(index) =>Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(items[index].name,
                      style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: screenWidth*0.03),),
                    Text(items[index].count.toString()),
                    SizedBox(
                      width: screenWidth*0.27,
                      child: TextField(
                        controller: controllers[index],
                      ),
                    ),
                  ],
                )
                )
              ):Text(""),
              SizedBox(height: screenHeight*0.03,),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: SizedBox(
                  width: double.infinity,
                  height: screenWidth * 0.17,
                  child: ElevatedButton(
                    onPressed: ()async{
                      if(_image!=null){
                        try{
                          final path = "item/photos/item-${DateTime.now().toString()}.jpg";
                          final ref = FirebaseStorage.instance.ref().child(path);
                          final uploadTask = ref.putFile(_image!);
                          final snapshot = await uploadTask.whenComplete(() {});
                          final urlDownload = await snapshot.ref.getDownloadURL();
                          await _firestore.collection('req').doc(widget._orderModel.req!.doc).collection('driver').doc().set({
                            'path':urlDownload,
                          }).whenComplete(()async{
                            await _firestore.collection('req').doc(widget._orderModel.req!.doc).collection('vendor').get().then((value){
                              for(int i=0;i<value.size;i++){
                                String doc=value.docs[i].id;
                                int count =value.docs[i].get('count');
                                for(int j=0;j<items.length;j++){
                                  if(items[j].doc==doc){
                                    if(count.toString()!=controllers[j].text){
                                      int newcount=int.parse(controllers[j].text);
                                      _firestore.collection('req').doc(widget._orderModel.req!.doc).collection('vendor').doc(doc).update({
                                        'count':newcount,
                                      }).whenComplete((){
                                        if(widget.ins){
                                          UpdateDriverTask(context,"Receipt from store",widget._orderModel.req!.doc);
                                        }
                                        else{
                                          UpdateItemTask(context,"Complete",widget._orderModel.req!.doc);
                                        }
                                        Get.back();
                                      });
                                    }
                                  }
                                }
                              }
                            });
                          });
                        }
                        catch(e){
                          showErrorDialog(context, e.toString());
                        }
                      }
                      else{
                        showErrorDialog(context, "برجاء تصوير التسليم");
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
                     "Submit".tr,
                      style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight*0.03,),
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
}