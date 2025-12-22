import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pallon_lastversion/Core/Utils/app.images.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';
import 'package:pallon_lastversion/feature/Reports/view/report_view.dart';
import 'package:pallon_lastversion/feature/offers/view/offer_view.dart';

import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/task_model.dart';
import '../../../models/user_model.dart';
import '../../AddStaff/view/add_staff_view.dart';
import '../../Banners/view/banner_view.dart';
import '../../Catalog/view/catalog_view.dart';
import '../../Client/view/client_main_view.dart';
import '../../InBox/view/inbox_view.dart';
import '../../Notification/view/notification_view.dart';
import '../../Orders/view/order_view.dart';
import '../../Requset/view/req_list_view.dart';
import '../../Tasks/funcation/task_function.dart';
import '../../Tasks/view/task_view.dart';
import '../../Tasks/widget/task_card.dart';
import '../../MainScreen/function/main_function.dart';

class DateItem {
  final DateTime date;
  final String dayAbbreviation;
  final int dayOfMonth;

  DateItem({
    required this.date,
    required this.dayAbbreviation,
    required this.dayOfMonth,
  });
}

class HomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeWidget();
}

class _HomeWidget extends State<HomeWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _dateScrollCtrl = ScrollController();
  int _dateStartIndex = 0;
  static const int _visibleDays = 7;

  UserModel userModel = UserModel(
    doc: "doc",
    email: "email",
    phone: "phone",
    name: "name",
    pic: "pic",
    type: "type",
  );

  late List<DateItem> _dateList;
  late DateTime _selectedDate;

  List<TaskModel> tasks = [];
  int _countReq = 0;

  StreamSubscription<QuerySnapshot>? _reqSub;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _listenReqCount();
    _getUserTypeAndLoadTasks();
  }

  @override
  void dispose() {
    _reqSub?.cancel();
    super.dispose();
  }

  void _initializeDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _selectedDate = today;

    _dateStartIndex = 0;

    _dateList = List.generate(30, (index) {
      final date = today.add(Duration(days: index));
      return DateItem(
        date: date,
        dayAbbreviation: DateFormat('EEE').format(date).toUpperCase(),
        dayOfMonth: date.day,
      );
    });
  }
  void _goToToday() {
    if (_dateList.isEmpty) return;

    setState(() {
      _dateStartIndex = 0;
      _selectedDate = _dateList.first.date;
    });

    _dateScrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _loadTasksForDate(_dateList.first.date);
  }


  void _listenReqCount() {
    try {
      _reqSub = _firestore
          .collection('req')
          .where('status', isEqualTo: 'inreview')
          .snapshots()
          .listen((snap) {
        if (!mounted) return;
        setState(() {
          _countReq = snap.size;
        });
      });
    } catch (e) {
    }
  }

  Future<void> _getUserTypeAndLoadTasks() async {
    try {
      if (_auth.currentUser == null) {
        return;
      }

      UserModel? user = await GetUserData(_auth.currentUser!.uid);
      if (!mounted) return;

      if (user != null) {
        setState(() {
          userModel = user;
        });
      }

      await _loadTasksForDate(_selectedDate);
    } catch (e) {
    }
  }

  Future<void> _loadTasksForDate(DateTime date) async {
    try {
      final DateTime normalized = DateTime(date.year, date.month, date.day);

      List<TaskModel> loaded;
      if (userModel.type == "Admin") {
        loaded = await GetAdminTask(normalized, context);
      } else {
        loaded = await GetUserTaskDate(normalized, context);
      }

      if (!mounted) return;
      setState(() {
        _selectedDate = normalized;
        tasks = loaded;
      });
    } catch (e) {
    }
  }

  void _shiftDatesForward() {
    if (_dateList.isEmpty) return;

    final maxStart = (_dateList.length - _visibleDays);
    if (maxStart <= 0) return;

    setState(() {
      _dateStartIndex = (_dateStartIndex + 1).clamp(0, maxStart);
    });

    _dateScrollCtrl.animateTo(
      _dateStartIndex * 90.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _shiftDatesBack() {
    if (_dateList.isEmpty) return;

    final maxStart = (_dateList.length - _visibleDays);
    if (maxStart <= 0) return;

    setState(() {
      _dateStartIndex = (_dateStartIndex - 1).clamp(0, maxStart);
    });

    _dateScrollCtrl.animateTo(
      _dateStartIndex * 90.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _selectDate(DateTime date) async {
    await _loadTasksForDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    List<Widget> adminAccess = [
      Stack(
        children: [
          InkWell(
            child: buildProjectCard(
              context,
              title: 'Perview'.tr,
              status: 'Perview'.tr,
              statusColor: const Color(0xFF07933E),
            ),
            onTap: () {
              Get.to(
                    () => ClientMainView(),
                transition: Transition.topLevel,
                duration: const Duration(seconds: 1),
              );
            },
          ),
          InkWell(
            onTap: () {
              Get.to(
                    () => ReqViewList(),
                transition: Transition.downToUp,
                duration: const Duration(seconds: 1),
              );
            },
            child: buildProjectCard(
              context,
              title: 'Requset List'.tr,
              status: 'View List'.tr,
              statusColor: const Color(0xFF07933E),
            ),
          ),
          _countReq == 0
              ? const SizedBox.shrink()
              : Positioned(
            top: 6,
            right: 6,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(
                _countReq.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      InkWell(
        child: buildProjectCard(
          context,
          title: 'Staff'.tr,
          status: 'View Staff'.tr,
          statusColor: const Color(0xFF07933E),
        ),
        onTap: () {
          Get.to(
                () => AddStaffView(),
            transition: Transition.topLevel,
            duration: const Duration(seconds: 1),
          );
        },
      ),
      InkWell(
        child: buildProjectCard(
          context,
          title: 'Catalog'.tr,
          status: 'Show Catalog'.tr,
          statusColor: const Color(0xFFCE232B),
        ),
        onTap: () {
          Get.to(
                () => CatalogView(),
            transition: Transition.topLevel,
            duration: const Duration(seconds: 1),
          );
        },
      ),
      InkWell(
        onTap: () {
          Get.to(
                () => OrderView(),
            duration: const Duration(seconds: 1),
            transition: Transition.fadeIn,
          );
        },
        child: buildProjectCard(
          context,
          title: 'Order'.tr,
          status: 'On-hold'.tr,
          statusColor: const Color(0xFFCE232B),
        ),
      ),
      InkWell(
        child: buildProjectCard(
          context,
          title: 'Banners'.tr,
          status: 'Show Banners'.tr,
          statusColor: const Color(0xFF07933E),
        ),
        onTap: () {
          Get.to(
                () => BannerView(),
            transition: Transition.topLevel,
            duration: const Duration(seconds: 1),
          );
        },
      ),
      InkWell(
        child: buildProjectCard(
          context,
          title: 'Reports'.tr,
          status: 'Show Reports'.tr,
          statusColor: const Color(0xFF07933E),
        ),
        onTap: () {
          Get.to(
                () => ReportView(),
            transition: Transition.topLevel,
            duration: const Duration(seconds: 1),
          );
        },
      ),
      InkWell(
        child: buildProjectCard(
          context,
          title: 'InBox'.tr,
          status: 'Show InBox Mail'.tr,
          statusColor: const Color(0xFF07933E),
        ),
        onTap: () {
          Get.to(
                () => InBoxView(userModel),
            transition: Transition.topLevel,
            duration: const Duration(seconds: 1),
          );
        },
      ),
      InkWell(
        child: buildProjectCard(
          context,
          title: 'Offers'.tr,
          status: 'Create Offer'.tr,
          statusColor: const Color(0xFF07933E),
        ),
        onTap: () {
          Get.to(
                () => OfferView(),
            transition: Transition.topLevel,
            duration: const Duration(seconds: 1),
          );
        },
      ),
    ];

    List<Widget> staffAccess = [
      InkWell(
        child: buildProjectCard(
          context,
          title: 'Catalog'.tr,
          status: 'Show Catalog'.tr,
          statusColor: const Color(0xFFCE232B),
        ),
        onTap: () {
          Get.to(
                () => CatalogView(),
            transition: Transition.topLevel,
            duration: const Duration(seconds: 1),
          );
        },
      ),
      InkWell(
        child: buildProjectCard(
          context,
          title: 'Banners'.tr,
          status: 'Show Banners'.tr,
          statusColor: const Color(0xFF07933E),
        ),
        onTap: () {
          Get.to(
                () => BannerView(),
            transition: Transition.topLevel,
            duration: const Duration(seconds: 1),
          );
        },
      ),
      InkWell(
        child: buildProjectCard(
          context,
          title: 'Reports'.tr,
          status: 'Show Reports'.tr,
          statusColor: const Color(0xFF07933E),
        ),
        onTap: () {
          Get.to(
                () => ReportView(),
            transition: Transition.topLevel,
            duration: const Duration(seconds: 1),
          );
        },
      ),
      InkWell(
        child: buildProjectCard(
          context,
          title: 'InBox'.tr,
          status: 'Show InBox Mail'.tr,
          statusColor: const Color(0xFF07933E),
        ),
        onTap: () {
          Get.to(
                () => InBoxView(userModel),
            transition: Transition.topLevel,
            duration: const Duration(seconds: 1),
          );
        },
      ),
      InkWell(
        child: buildProjectCard(
          context,
          title: 'Offers'.tr,
          status: 'Create Offer'.tr,
          statusColor: const Color(0xFF07933E),
        ),
        onTap: () {
          Get.to(
                () => OfferView(),
            transition: Transition.topLevel,
            duration: const Duration(seconds: 1),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: screenHeight * 0.25,
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
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Good Morning'.tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontSize: screenWidth * 0.06,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            (userModel.name == "name" || userModel.name == "")
                                ? userModel.email
                                : userModel.name,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontSize: screenWidth * 0.045,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: SvgPicture.asset(
                          AppImages.notification,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Get.to(
                                () => NotificationView(),
                            duration: const Duration(seconds: 1),
                            transition: Transition.fadeIn,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.02,
              ),
              child: Text(
                'Select date'.tr,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF000000),
                ),
              ),
            ),

            SizedBox(
              height: screenHeight * 0.12,
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goToToday,
                    icon:SvgPicture.asset(AppImages.arrows),
                    tooltip: "Today",
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: _dateScrollCtrl,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      itemCount: _dateList.length,
                      itemBuilder: (context, index) {
                        final item = _dateList[index];
                        final isSelected = item.date.isAtSameMomentAs(_selectedDate);

                        return InkWell(
                          onTap: () => _selectDate(item.date),
                          child: Container(
                            width: screenWidth * 0.18,
                            margin: EdgeInsets.only(right: screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF07933E) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.dayAbbreviation.tr,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  '${item.dayOfMonth}',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),



            Padding(
              padding: const EdgeInsets.only(top: 15, left: 35, right: 15),
              child: Text(
                'Access'.tr,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF000000),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: screenWidth * 0.05,
                crossAxisSpacing: screenWidth * 0.05,
                childAspectRatio: 1.2,
                children: userModel.type == "Admin" ? adminAccess : staffAccess,
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ongoing task for ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(
                            () => TaskView(),
                        duration: const Duration(seconds: 1),
                        transition: Transition.cupertinoDialog,
                      );
                    },
                    child: Text(
                      'Show All tasks'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.03,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            tasks.isNotEmpty
                ? ListView.builder(
              itemCount: tasks.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return TaskCard(tasks[index]);
              },
            )

                : Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  "You Don't Have Any Task".tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF000000),
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}
