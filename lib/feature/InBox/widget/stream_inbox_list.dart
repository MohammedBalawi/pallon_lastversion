import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

import '../../../models/inbox_model.dart';
import '../../../models/user_model.dart';
import '../function/inbox_function.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Widget StreamInBoxList(BuildContext context, UserModel user) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth  = MediaQuery.of(context).size.width;

  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('inbox').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(
            backgroundColor: Color(0xFF07933E),
          ),
        );
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Text(
            'No InBox found.'.tr,
            style: TextStyle(
              fontFamily: ManagerFontFamily.fontFamily,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        );
      }

      List<InBoxModel> list = [];
      final messages = snapshot.data!.docs;

      for (var message in messages.reversed) {
        list.add(
          InBoxModel(
            doc: message.id,
            title: message.get('title'),
            body: message.get('body'),
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.only(
          left: screenWidth * 0.04,
          right: screenWidth * 0.04,
          bottom: screenHeight * 0.02,
        ),
        itemCount: list.length,
        separatorBuilder: (_, __) => SizedBox(height: screenHeight * 0.01),
        itemBuilder: (context, index) {
          final item = list[index];

          return Card(
            color: Colors.white,
            elevation: 3,
            shadowColor: Colors.black.withOpacity(0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.016,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: screenHeight * 0.08,
                    decoration: BoxDecoration(
                      color: const Color(0xFF07933E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.035),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,

                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          item.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,

                            fontSize: screenWidth * 0.036,
                            height: 1.4,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (user.type == "Admin") ...[
                    SizedBox(width: screenWidth * 0.02),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        _showDeleteDialog(context, item);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: Color(0xFFCE232B),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showDeleteDialog(BuildContext context, InBoxModel inbox) {
  showDialog(
    context: context,
    builder: (ctx) {
      final screenWidth = MediaQuery.of(ctx).size.width;

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFCE232B),
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                'Delete InBox?'.tr,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete this message?'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,

                  fontSize: screenWidth * 0.037,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF07933E),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Cancel'.tr,
                        style:  TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,

                          color: Color(0xFF07933E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        DeleteInBox(context, inbox);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCE232B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        'Delete'.tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,

                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
