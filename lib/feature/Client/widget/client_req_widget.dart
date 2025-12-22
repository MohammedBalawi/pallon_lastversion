import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/feature/Client/widget/stream_client_req.dart';


class ClientReqWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _ClientReqWidget();
  }
}


class _ClientReqWidget extends State<ClientReqWidget>{
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("All Request".tr,style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF07933E),
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: StreamClientReq(context,true),
      ),
    );
  }
}