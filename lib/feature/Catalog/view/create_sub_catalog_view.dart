import 'package:flutter/material.dart';

import '../../../models/catalog_model.dart';
import '../widget/create_sub_catalog_widget.dart';

class CreateSubCatalogView extends StatelessWidget{
  Catalog cat;
  CreateSubCatalogView(this.cat);
  @override
  Widget build(BuildContext context) {
    return CreateSubCatalogWidget(cat);
  }
}