import 'package:flutter/material.dart';

import '../../../models/order_model.dart';
import '../widget/order_details_widget.dart';


class OrderDetailsView extends StatelessWidget{
  OrderModel _orderModel;
  OrderDetailsView(this._orderModel);
  @override
  Widget build(BuildContext context) {
    return OrderDetailsWidget(_orderModel);
  }
}