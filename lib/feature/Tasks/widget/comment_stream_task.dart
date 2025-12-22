import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/models/comment_model.dart';
import 'package:pallon_lastversion/models/order_model.dart';

final FirebaseAuth _auth=FirebaseAuth.instance;
final FirebaseFirestore _firestore=FirebaseFirestore.instance;

Widget CommentStreamTask(BuildContext context,String colle,OrderModel order){
  final screenHeight = MediaQuery
      .of(context)
      .size
      .height;
  final screenWidth = MediaQuery
      .of(context)
      .size
      .width;
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('req').doc(order.req!.doc).collection(colle).snapshots(),
    builder: (context,snapshot){
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(
            backgroundColor: Color(0xFF07933E),
          ),
        );
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Card(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: Text("No Comments".tr),
          ),
        );
      }
      List<CommentModel> comment=[];
      final messages = snapshot.data!.docs;
      for (var message in messages.reversed){
        comment.add(
          CommentModel(doc: message.id,
              name: message.get('name'), type: message.get('type'),
              pic: message.get('pic'), text: message.get('text'))
        );
      }
      return Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListView.builder(
          itemCount: comment.length,
          itemBuilder: (context,index){
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(comment[index].pic),
                radius: 15,
              ),
              title: Text(comment[index].name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment[index].type),
                  Text(comment[index].text)
                ],
              ),
              
            );
          },
        ),
      );
    },
  );
}