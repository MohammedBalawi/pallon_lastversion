import 'package:flutter/material.dart';

import '../../../models/catalog_model.dart';
import '../../../models/req_model.dart';
import '../widget/compelete_req_widget.dart';



class CompeleteReqView extends StatelessWidget{
  ReqModel req;
  List<Catalog> cat;
  CompeleteReqView(this.req,this.cat);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CompeleteReqWidget(req,cat);
  }
}