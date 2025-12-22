import 'package:flutter/material.dart';

import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../widget/create_catalog_item_widget.dart';

class CreateCatalogItemView extends StatelessWidget{
  Catalog cat;
  SubCatModel sub;
  SubSubCatModel subsub;
  CreateCatalogItemView(this.cat,this.sub,this.subsub);
  @override
  Widget build(BuildContext context) {
    return CreateCatalogItemWidget(cat,sub,subsub);
  }
}