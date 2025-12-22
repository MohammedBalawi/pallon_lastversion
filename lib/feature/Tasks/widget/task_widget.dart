import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/feature/Tasks/widget/stream_task_list_widget.dart';


class TaskWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _TaskWidget();
  }
}


class _TaskWidget extends State<TaskWidget>{
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF07933E),
        title: Text("All Task".tr,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
      ),
      body: StreamTaskListWidget(context,true),
    );
  }
}