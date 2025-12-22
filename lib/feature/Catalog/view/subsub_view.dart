import 'package:flutter/material.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/user_model.dart';
import '../widget/subsub_widget.dart';

class SubSubView extends StatelessWidget{
  UserModel userModel;
  SubCatModel sub;
  Catalog catalog;
  SubSubView(this.catalog,this.sub,this.userModel);
  @override
  Widget build(BuildContext context) {
    return SubSubWidget(this.catalog,this.sub,userModel);
  }
}