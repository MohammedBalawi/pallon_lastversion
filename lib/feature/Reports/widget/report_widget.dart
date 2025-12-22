import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/feature/Reports/widget/store_report_widget.dart';
import 'package:pallon_lastversion/feature/Reports/widget/user_report_widget.dart';
import 'order_report_widget.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

class ReportWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReportWidget();
  }
}

class _ReportWidget extends State<ReportWidget> {
  final List<String> _reportfillter = ["Order", "The Store", "User"];
  final List<String> _reportorder = [
    "All",
    "Compelete",
    "InReview",
    "Progress",
    "Accept",
    "Reject"
  ];
  final List<String> _reportuser = [
    "All",
    "Admin",
    "Client",
    "Vendor",
    "Driver",
    "Designer",
    "Coordinator"
  ];

  int _selectreport = 0;
  int _select_order = 0;
  int _select_user = 0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                  colors: [
                    Color(0xFF07933E),
                    Color(0xFF007530),
                  ],
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
                          Text(
                            'Report'.tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            'View and export app reports'.tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontSize: screenWidth * 0.035,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(13.0),
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.08,
                    child: _FillterReportWidget(context),
                  ),

                  if (_selectreport == 0) ...[
                    SizedBox(
                      height: screenHeight * 0.08,
                      child: _FillterOrderWidget(context),
                    ),
                  ],

                  if (_selectreport == 1) ...[
                    SizedBox(height: screenHeight * 0.01),
                    StoreReport(context),
                  ],

                  if (_selectreport == 0) ...[
                    SizedBox(height: screenHeight * 0.01),
                    OrderReportWidget(context, _reportorder[_select_order]),
                  ],

                  if (_selectreport == 2) ...[
                    SizedBox(
                      height: screenHeight * 0.08,
                      child: _FillterUserWidget(context),
                    ),
                  ],

                  if (_selectreport == 2) ...[
                    SizedBox(height: screenHeight * 0.01),
                    UserReportWidget(context, _reportuser[_select_user]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _FillterReportWidget(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _reportfillter.length,
      itemBuilder: (context, index) {
        final bool isSelected = _selectreport == index;

        return InkWell(
          onTap: () {
            setState(() {
              _selectreport = index;
            });
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF07933E) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF07933E)
                      : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: const Color(0xFF07933E).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _reportfillter[index].tr,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF222222),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _FillterOrderWidget(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _reportorder.length,
      itemBuilder: (context, index) {
        final bool isSelected = _select_order == index;

        return InkWell(
          onTap: () {
            setState(() {
              _select_order = index;
            });
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF07933E) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF07933E)
                      : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: const Color(0xFF07933E).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _reportorder[index].tr,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  fontSize: screenWidth * 0.033,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF222222),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _FillterUserWidget(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _reportuser.length,
      itemBuilder: (context, index) {
        final bool isSelected = _select_user == index;

        return InkWell(
          onTap: () {
            setState(() {
              _select_user = index;
            });
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF07933E) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF07933E)
                      : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: const Color(0xFF07933E).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _reportuser[index].tr,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  fontSize: screenWidth * 0.033,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF222222),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        );
      },
    );
  }
}
