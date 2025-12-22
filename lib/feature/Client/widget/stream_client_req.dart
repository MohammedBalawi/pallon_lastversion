import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/req_data_model.dart';
import 'client_req_card.dart';

final FirebaseFirestore _firestore=FirebaseFirestore.instance;
final FirebaseAuth _auth=FirebaseAuth.instance;


Widget StreamClientReq(BuildContext context,bool scrool){
  final screenHeight = MediaQuery
      .of(context)
      .size
      .height;
  final screenWidth = MediaQuery
      .of(context)
      .size
      .width;
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('req').where('createDoc',isEqualTo: _auth.currentUser!.uid).snapshots(),
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
      List<ReqDataModel> req=[];
      final messages = snapshot.data!.docs;
      for (var message in messages.reversed){
        req.add(ReqDataModel(doc:message.id ,name: message.get('name'), fees: message.get('fees'), total: message.get('total'),
            des: [], item: [], float: message.get('float'), address: message.get('address'),
            date: message.get('date'), hour: message.get('hour'), phone: message.get('phone'),
            createby: message.get('createby'),
            deposite: message.get('deposit'), design: message.get('desgin'), notes: message.get('notes'),
            ownerOfevent: message.get('ownerofevent'),
            status: message.get('status'), typeby: message.get('typeCreate'), typeOfBuilding: message.get('typeofbuilding'),
            typeOfEvent: message.get('typeofevent'),
            branch:message.get("branch") ,typebank: message.get("banktype")));
      }
      return ListView.builder(
        itemCount: req.length,
        physics:scrool?ScrollPhysics(parent: AlwaysScrollableScrollPhysics()):NeverScrollableScrollPhysics(),
        itemBuilder: (context,index){
          return ClientReqCard(req[index]);
        },
      );
    },
  );
}