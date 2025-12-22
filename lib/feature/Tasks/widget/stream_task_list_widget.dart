import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/feature/Tasks/widget/task_card.dart';

import '../../../models/task_model.dart';


final FirebaseAuth _auth=FirebaseAuth.instance;
final FirebaseFirestore _firestore=FirebaseFirestore.instance;
Widget StreamTaskListWidget(BuildContext context,bool scrool){
  final screenHeight = MediaQuery
      .of(context)
      .size
      .height;
  final screenWidth = MediaQuery
      .of(context)
      .size
      .width;
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('user').doc(_auth.currentUser!.uid).collection('task').snapshots(),
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
      List<TaskModel> tasks=[];
      final messages = snapshot.data!.docs;
      for (var message in messages.reversed){
        tasks.add(
          TaskModel(doc: message.get('doc'))
        );
      }
      return ListView.builder(
        scrollDirection:scrool? Axis.vertical:Axis.horizontal,
        itemCount: tasks.length,
        itemBuilder: (context,index){
          return TaskCard(tasks[index]);
        },
      );
    },
  );
}