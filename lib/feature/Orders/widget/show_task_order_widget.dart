import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pallon_lastversion/feature/Tasks/view/desgin_task_view.dart';
import 'package:pallon_lastversion/feature/Tasks/widget/cheeck_list_driver_widget.dart';
import 'package:pallon_lastversion/feature/Tasks/widget/vendor_task_widget.dart';
import '../../../Core/Utils/app.images.dart';
import '../../../models/order_model.dart';
import '../../../models/user_model.dart';
import '../../MainScreen/function/main_function.dart';
import '../../Tasks/funcation/task_function.dart';
import '../function/order_function.dart';


class ShowTaskOrderWidget extends StatefulWidget{
  OrderModel _orderModel;
  ShowTaskOrderWidget(this._orderModel);
  @override
  State<StatefulWidget> createState() {
    return _ShowTaskOrderWidget();
  }
}

class _ShowTaskOrderWidget extends State<ShowTaskOrderWidget>{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  File? _image;
  UserModel userModel = UserModel(
      doc: "doc", email: "email", phone: "phone", name: "name", pic: "pic", type: "type");
  @override
  void initState() {
    super.initState();
    GetUserType();
    Cheeck();
  }
  void GetUserType() async {
    if (_auth.currentUser != null) {
      UserModel? user = await GetUserData(_auth.currentUser!.uid);
      widget._orderModel=await GetTaskStatus(widget._orderModel, context);
      widget._orderModel = await GetStaffOrder(widget._orderModel, context);
      setState(() {
        userModel = user!;
        widget._orderModel;
      });
    }
  }
  void Cheeck()async{
    if(widget._orderModel.req!.des.isEmpty&& widget._orderModel.req!.task=="desginer"){
      await _firestore.collection('req').doc(widget._orderModel.req!.doc).update({
        'task':'vendor'
      }).whenComplete((){
        setState(() {
          widget._orderModel.req!.task="vendor";
        });
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF07933E),
        title: Text(
          "Tasks".tr,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('req').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Color(0xFF07933E),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return  Center(
              child: Text('No items found.'.tr),
            );
          }
          final messages = snapshot.data!.docs;
          for (var message in messages.reversed){
            if(message.id==widget._orderModel.req!.doc){
              widget._orderModel.req!.taskstatus=message.get('taskstatus');
              widget._orderModel.req!.task=message.get('task');
            }
          }
          return Padding(
              padding: const EdgeInsets.all(13.0),
              child: ListView(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  CircleAvatar(
                    radius: screenWidth * 0.35,
                    child: ClipOval(
                      child: Image.asset(AppImages.appPLogo,
                        width: screenWidth * 0.7,
                        height: screenWidth * 0.7,
                        fit: BoxFit.fill,)
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                 widget._orderModel.req!.des.isEmpty?Text(""): InkWell(
                    onTap: (){
                      Get.to(DesginTaskView(widget._orderModel),duration: Duration(seconds: 1),transition: Transition.circularReveal);
                    },
                    child: _buildInfoCard(
                      context,
                      title: "Designer".tr,
                      data: {
                        'Employee'.tr: widget._orderModel.Designer!.name,
                        'Status'.tr:widget._orderModel.req!.task=="desginer"?widget._orderModel.req!.taskstatus.toString():"Compelete",
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  InkWell(
                    onTap: (){
                      Get.to(VendorTaskWidget(widget._orderModel),duration: Duration(seconds: 1),transition: Transition.cupertino);
                    },
                    child: _buildInfoCard(
                      context,
                      title: "Vendor".tr,
                      data: {
                        'Employee'.tr: widget._orderModel.Vendor!.name,
                        'Status'.tr:widget._orderModel.req!.task=="vendor"? widget._orderModel.req!.taskstatus.toString():
                        widget._orderModel.req!.task!="desginer"?"Compelete":"Wait",
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  widget._orderModel.req!.branch=="توصيل"||widget._orderModel.req!.branch=="توصيل و تركيب"||
                      widget._orderModel.req!.branch=="شحن خارج جدة" ?_buildInfoCard(
                    context,
                    title: "Driver".tr,
                    data: {
                      'Employee'.tr: widget._orderModel.Driver!.name,
                      'Status'.tr:widget._orderModel.req!.task=="driver"? widget._orderModel.req!.taskstatus.toString():
                      widget._orderModel.req!.task!="desginer" && widget._orderModel.req!.task!="vendor"?"Compelete":"Wait",
                    },
                  ):Text(""),
                  SizedBox(height: screenHeight * 0.02),
                  widget._orderModel.req!.task=="driver"&& widget._orderModel.Driver!.doc==
                userModel.doc || userModel.type=="Admin" && widget._orderModel.req!.task=="driver" ||
              widget._orderModel.req!.task=="driver" && userModel.doc==widget._orderModel.Coordinator!.doc?Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: screenWidth * 0.17,
                      child: ElevatedButton(
                        onPressed: () {
                          if(widget._orderModel.req!.taskstatus=="progress"){
                            Get.bottomSheet(CheeckListDriverWidget(widget._orderModel,true));
                            // UpdateDriverTask(context,"Receipt from store",widget._orderModel.req!.doc);
                            // setState(() {
                            //   widget._orderModel.req!.taskstatus="Receipt from store";
                            // });
                          }
                          else if(widget._orderModel.req!.taskstatus=="Receipt from store"){
                            UpdateDriverTask(context,"Shipped",widget._orderModel.req!.doc);
                            setState(() {
                              widget._orderModel.req!.taskstatus="Shipped";
                            });
                          }
                          else if(widget._orderModel.req!.taskstatus=="Shipped"){
                            UpdateDriverTask(context,"Start moving",widget._orderModel.req!.doc);
                            setState(() {
                              widget._orderModel.req!.taskstatus="Start moving";
                            });
                          }
                          else if(widget._orderModel.req!.taskstatus=="Start moving"){
                            UpdateDriverTask(context,"Delivered",widget._orderModel.req!.doc);
                            setState(() {
                              widget._orderModel.req!.taskstatus="Delivered";
                            });
                          }
                          else if(widget._orderModel.req!.taskstatus=="Delivered"){
                            UpdateDriverTask(context,"installation",widget._orderModel.req!.doc);
                            setState(() {
                              widget._orderModel.req!.taskstatus="installation";
                            });
                          }
                          else if(widget._orderModel.req!.taskstatus=="installation"){
                            UpdateDriverTask(context,"Receipt from the customer",widget._orderModel.req!.doc);
                            setState(() {
                              widget._orderModel.req!.taskstatus="Receipt from the customer";
                            });
                          }
                          else if(widget._orderModel.req!.taskstatus=="Receipt from the customer"){
                            Get.bottomSheet(CheeckListDriverWidget(widget._orderModel,false));
                            // UpdateItemTask(context,"Complete",widget._orderModel.req!.doc);
                            // setState(() {
                            //   widget._orderModel.req!.taskstatus="Complete";
                            // });
                          }
                          else{
                            FinishOrder(context,widget._orderModel.req!.doc);
                            setState(() {
                              widget._orderModel.req!.taskstatus="finish";
                              widget._orderModel.req!.status='finish';
                              widget._orderModel.req!.task="finish";
                            });
                            Get.back();
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
                         widget._orderModel.req!.taskstatus=="progress"? "Receipt from store".tr:
                         widget._orderModel.req!.taskstatus=="Receipt from store"?"Shipped".tr:
                         widget._orderModel.req!.taskstatus=="Shipped"?"Start moving".tr:
                         widget._orderModel.req!.taskstatus=="Start moving"?"Delivered".tr:
                         widget._orderModel.req!.taskstatus=="Delivered"?"installation".tr:
                         widget._orderModel.req!.taskstatus=="installation"?"Receipt from the customer".tr:
                             widget._orderModel.req!.taskstatus=="Receipt from the customer"?"Complete".tr:widget._orderModel.req!.taskstatus=="Complete".tr?"Finish".tr:"",

                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ):Text(""),
                  SizedBox(height: screenHeight*0.02,),
                ],
              ),
            );
        },
      ),
    );
  }
  Widget _buildInfoCard(
      BuildContext context, {
        required String title,
        required Map<String, String> data,
      }) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFCE232B),
              ),
            ),
            const Divider(height: 20, thickness: 1),
            ...data.entries
                .map(
                  (entry) => _buildInfoRow(
                context,
                title: entry.key,
                data: entry.value,
              ),
            )
                .toList(),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoRow(
      BuildContext context, {
        required String title,
        required String data,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title:",
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
         title!="Status"? Flexible(
            child: Text(
              data,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
              ),
            ),
          ):Container(
           padding: const EdgeInsets.symmetric(
             horizontal: 10,
             vertical: 6,
           ),
           decoration: BoxDecoration(
             color:data=="Wait"? Colors.red
                 :data=="Compelete"?Colors.green:Colors.blue,
             borderRadius: BorderRadius.circular(
               8,
             ),
           ),

           child: Text(
             data,
             style: const TextStyle(
               color: Colors.white,
               fontWeight: FontWeight.w700,
               fontSize: 14,
             ),
           ),
         ),
        ],
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