import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';
import 'package:pallon_lastversion/feature/AddStaff/view/edit_staff_view.dart';

import '../../../models/user_model.dart';


final FirebaseFirestore _firestore=FirebaseFirestore.instance;
final FirebaseAuth _auth=FirebaseAuth.instance;

Widget CustomeStaffTable(BuildContext context){
  final screenHeight = MediaQuery
      .of(context)
      .size
      .height;
  final screenWidth = MediaQuery
      .of(context)
      .size
      .width;
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('user').where('type',isNotEqualTo: 'client').snapshots(),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Color(0xFF07933E),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return  Center(
            child: Text('No Staff found.'.tr),
          );
        }
        List<DataRow> rows = [];
        List<UserModel> users=[];
        final messages = snapshot.data!.docs;
        for (var message in messages.reversed){
          if(message.id==_auth.currentUser!.uid){
          }
          else{
            UserModel user=UserModel(
                doc: message.id, email: message.get('email'),
                phone: message.get('phone'), name: message.get('name'),
                pic: message.get('pic'), type: message.get('type'));
            users.add(user);
            DataRow row=DataRow(
                cells: [
                  DataCell(InkWell(
                      onTap: (){
                        Get.to(EditStaffView(user));
                      },
                      child: Text(message.get('name',),style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily
                      ),))),
                  DataCell(InkWell(
                      onTap: (){
                        Get.to(EditStaffView(user));
                      },child: Text(message.get('email') ?? '',style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily
                  ),))),
                  DataCell(InkWell(
                      onTap: (){
                        Get.to(EditStaffView(user));
                      },child: Text(user.type.tr,style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily
                  ),))),
                  DataCell(
                  InkWell(
                    onTap: (){
                      Get.to(EditStaffView(user));
                    },
                      child: Text("Edit".tr,style: TextStyle(color: Colors.blue,fontFamily: ManagerFontFamily.fontFamily),))
                  ),
                ]
            );
            rows.add(row);
          }
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columnSpacing: screenWidth * 0.18,
              horizontalMargin: 16,
              dividerThickness: 2.0,
              showBottomBorder: true,
              sortAscending: true,
              columns: [
                DataColumn(
                  label: SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        'Name'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        'Email'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,

                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        'Type'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,

                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        'Action'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,

                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
          ], rows: rows),
        );
      }
  );
}