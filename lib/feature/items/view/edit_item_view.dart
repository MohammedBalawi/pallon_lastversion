import 'package:flutter/material.dart';

import '../../../models/item_model.dart';
import '../widget/edit_item_widget.dart';


class EditItemView extends StatelessWidget{
  ItemModel itemModel;
  EditItemView(this.itemModel);
  @override
  Widget build(BuildContext context) {
    return EditItemWidget(itemModel);
  }
}