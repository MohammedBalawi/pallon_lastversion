import 'package:flutter/material.dart';

import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../widget/create_sub_sub_widget.dart';


class CreateSubSubView extends StatelessWidget{
  SubCatModel sub;
  Catalog catalog;
  CreateSubSubView(this.catalog,this.sub);
  @override
  Widget build(BuildContext context) {
    return CreateSubSubWidget(this.catalog,this.sub);
  }
}