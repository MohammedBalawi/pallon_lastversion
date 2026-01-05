import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:pallon_lastversion/Core/Widgets/common_widgets.dart';
import '../../../Core/Widgets/image_view.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/order_model.dart';
import '../../../models/req_data_model.dart';
import '../../../models/user_model.dart';

import '../../Requset/functions/req_functions.dart' as req_fn;
import '../function/order_function.dart' as order_fn;
import 'order_details_widget.dart';

class CreateOrderWidget extends StatefulWidget {
  final ReqDataModel req;
  const CreateOrderWidget(this.req, {super.key});

  @override
  State<CreateOrderWidget> createState() => _CreateOrderWidget();
}

class _CreateOrderWidget extends State<CreateOrderWidget> {
  late final TextEditingController createAt;
  late final TextEditingController clientName;
  late final TextEditingController clientPhone;

  late ReqDataModel _req;

  List<UserModel> _designers = [];
  List<UserModel> _coordinator = [];
  List<UserModel> _vendor = [];
  List<UserModel> _driver = [];

  UserModel? _selectedCoordinator;
  UserModel? _selectedDesigner;
  UserModel? _selectedDriver;
  UserModel? _selectedVendor;

  bool show = false;

  int _tax = 0;

  String? _jobOrderNumber;

  String hourForm = "AM";
  int hour = 0;

  List<CatalogItemModel> get _items => (_req.item as List).cast<CatalogItemModel>();

  bool get _needsDesigner => _req.des.isNotEmpty;

  bool get _needsDriver =>
      _req.branch == "توصيل" ||
          _req.branch == "توصيل و تركيب" ||
          _req.branch == "شحن خارج جدة";

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();

    _req = widget.req;

    final dt = DateTime.tryParse(_req.doc.split('Doc').last);
    if (dt != null) {
      if (dt.hour > 12) {
        hour = dt.hour - 12;
        hourForm = "PM";
      } else {
        hour = dt.hour == 0 ? 12 : dt.hour;
        hourForm = "AM";
      }
    }

    createAt = TextEditingController(text: _req.doc.split("Doc").last);
    clientName = TextEditingController(text: _req.name);
    clientPhone = TextEditingController(text: _req.phone);

