import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/req_data_model.dart';
import '../../Requset/Widget/req_details_widget.dart';

class ClientReqCard extends StatefulWidget {
  final ReqDataModel req;
  const ClientReqCard(this.req, {super.key});

  @override
  State<ClientReqCard> createState() => _ClientReqCard();
}

class _ClientReqCard extends State<ClientReqCard> {
  double progress = 0;

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().trim()) ?? 0.0;
  }

  double _safeProgress(dynamic deposit, dynamic total) {
    final d = _toDouble(deposit);
    final t = _toDouble(total);

    if (t <= 0) return 0.0;

    final p = d / t;
    if (p.isNaN || p.isInfinite) return 0.0;

    return p.clamp(0.0, 1.0);
  }

  String _safeText(dynamic v, {String fallback = ""}) {
    if (v == null) return fallback;
    final s = v.toString();
    return s.isEmpty ? fallback : s;
  }

  @override
  void initState() {
    super.initState();
    progress = _safeProgress(widget.req.deposite, widget.req.total);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final double percentDouble = progress * 100;
    final int percent =
    (percentDouble.isNaN || percentDouble.isInfinite) ? 0 : percentDouble.round();

    return InkWell(
      onTap: () {
        Get.to(
              () => ReqDetailsWidget(widget.req),
          transition: Transition.zoom,
          duration: const Duration(seconds: 1),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenWidth * 0.02,
              height: screenHeight * 0.15,
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _safeText(widget.req.typeOfEvent, fallback: "-"),
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      'For - ${_safeText(widget.req.ownerOfevent, fallback: "-")}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Status - ${_safeText(widget.req.status, fallback: "-")}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due date',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          _safeText(widget.req.date, fallback: "-"),
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.02,
                right: screenWidth * 0.05,
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey[200],
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
