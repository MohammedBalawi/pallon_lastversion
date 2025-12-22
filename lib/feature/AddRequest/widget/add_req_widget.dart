import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

import '../../../models/catalog_model.dart';
import '../../../models/req_model.dart';
import '../view/complete_req_view.dart';

class AddReqWidget extends StatefulWidget {
  const AddReqWidget({super.key});

  @override
  State<AddReqWidget> createState() => _AddReqWidget();
}

class _AddReqWidget extends State<AddReqWidget> {
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController type = TextEditingController();
  final TextEditingController nameofevent = TextEditingController();
  final TextEditingController address = TextEditingController(text: "");
  final TextEditingController hour = TextEditingController();
  final TextEditingController date = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ScrollController _scrollCtrl = ScrollController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _typeFocus = FocusNode();

  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _typeKey = GlobalKey();
  final GlobalKey _hourKey = GlobalKey();
  final GlobalKey _dateKey = GlobalKey();

  final Map<String, bool> _missingState = {
    'Name': false,
    'Type Of Event': false,
    'Hour': false,
    'Date': false,
  };

  List<Catalog> _fullCatalog = [];

  @override
  void initState() {
    super.initState();
    // _getAllCatalog();
    name.addListener(_refreshMissingStateLive);
    type.addListener(_refreshMissingStateLive);
    hour.addListener(_refreshMissingStateLive);
    date.addListener(_refreshMissingStateLive);
  }

  // Future<void> _getAllCatalog() async {
  //   final cats = await GetAllCatalogData();
  //   if (!mounted) return;
  //   setState(() => _fullCatalog = cats);
  // }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    type.dispose();
    nameofevent.dispose();
    address.dispose();
    hour.dispose();
    date.dispose();

    _scrollCtrl.dispose();

