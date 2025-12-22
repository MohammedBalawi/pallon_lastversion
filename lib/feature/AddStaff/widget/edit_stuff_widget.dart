import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';
import 'package:pallon_lastversion/Core/Widgets/image_view.dart';
import 'package:pallon_lastversion/models/user_model.dart';

import '../../../Core/Widgets/common_widgets.dart';
import '../function/add_staff_function.dart';


class EditStaffWidget extends StatefulWidget{
  UserModel employee;

  EditStaffWidget(this.employee);
  @override
  State<StatefulWidget> createState() {
    return _EditStaffWidget();
  }

}

class _EditStaffWidget extends State<EditStaffWidget>{
  String? type;
  List<String> types = [
    "Admin",
    'coordinator',
    "driver",
    "vendor",
    'designer'
  ];
  bool show=false;
  TextEditingController _type=TextEditingController();
  @override
  void initState() {
    super.initState();
    _type=TextEditingController(text: widget.employee.type.toString());
    type=widget.employee.type;
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:  Text("Edit Employee".tr,style: TextStyle(color: Colors.white,
        fontFamily: ManagerFontFamily.fontFamily
        )),
        backgroundColor: const Color(0xFF07933E),
        leading: IconButton(
            onPressed: (){
              Get.back();
            },
            icon: const Icon(Icons.arrow_back,color: Colors.white)),
      ),
      body: ModalProgressHUD(
        inAsyncCall: show,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                    child: GestureDetector(
                      onTap: (){
                        Get.to(ViewImage(widget.employee.pic));
                      },
                      child: CircleAvatar(
                        radius: screenWidth * 0.15,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.employee.pic,
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  widget.employee.name,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  widget.employee.type.tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField2<String>(
                  isExpanded: true,

                  decoration: InputDecoration(
                    labelText: 'Select Type'.tr,
                    labelStyle: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),

                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),



                  value: type,

                  items: types.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Center(
                        child: Text(
                          item.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: 15,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  onChanged: (val) => setState(() => type = val),

                  validator: (value) =>
                  value == null ? 'Please select a type'.tr : null,

                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 260,
                    padding: const EdgeInsets.all(12),
                    elevation: 5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),

                  menuItemStyleData: const MenuItemStyleData(
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),

                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (type == widget.employee.type) {
                          Get.snackbar('نجاح', 'لم يتم تغيير أي شيء',backgroundColor:Colors.green,colorText: Colors.white );
                          return;
                        }

                        setState(() => show = true);

                        final updated = await UpdateStaffType(
                          widget.employee.doc,
                          type!,
                          context,
                        );

                        setState(() => show = false);

                        if (updated) {
                          Get.back();
                          Get.snackbar('نجاح', 'تم التحديث بنجاح',backgroundColor:Colors.green,colorText: Colors.white );

                          // mesgCustom(context, 'تم التحديث بنجاح'.tr);
                        } else {
                        }
                      },


                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF07933E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12
                          ),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Update Type'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,

                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialogmsg(context,"هل انت متاكد من الحذف");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCE232B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Delete Employee'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,

                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void showDialogmsg(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCE232B).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Color(0xFFCE232B),
                    size: 40,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'تنبيه'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFCE232B),
                    fontFamily: ManagerFontFamily.fontFamily,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: 1.4,
                    fontFamily: ManagerFontFamily.fontFamily,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      DeleteStaff(widget.employee.doc, context);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF07933E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'نعم'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: ManagerFontFamily.fontFamily,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'الغاء'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        fontFamily: ManagerFontFamily.fontFamily,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}