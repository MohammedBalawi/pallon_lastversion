import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../widget/inbox_widget.dart';

class InBoxView extends StatelessWidget{
  UserModel userModel;
  InBoxView(this.userModel);
  @override
  Widget build(BuildContext context) {
    return InBoxWidget(userModel);
  }
}