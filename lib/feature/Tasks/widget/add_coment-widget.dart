import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/models/user_model.dart';

import '../../../Core/Widgets/common_widgets.dart';
import '../funcation/task_function.dart';


class AddCommentWidget extends StatelessWidget{
  TextEditingController _comment=TextEditingController();
  UserModel userModel;
  String coll;
  String doc;
  AddCommentWidget(this.userModel,this.coll,this.doc);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight*0.45,
      color: Colors.white,
      child:Padding(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comment'.tr,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            TextFormField(
              controller: _comment,
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.text_fields),
                hintText: "Enter Your Comment".tr,
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.05),
              ),
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: screenHeight * 0.09),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                width: double.infinity,
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  onPressed: (){
                   if(_comment.text!=""){
                     AddComment(_comment,context,userModel,coll,doc);
                   }
                   else{
                     showErrorDialog(context,"Please Enter Comment".tr);
                   }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCE232B),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(screenWidth * 0.05),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Add Comment'.tr,
                    style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}