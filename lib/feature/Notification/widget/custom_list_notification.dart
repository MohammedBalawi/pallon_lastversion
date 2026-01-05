import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/notification_model.dart';
import '../../../models/order_model.dart';
import '../../../models/req_data_model.dart';
import '../../Orders/view/order_details_view.dart';



final FirebaseFirestore _firestore=FirebaseFirestore.instance;
final FirebaseAuth _auth=FirebaseAuth.instance;


Widget CustomListNotification(BuildContext context){
  final screenHeight = MediaQuery
      .of(context)
      .size
      .height;
  final screenWidth = MediaQuery
      .of(context)
      .size
      .width;
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('user').doc(_auth.currentUser!.uid).collection('Notification').snapshots(),
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
      List<NotificationModel> list=[];
      final messages = snapshot.data!.docs;
      for (var message in messages.reversed){
        list.add(
          NotificationModel(title: message.get('title'),
              body: message.get('body'), req: message.get('doc'), doc: message.id)
        );
      }
      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context,index){
          return StreamBuilder<QuerySnapshot>(
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
                  child: Text('No Notification found.'.tr),
                );
              }
              String name="";
              ReqDataModel req=ReqDataModel(doc: "doc", name: "name",
                  fees: "fees", total: "total", des: [], item: [], float: "float", address: "address",
                  date: "date", hour: "hour", phone: "phone", createby: "createby",
                  deposite: "deposite", design: "design",
                  notes: "notes", ownerOfevent: "ownerOfevent", status: "status",
                  typeby: "typeby", typeOfBuilding: "typeOfBuilding", typeOfEvent: "typeOfEvent",
                  branch: "branch", typebank: "typebank");
              final messages = snapshot.data!.docs;
              for (var message in messages.reversed){
                final data = message.data() as Map<String, dynamic>;
                 req=ReqDataModel(doc:message.id ,name: message.get('name'), fees: message.get('fees'), total: message.get('total'),
                    des: [], item: [], float: message.get('float'), address: message.get('address'),
                    date: ReqDataModel.normalizeDate(message.get('date')), hour: message.get('hour'), phone: message.get('phone'),
                    createby: message.get('createby'),
                    deposite: message.get('deposit'), design: message.get('desgin'), notes: message.get('notes'),
                    ownerOfevent: message.get('ownerofevent'),
                    status: message.get('status'), typeby: message.get('typeCreate'), typeOfBuilding: message.get('typeofbuilding'),
                    typeOfEvent: message.get('typeofevent'),
                    branch:message.get("branch") ,typebank: message.get("banktype"),
                    invoiceNumber: (data['invoiceNumber'] ?? data['invoice_number'] ?? "").toString(),
                    eventName: (data['eventName'] ?? data['event_name'] ?? "").toString(),
                    requestDate: ReqDataModel.normalizeDate(data['requestDate'] ?? data['request_date']),
                    createdAt: ReqDataModel.normalizeDate(data['createdAt']));
                name=message.get('name');
              }
              OrderModel orderModel=OrderModel();
              orderModel.req=req;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  elevation: 3,
                  child: ListTile(
                    onTap: (){
                      Get.to(OrderDetailsView(orderModel),transition: Transition.fadeIn,duration: Duration(seconds: 1));
                    },
                    title: Text(list[index].title),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(list[index].body,style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
                        Text("In Order $name",style: TextStyle(color: Colors.grey))
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