    _nameFocus.dispose();
    _typeFocus.dispose();

    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        date.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && mounted) {
      setState(() {
        hour.text = picked.format(context);
      });
    }
  }

  InputDecoration _deco({
    required double screenWidth,
    required double screenHeight,
    required String hint,
    IconData? icon,
    Widget? suffix,
    bool highlightGreen = false,
  }) {
    final Color green = const Color(0xFF07933E);

    return InputDecoration(
      hintText: hint.tr,
      hintStyle: TextStyle(
        fontFamily: ManagerFontFamily.fontFamily,
        color: Colors.grey[500],
      ),
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: highlightGreen ? green : Colors.grey[600]),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        borderSide: BorderSide(
          color: highlightGreen ? green.withOpacity(0.8) : Colors.transparent,
          width: highlightGreen ? 1.4 : 0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        borderSide: BorderSide(
          color: highlightGreen ? green : green,
          width: 1.6,
        ),
      ),

      contentPadding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.02,
        horizontal: screenWidth * 0.05,
      ),
    );
  }

  void _showMissingDialog(List<String> missing) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFCE232B)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Missing required fields".tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Please fill the following fields:".tr,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              ...missing.map(
                    (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF07933E)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _focusFirstMissing(missing);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07933E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    "OK".tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    ).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusFirstMissing(missing);
      });
    });
  }

  List<String> _getMissingFields() {
    final missing = <String>[];

    if (name.text.trim().isEmpty) missing.add("Name");
    if (type.text.trim().isEmpty) missing.add("Type Of Event");
    if (hour.text.trim().isEmpty) missing.add("Hour");
    if (date.text.trim().isEmpty) missing.add("Date");

    return missing;
  }

  void _refreshMissingStateLive() {
    if (!mounted) return;

    final newState = <String, bool>{
      'Name': name.text.trim().isEmpty,
      'Type Of Event': type.text.trim().isEmpty,
      'Hour': hour.text.trim().isEmpty,
      'Date': date.text.trim().isEmpty,
    };

    bool changed = false;
    newState.forEach((k, v) {
      if (_missingState[k] != v) changed = true;
    });

    if (changed) {
      setState(() {
        _missingState
          ..clear()
          ..addAll(newState);
      });
    }
  }

  void _focusFirstMissing(List<String> missing) {
    if (!mounted) return;
    if (missing.isEmpty) return;

    final first = missing.first;

    setState(() {
      _missingState['Name'] = name.text.trim().isEmpty;
      _missingState['Type Of Event'] = type.text.trim().isEmpty;
      _missingState['Hour'] = hour.text.trim().isEmpty;
      _missingState['Date'] = date.text.trim().isEmpty;
    });

    if (first == "Name") {
      _ensureVisible(_nameKey);
      _nameFocus.requestFocus();
    } else if (first == "Type Of Event") {
      _ensureVisible(_typeKey);
      _typeFocus.requestFocus();
    } else if (first == "Hour") {
      _ensureVisible(_hourKey);
      _selectTime(context);
    } else if (first == "Date") {
      _ensureVisible(_dateKey);
      _selectDate(context);
    }
  }

  void _ensureVisible(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.25,
    );
  }

  void _onNextPressed() {
    final missing = _getMissingFields();
    if (missing.isNotEmpty) {
      setState(() {
        _missingState['Name'] = name.text.trim().isEmpty;
        _missingState['Type Of Event'] = type.text.trim().isEmpty;
        _missingState['Hour'] = hour.text.trim().isEmpty;
        _missingState['Date'] = date.text.trim().isEmpty;
      });

      _showMissingDialog(missing);
      return;
    }

    if (phone.text.trim().isEmpty) phone.text = "No Phone";
    if (nameofevent.text.trim().isEmpty) nameofevent.text = "No Name";

    final req = ReqModel(
      Name: name.text.trim(),
      Phone: phone.text.trim(),
      TypeOfEvent: type.text.trim(),
      OwnerOfEvent: nameofevent.text.trim(),
      Hour: hour.text.trim(),
      Date: date.text.trim(),
      Address: address.text.trim(),
      TypeOfBuilding: "",
      Float: "",
    );

    Get.to(
          () => CompeleteReqView(req, _fullCatalog),
      transition: Transition.rightToLeft,
      duration: const Duration(seconds: 1),
    );
  }

  Widget _label(String text, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        text.tr,
        style: TextStyle(
          fontFamily: ManagerFontFamily.fontFamily,
          fontSize: screenWidth * 0.032,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        controller: _scrollCtrl,
        padding: EdgeInsets.only(bottom: screenHeight * 0.03),
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.24,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07933E), Color(0xFF007530)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(44),
                  bottomRight: Radius.circular(44),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: screenWidth * 0.08,
                    bottom: screenHeight * 0.05,
                    right: screenWidth * 0.08,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Request'.tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: screenWidth * 0.075,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Fill event details to continue'.tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: screenWidth * 0.035,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Details'.tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please fill in the information below'.tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.045),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Name *", screenWidth),
                        TextFormField(
                          key: _nameKey,
                          focusNode: _nameFocus,
                          controller: name,
                          keyboardType: TextInputType.name,
                          decoration: _deco(
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            hint: "Enter your name",
                            icon: Icons.person_outline,
                            highlightGreen: _missingState['Name'] == true,
                          ),
                          style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                        ),

                        _label("Phone Number", screenWidth),
                        TextFormField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          decoration: _deco(
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            hint: "Enter phone number",
                            icon: Icons.phone_outlined,
                          ),
                          style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                        ),

                        _label("Owner Of Event", screenWidth),
                        TextFormField(
                          controller: nameofevent,
                          keyboardType: TextInputType.name,
                          decoration: _deco(
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            hint: "Enter owner name",
                            icon: Icons.badge_outlined,
                          ),
                          style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                        ),

                        _label("Type Of Event *", screenWidth),
                        TextFormField(
                          key: _typeKey,
                          focusNode: _typeFocus,
                          controller: type,
                          keyboardType: TextInputType.text,
                          decoration: _deco(
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            hint: "Enter type of event",
                            icon: Icons.category_outlined,
                            highlightGreen: _missingState['Type Of Event'] == true,
                          ),
                          style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                        ),

                        _label("Hour *", screenWidth),
                        GestureDetector(
                          onTap: () => _selectTime(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              key: _hourKey,
                              controller: hour,
                              decoration: _deco(
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                hint: "Select Time",
                                icon: Icons.access_time,
                                suffix: const Icon(Icons.arrow_drop_down),
                                highlightGreen: _missingState['Hour'] == true,
                              ),
                              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                            ),
                          ),
                        ),

                        _label("Date *", screenWidth),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              key: _dateKey,
                              controller: date,
                              decoration: _deco(
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                hint: "Select Date",
                                icon: Icons.calendar_today_outlined,
                                suffix: const Icon(Icons.arrow_drop_down),
                                highlightGreen: _missingState['Date'] == true,
                              ),
                              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCE232B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        ),
                        elevation: 6,
                        shadowColor: const Color(0xFFCE232B).withOpacity(0.35),
                      ),
                      child: Text(
                        'Next'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: screenWidth * 0.048,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
