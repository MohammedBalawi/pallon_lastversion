import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../function/inbox_function.dart';

class CreateInBoxWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateInBoxWidget();
  }
}

class _CreateInBoxWidget extends State<CreateInBoxWidget> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();
  bool _show = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

    return ModalProgressHUD(
      inAsyncCall: _show,
      child: SingleChildScrollView(
        child: Container(
          color: Colors.grey[100],
          width: screenWidth,
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Card(

              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Create Inbox Message'.tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        Icon(
                          Icons.mail_outline,
                          color: const Color(0xFF07933E),
                          size: screenWidth * 0.07,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    Text(
                      'Title'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    TextFormField(
                      controller: _title,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.title_rounded),
                        hintText: 'Title'.tr,
                        hintStyle: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF07933E),
                            width: 1.2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.04,
                        color: const Color(0xFF000000),
                      ),
                      keyboardType: TextInputType.text,
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    Text(
                      'Body'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    TextFormField(
                      controller: _body,
                      maxLines: 5,
                      minLines: 3,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.notes_rounded),
                        hintText: 'Body'.tr,
                        hintStyle: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF07933E),
                            width: 1.2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.038,
                        color: const Color(0xFF000000),
                      ),
                      keyboardType: TextInputType.multiline,
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.065,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_title.text.trim().isEmpty) {
                            showErrorDialog(context, "Please Enter Title".tr);
                            return;
                          }
                          if (_body.text.trim().isEmpty) {
                            showErrorDialog(context, "Please Enter Body".tr);
                            return;
                          }

                          setState(() {
                            _show = true;
                          });

                          await AddNewInBox(context, _title, _body);

                          if (mounted) {
                            setState(() {
                              _show = false;
                            });
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07933E),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(screenWidth * 0.05),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'Add New InBox'.tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.01),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
