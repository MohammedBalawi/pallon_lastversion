import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/feature/AddRequest/functions/req_function.dart';
import 'package:pallon_lastversion/models/order_model.dart';
import '../../../models/item_model.dart';
import '../../../models/user_model.dart';
import '../../MainScreen/function/main_function.dart';
import '../../Orders/function/order_function.dart';
import '../funcation/task_function.dart';
import 'add_coment-widget.dart';
import 'comment_stream_task.dart';

class VendorTaskWidget extends StatefulWidget {
  final OrderModel _orderModel;
  VendorTaskWidget(this._orderModel);

  @override
  State<StatefulWidget> createState() {
    return _VendorTaskWidget();
  }
}

class _VendorTaskWidget extends State<VendorTaskWidget> {
  List<ItemModel> items = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel userModel = UserModel(
    doc: "doc",
    email: "email",
    phone: "phone",
    name: "name",
    pic: "pic",
    type: "type",
  );

  ItemModel? selectedItem;
  int selectedQuantity = 1;
  List<Map<String, dynamic>> selectedItemsTable = [];

  @override
  void initState() {
    super.initState();
    GetUserType();
    GetItems();
  }
  Future<List<ItemModel>> GetVendorItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('show', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((e) => ItemModel.fromMap(e.data(), docId: e.id))
        .toList();
  }

  void GetItems() async {
    items = await GetVendorItems();
    setState(() {});
  }


  void GetUserType() async {
    if (_auth.currentUser != null) {
      UserModel? user = await GetUserData(_auth.currentUser!.uid);
      setState(() {
        userModel = user!;
      });
    }
  }

  void addItemToTable() {
    if (selectedItem != null && selectedQuantity > 0) {
      ItemModel item=selectedItem!;
      item.count=selectedQuantity;
      double price=item.price*item.count;
      item.price=price;
      setState(() {
        selectedItemsTable.add({
          'item': selectedItem!,
          'quantity': selectedQuantity,
        });
        selectedItem = null;
        selectedQuantity = 1;
      });
      AddVendorTask(context,item,widget._orderModel);
    } else {
      Get.snackbar("Error".tr, "Please select an item and quantity.".tr);
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
          "Vendor Task".tr,
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
           widget._orderModel!.Vendor!.doc==userModel.doc?
           _buildItemDropdown():Text(""),
            SizedBox(height: screenHeight*0.009),
            Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildItemTable(),
                )),
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
                "vendorcomment",
                widget._orderModel,
              ),
            ),
            widget._orderModel.Vendor!.doc == userModel.doc
                ? Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                width: double.infinity,
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget._orderModel.req!.task = "driver";
                    });
                    FinishTask(
                      context,
                      widget._orderModel,
                      "driver",
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
              "vendorcomment",
              widget._orderModel.req!.doc,
            ),
          );
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.chat, color: Colors.green),
      ),
    );
  }

  Widget _buildItemDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Item".tr,
            style: TextStyle(
                fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        DropdownButton<ItemModel>(
          isExpanded: true,
          hint: Text("Choose an item".tr),
          value: selectedItem,
          items: items.map((item) {
            return DropdownMenuItem<ItemModel>(
              value: item,
              child: Text(item.name ?? 'Unnamed'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedItem = value;
            });
          },
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text("Quantity:".tr),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                initialValue: selectedQuantity.toString(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter quantity".tr,
                ),
                onChanged: (val) {
                  selectedQuantity = int.tryParse(val) ?? 1;
                },
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: addItemToTable,
              child: Text("Add".tr,style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemTable() {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final FirebaseFirestore firestore=FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('req').doc(widget._orderModel.req!.doc).collection('vendor').snapshots(),
      builder: (context,snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Color(0xFF07933E),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text("No items added yet.".tr)),
                ),
          );
        }
        List<ItemModel> vendoritems=[];
        final messages = snapshot.data!.docs;
        for (var message in messages.reversed){
          vendoritems.add(
            ItemModel(doc: message.id,
                id: message.get('id'), name: message.get('name'),
                count: message.get('count'),
                price: message.get('price'), pic: message.get('pic'),
                show: message.get('show'))
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selected Items".tr,
                style: TextStyle(
                  fontSize: screenWidth*0.05,
                    fontWeight: FontWeight.bold,
                  color: Colors.red
                )),
            DataTable(
              columns:  [
                DataColumn(label: Text("Item".tr)),
                DataColumn(label: Text("Quantity".tr)),
                DataColumn(label: Text("Action".tr)),
              ],
              rows: vendoritems.map((entry) {
                final item = entry.name;
                final quantity = entry.count;
                return DataRow(
                  cells: [
                    DataCell(Text(item)),
                    DataCell(Text(quantity.toString())),
                   widget._orderModel.Vendor!.doc==userModel.doc?
                   DataCell(
                      IconButton(
                        onPressed: (){
                          DeleteVendorItem(context,entry,widget._orderModel);
                        },
                        icon: Icon(Icons.remove_circle_outline),
                      )
                    ):DataCell(Text("No Action")),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
