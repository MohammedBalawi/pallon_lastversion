import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/feature/Tasks/widget/add_coment-widget.dart';
import 'package:pallon_lastversion/feature/Tasks/widget/comment_stream_task.dart';
import '../../../models/order_model.dart';
import '../../../models/user_model.dart';
import '../../MainScreen/function/main_function.dart';
import '../funcation/task_function.dart';
import 'desgin_image_stream.dart';

class DesginTaskWidget extends StatefulWidget {
  OrderModel _orderModel;
  DesginTaskWidget(this._orderModel);
  @override
  State<StatefulWidget> createState() {
    return _DesginTaskWidget();
  }
}

class _DesginTaskWidget extends State<DesginTaskWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel userModel = UserModel(
    doc: "doc",
    email: "email",
    phone: "phone",
    name: "name",
    pic: "pic",
    type: "type",
  );
  @override
  void initState() {
    super.initState();
    GetUserType();
  }
  void GetUserType() async {
    if (_auth.currentUser != null) {
      UserModel? user = await GetUserData(_auth.currentUser!.uid);
      setState(() {
        userModel = user!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF07933E),
        title: Text(
          "Design Task".tr,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(13.0),
        child: ListView(
          children: [
            DesginImageStream(context,widget._orderModel,userModel),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Comments".tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.06,
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.3,
              child: CommentStreamTask(
                context,
                "designercomment",
                widget._orderModel,
              ),
            ),
            widget._orderModel.Designer!.doc == userModel.doc
                ? Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.07,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            widget._orderModel.req!.task = "vendor";
                          });
                          FinishTask(
                            context,
                            widget._orderModel,
                            "vendor",
                            "progress",
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCE232B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.05,
                            ),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Finish Task'.tr,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : Text(""),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.bottomSheet(
            AddCommentWidget(
              userModel,
              "designercomment",
              widget._orderModel.req!.doc,
            ),
          );
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.chat, color: Colors.green),
      ),
    );
  }
}
