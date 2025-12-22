import 'package:flutter/material.dart';
import 'package:pallon_lastversion/feature/Catalog/widget/item_widget.dart';

import '../../../models/catalog_item_model.dart';


class ItemView extends StatelessWidget{
  CatalogItemModel itemModel;
  String path;
  ItemView(this.itemModel,this.path);
  @override
  Widget build(BuildContext context) {
    return ItemWidget(itemModel,path);
  }
}