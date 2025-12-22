import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../widget/show_task_order_widget.dart';


class ShowTaskOrderView extends StatelessWidget{
  OrderModel _orderModel;
  ShowTaskOrderView(this._orderModel);
  @override
  Widget build(BuildContext context) {
    return ShowTaskOrderWidget(_orderModel);
  }
}