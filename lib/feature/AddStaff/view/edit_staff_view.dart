import 'package:flutter/material.dart';
import 'package:pallon_lastversion/feature/AddStaff/widget/edit_stuff_widget.dart';
import 'package:pallon_lastversion/models/user_model.dart';

class EditStaffView extends StatelessWidget{
  UserModel employee;
  EditStaffView(this.employee);

  @override
  Widget build(BuildContext context) {
    return EditStaffWidget(employee);
  }
}