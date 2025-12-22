import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/models/order_model.dart';

import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/user_model.dart';
import '../../Requset/functions/req_functions.dart';
import '../function/order_function.dart';


class EditEmployeeJopOrderWidget extends StatefulWidget{
  OrderModel _orderModel;
  EditEmployeeJopOrderWidget(this._orderModel);
  @override
  State<StatefulWidget> createState() {
    return _EditEmployeeJopOrderWidget();
  }

}


class _EditEmployeeJopOrderWidget extends State<EditEmployeeJopOrderWidget>{
  List<UserModel> _designers=[];
  List<UserModel> _coordinator=[];
  List<UserModel> _vendor=[];
  List<UserModel> _driver=[];

  UserModel? _selectedCoordinator;
  UserModel? _selectedDesigner;
  UserModel? _selectedDriver;
  UserModel? _selectedVendor;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Start();
  }
  void Start()async{
    _coordinator=await GetStuff("coordinator", context);
    _designers=await GetStuff("designer", context);
    _driver=await GetStuff("driver", context);
    _vendor=await GetStuff("vendor", context);
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildStaffSelectionCard(context, screenWidth),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                width: double.infinity,
                height: screenWidth * 0.17,
                child: ElevatedButton(
                  onPressed: () {
                    if(_selectedCoordinator!=null&&_selectedDesigner!=null&&
                    _selectedDriver!=null&&_selectedVendor!=null){
                      UpdateStaffOrder(
                        context,_selectedCoordinator!,_selectedVendor!,
                        _selectedDriver!,_selectedDesigner!,widget._orderModel
                      );
                    }
                    else{
                      showErrorDialog(context,"Please Select All Staff".tr);
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
                    "Save Edit".tr,
                    style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStaffSelectionCard(BuildContext context, double screenWidth) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Edit Staff Members".tr,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFCE232B),
              ),
            ),
            const Divider(height: 20, thickness: 1),

            _buildStaffDropdown(
              title: "Coordinator:".tr,
              items: _coordinator,
              selectedValue: _selectedCoordinator,
              onChanged: (UserModel? newValue) {
                setState(() {
                  _selectedCoordinator = newValue;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildStaffDropdown(
              title: "Designer:".tr,
              items: _designers,
              selectedValue: _selectedDesigner,
              onChanged: (UserModel? newValue) {
                setState(() {
                  _selectedDesigner = newValue;
                });
              },
            ),
            const SizedBox(height: 12),

            _buildStaffDropdown(
              title: "Driver:".tr,
              items: _driver,
              selectedValue: _selectedDriver,
              onChanged: (UserModel? newValue) {
                setState(() {
                  _selectedDriver = newValue;
                });
              },
            ),
            const SizedBox(height: 12),

            _buildStaffDropdown(
              title: "Vendor:".tr,
              items: _vendor,
              selectedValue: _selectedVendor,
              onChanged: (UserModel? newValue) {
                setState(() {
                  _selectedVendor = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStaffDropdown({
    required String title,
    required List<UserModel> items,
    required UserModel? selectedValue,
    required ValueChanged<UserModel?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<UserModel>(
                isExpanded: true,
                value: selectedValue,
                icon: const Icon(Icons.arrow_drop_down),
                hint: Text("Select $title"),
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<UserModel>>((UserModel user) {
                  return DropdownMenuItem<UserModel>(
                    value: user,
                    child: Text(user.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}