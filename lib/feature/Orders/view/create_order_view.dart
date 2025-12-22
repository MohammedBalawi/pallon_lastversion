import 'package:flutter/material.dart';

import '../../../models/req_data_model.dart';
import '../widget/create_order_widget.dart';


class CreateOrderView extends StatelessWidget{
  ReqDataModel req;
  CreateOrderView(this.req);
  @override
  Widget build(BuildContext context) {
    return CreateOrderWidget(req);
  }
}