    _loadAllData();
  }

  @override
  void dispose() {
    createAt.dispose();
    clientName.dispose();
    clientPhone.dispose();
    super.dispose();
  }

  UserModel _fakeCurrentUser() {
    final auth = FirebaseAuth.instance;
    return UserModel(
      doc: auth.currentUser?.uid ?? "unknown",
      email: "",
      phone: "",
      name: "",
      pic: "",
      type: "",
    );
  }

  Future<void> _loadAllData() async {
    _safeSetState(() => show = true);
    try {
      final taxx = await order_fn.GetConstanttax();

      final reqWithDesign = await req_fn.GetReqDesign(_req, context);
      final reqWithItems = await req_fn.GetReqItem(_req, context);

      final coordinators = await req_fn.GetStuff("coordinator", context);
      final designers = await req_fn.GetStuff("designer", context);
      final drivers = await req_fn.GetStuff("driver", context);
      final vendors = await req_fn.GetStuff("vendor", context);

      if (!mounted) return;

      _safeSetState(() {
        _tax = taxx;

        _req.des = reqWithDesign.des;
        _req.notes = reqWithDesign.notes;
        _req.item = reqWithItems.item;

        _coordinator = coordinators;
        _designers = designers;
        _driver = drivers;
        _vendor = vendors;

        _selectedCoordinator = _coordinator.isNotEmpty ? _coordinator.first : null;
        _selectedDesigner = _designers.isNotEmpty ? _designers.first : null;
        _selectedDriver = _driver.isNotEmpty ? _driver.first : null;
        _selectedVendor = _vendor.isNotEmpty ? _vendor.first : null;
      });
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    } finally {
      _safeSetState(() => show = false);
    }
  }

  Future<void> _onCreatePressed() async {
    final List<String> missing = [];

    if (_selectedCoordinator == null) missing.add("المنظم (Coordinator)");
    if (_selectedVendor == null) missing.add("مدير المخزن (Vendor)");
    if (_needsDesigner && _selectedDesigner == null) missing.add("المصمم (Designer)");
    if (_needsDriver && _selectedDriver == null) missing.add("السائق (Driver)");

    if (missing.isNotEmpty) {
      showErrorDialog(context, "الرجاء اختيار:\n• ${missing.join("\n• ")}");
      return;
    }

    _safeSetState(() => show = true);

    try {
      final jobNo = await order_fn.createJobOrder(
        context: context,
        req: _req,
        coordinator: _selectedCoordinator!,
        designer: _needsDesigner ? _selectedDesigner! : _fakeCurrentUser(),
        driver: _needsDriver ? _selectedDriver! : _fakeCurrentUser(),
        vendor: _selectedVendor!,
      );

      if (!mounted || jobNo == null) return;

      _safeSetState(() => _jobOrderNumber = jobNo);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("تم إنشاء أمر التشغيل رقم: $jobNo"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final String userType = (_req.typeby ?? "").toLowerCase();

      if (userType != "Client") {
        OrderModel orderModel = OrderModel();
        orderModel.req = _req;

        orderModel = await order_fn.GetStaffOrder(orderModel, context);

        orderModel = await order_fn.GetTaskStatus(orderModel, context);

        if (!mounted) return;

        Get.offUntil(
          GetPageRoute(
            page: () => OrderDetailsWidget(orderModel),
            transition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 400),
          ),
              (route) => route.settings.name == '/add-order',
        );


      } else {
        Navigator.of(context).pop(true);
      }

    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    } finally {
      _safeSetState(() => show = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: ModalProgressHUD(
        inAsyncCall: show,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: screen.width * 0.06,
                right: screen.width * 0.06,
                top: screen.height * 0.05,
                bottom: screen.height * 0.03,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07933E), Color(0xFF007530)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Create Job Order".tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screen.width * 0.052,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "#${_req.canonicalOrderNumber()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _buildInfoCard(
                      context,
                      icon: Icons.person,
                      title: "Client & Request Details".tr,
                      data: {
                        'Request Date'.tr: _formatReqDate(),
                        'Client Name'.tr: _req.name,
                        'Client Phone'.tr: _req.phone,
                        'Owner Of Event'.tr: _req.ownerOfevent,
                        'Order Number'.tr: _req.canonicalOrderNumber(),
                        'Job Order Number'.tr: _jobOrderNumber ?? "-",
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      context,
                      icon: Icons.location_on_outlined,
                      title: "Event & Location".tr,
                      data: {
                        'Event Type'.tr: _req.typeOfEvent,
                        'Event Owner'.tr: _req.ownerOfevent,
                        'Receiving'.tr: _req.branch,
                        'Address'.tr: "${_req.address} - ${_req.typeOfBuilding} - ${_req.float}",
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      context,
                      icon: Icons.payments_outlined,
                      title: "Payment Summary".tr,
                      data: {
                        'Payment Method'.tr: _req.typebank,
                        'Total Price'.tr: "${_req.total} SAR",
                        'Deposit'.tr: "${_req.deposite} SAR",
                        'Remaining Fees'.tr: "${_req.fees} SAR",
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildStaffSelectionCard(context),
                    const SizedBox(height: 12),

                    if (_items.isNotEmpty) ...[
                      _buildItemsCard(context),
                      const SizedBox(height: 12),
                    ],

                    _buildDesignCard(context),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: show ? null : _onCreatePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCE232B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          "Create".tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatReqDate() {
    final dt = DateTime.tryParse(_req.doc.split('Doc').last);
    if (dt == null) return "-";
    return "${dt.year}/${dt.month}/${dt.day}\n$hour $hourForm";
  }


  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Map<String, String> data,
      }) {
    return Card(
      color: Colors.white,
      elevation: 2.5,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF07933E).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF07933E)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFCE232B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            const SizedBox(height: 10),
            ...data.entries.map((e) => _buildInfoRow(e.key, e.value)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffSelectionCard(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2.5,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCE232B).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.groups_2_outlined, color: Color(0xFFCE232B)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Assign Staff Members".tr,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFCE232B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            const SizedBox(height: 12),

            _buildStaffDropdown(
              title: "Coordinator".tr,
              items: _coordinator,
              selectedValue: _selectedCoordinator,
              onChanged: (v) => _safeSetState(() => _selectedCoordinator = v),
            ),
            const SizedBox(height: 12),

            if (_needsDesigner) ...[
              _buildStaffDropdown(
                title: "Designer".tr,
                items: _designers,
                selectedValue: _selectedDesigner,
                onChanged: (v) => _safeSetState(() => _selectedDesigner = v),
              ),
              const SizedBox(height: 12),
            ],

            if (_needsDriver) ...[
              _buildStaffDropdown(
                title: "Driver".tr,
                items: _driver,
                selectedValue: _selectedDriver,
                onChanged: (v) => _safeSetState(() => _selectedDriver = v),
              ),
              const SizedBox(height: 12),
            ],

            _buildStaffDropdown(
              title: "Vendor".tr,
              items: _vendor,
              selectedValue: _selectedVendor,
              onChanged: (v) => _safeSetState(() => _selectedVendor = v),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<UserModel>(
                isExpanded: true,
                value: selectedValue,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                hint: Text("Select $title"),
                onChanged: items.isEmpty ? null : onChanged,
                items: items.map((u) {
                  return DropdownMenuItem<UserModel>(
                    value: u,
                    child: Text(u.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Card(
      color: Colors.white,
      elevation: 2.5,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF07933E).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF07933E)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Requested Items".tr,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFCE232B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: w * 0.06,
                headingRowHeight: 44,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 56,
                headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                columns: [
                  DataColumn(label: Text('Name'.tr, style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataColumn(label: Text('Price'.tr, style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataColumn(label: Text('Count'.tr, style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataColumn(label: Text('Total'.tr, style: const TextStyle(fontWeight: FontWeight.w900))),
                  DataColumn(label: Text('Notes'.tr, style: const TextStyle(fontWeight: FontWeight.w900))),
                ],
                rows: _items.map((item) {
                  final total = (double.tryParse(item.price) ?? 0.0) * item.count;
                  return DataRow(
                    cells: [
                      DataCell(SizedBox(
                        width: w * 0.32,
                        child: Text(item.name, overflow: TextOverflow.ellipsis),
                      )),
                      DataCell(Text(
                        "${item.price} SAR",
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF07933E)),
                      )),
                      DataCell(Text(
                        "${item.count}",
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF07933E)),
                      )),
                      DataCell(Text(
                        "${total.toStringAsFixed(2)} SAR",
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF07933E)),
                      )),
                      DataCell(SizedBox(
                        width: w * 0.26,
                        child: Text(item.des, overflow: TextOverflow.ellipsis),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hasDesign = _req.des.isNotEmpty;

    final statusText = hasDesign ? "Design Attached".tr : "No Design Provided".tr;
    final statusColor = hasDesign ? const Color(0xFF07933E) : const Color(0xFFCE232B);

    return Card(
      color: Colors.white,
      elevation: 2.5,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.design_services_outlined, color: statusColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Special Design Status".tr,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFCE232B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            const SizedBox(height: 10),

            if (hasDesign) ...[
              Text(
                "Design Images (${_req.des.length}):",
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: screenWidth * 0.32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _req.des.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final url = _req.des[index];
                    return InkWell(
                      onTap: () {
                        Get.to(
                              () => ViewImage(url),
                          duration: const Duration(milliseconds: 400),
                          transition: Transition.fadeIn,
                        );
                      },
                      child: Container(
                        width: screenWidth * 0.34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            Text(
              "Notes: ${_req.notes}",
              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
