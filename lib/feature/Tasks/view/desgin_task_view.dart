import 'package:flutter/material.dart';
import 'package:pallon_lastversion/feature/Tasks/widget/desgin_task_widget.dart';

import '../../../models/order_model.dart';

class DesginTaskView extends StatelessWidget{
  OrderModel _orderModel;
  DesginTaskView(this._orderModel);
  @override
  Widget build(BuildContext context) {
    return DesginTaskWidget(this._orderModel);
  }

}