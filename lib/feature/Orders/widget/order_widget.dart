import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_list_orders.dart';


class OrderWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _OrderWidget();
  }
}

class _OrderWidget extends State<OrderWidget>{
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
          backgroundColor: const Color(0xFF07933E),
          title: Text("Order".tr,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
      ),
      body: CustomListOrders(context),
    );
  }
}