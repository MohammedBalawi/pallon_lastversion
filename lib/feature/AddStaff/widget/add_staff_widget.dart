import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/app.images.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

import '../../../models/user_model.dart';
import '../function/add_staff_function.dart';
import 'custom_staff_table.dart';

class AddStaffWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddStaffWidget();
}

class _AddStaffWidget extends State<AddStaffWidget> {
  List<UserModel> staff = [];
  List<UserModel> clients = [];
  List<UserModel> filteredClients = [];
  UserModel? _selectedClient;
  String? type;

  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String> types = ["Admin", 'coordinator', "driver", "vendor", 'designer'];

  @override
  void initState() {
    super.initState();
    _getStaffAndClientData();
  }

  void _getStaffAndClientData() async {
    List<UserModel> fetchedStaff = await GetAllStaff();
    List<UserModel> fetchedClients = await GetAllClients();

    setState(() {
      staff = fetchedStaff;
      clients = fetchedClients;
      filteredClients = fetchedClients;
    });
  }

  void _filterClients(String query) {
    setState(() {
      filteredClients = clients.where((c) {
        final q = query.toLowerCase();
        return c.name.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q);
      }).toList();
    });
  }

  void _addStaffToTable() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClient != null && type != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        await firestore.collection("user").doc(_selectedClient!.doc).update({
          'type': type!,
        });

        setState(() {
          clients.removeWhere((u) => u.doc == _selectedClient!.doc);
          filteredClients.removeWhere((u) => u.doc == _selectedClient!.doc);

          _selectedClient = null;
          type = null;
          _searchController.clear();
        });


        Get.snackbar(
          'Success'.tr,
          'Staff role updated successfully'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.19,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07933E), Color(0xFF007530)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: screenHeight * 0.08,
                    left: screenWidth * 0.08,
                    child: Text(
                      'Staff'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _searchController,
                      onChanged: _filterClients,
                      decoration: InputDecoration(
                        labelText: 'Search user by name or email'.tr,
                        labelStyle:TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 14,
                          color: Colors.grey,
                        ) ,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                              height: 20,
                              width: 20,
                              child: SvgPicture.asset(AppImages.search,color: Colors.grey,fit: BoxFit.contain,)),
                        ),

                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                  DropdownButtonFormField2<UserModel>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Select User'.tr,
                      labelStyle: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: SvgPicture.asset(
                            AppImages.SelectUser,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                    ),

                    value: _selectedClient,

                    items: [
                      for (int i = 0; i < filteredClients.length; i++)
                        DropdownMenuItem<UserModel>(
                          value: filteredClients[i],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                filteredClients[i].name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: ManagerFontFamily.fontFamily,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              if (i != filteredClients.length - 1)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],

                    selectedItemBuilder: (context) {
                      return filteredClients.map((user) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: ManagerFontFamily.fontFamily,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        );
                      }).toList();
                    },

                    onChanged: (value) {
                      setState(() => _selectedClient = value);
                    },

                    validator: (value) =>
                    value == null ? 'Please select a user'.tr : null,

                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 400,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),




                  const SizedBox(height: 16),

                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Select Role'.tr,
                      labelStyle: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: SvgPicture.asset(
                            AppImages.settings,
                            color: Colors.grey.shade500,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),

                    value: type,

                    items: [
                      for (int i = 0; i < types.length; i++)
                        DropdownMenuItem<String>(
                          value: types[i],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  types[i].tr,
                                  style: TextStyle(
                                    fontFamily: ManagerFontFamily.fontFamily,
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                              if (i != types.length - 1)
                                Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: Colors.grey.shade300,
                                ),
                            ],
                          ),
                        ),
                    ],

                    selectedItemBuilder: (context) {
                      return types.map((item) {
                        return Text(
                          item.tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: 15,
                            color: Colors.grey.shade800,
                          ),
                        );
                      }).toList();
                    },

                    onChanged: (val) => setState(() => type = val),

                    validator: (value) =>
                    value == null ? 'Please select a role'.tr : null,

                    dropdownStyleData: DropdownStyleData(
                      elevation: 5,
                      maxHeight: 260,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),

                    menuItemStyleData: const MenuItemStyleData(
                      padding: EdgeInsets.zero,
                      height: 52,
                    ),
                  ),




                  const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _addStaffToTable,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF07933E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 20),
                        elevation: 5,
                      ),
                      child: Text(
                        'Add Staff'.tr,
                        style:  TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                height: screenHeight * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),

                padding: const EdgeInsets.all(16),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: CustomeStaffTable(context),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
