import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';
import '../../../models/user_model.dart';
import '../../MainScreen/function/main_function.dart';
import '../widget/profile_list_option_widget.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileWidget();
}

class _ProfileWidget extends State<ProfileWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel userModel = UserModel(
    doc: "doc",
    email: "email",
    phone: "phone",
    name: "name",
    pic: "pic",
    type: "type",
  );

  @override
  void initState() {
    super.initState();
    GetUserType();
  }

  void GetUserType() async {
    userModel = (await GetUserData(_auth.currentUser!.uid))!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.38,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: screenHeight * 0.28,
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
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Profile'.tr,
                              style: TextStyle(
                                fontFamily: ManagerFontFamily.fontFamily,
                                fontSize: screenWidth * 0.065,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Account Details'.tr,
                              style: TextStyle(
                                fontFamily: ManagerFontFamily.fontFamily,
                                fontSize: screenWidth * 0.035,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),

                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: -screenHeight * 0.09,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: screenWidth * 0.145,
                                backgroundColor:
                                const Color(0xFFE8F5E9),
                                child: CircleAvatar(
                                  radius: screenWidth * 0.13,
                                  backgroundColor: Colors.white,
                                  child: (userModel.pic == "" ||
                                      userModel.pic == "pic")
                                      ? Icon(
                                    Icons.person,
                                    size: screenWidth * 0.13,
                                    color: Colors.grey[300],
                                  )
                                      : ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: userModel.pic,
                                      width: screenWidth * 0.26,
                                      height: screenWidth * 0.26,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF07933E),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      const Color(0xFF07933E).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Name
                          Text(
                            userModel.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Welcome".tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontSize: screenWidth * 0.036,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (userModel.email.isNotEmpty) ...[
                                Icon(
                                  Icons.email_outlined,
                                  size: 18,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    userModel.email,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: ManagerFontFamily.fontFamily,
                                      fontSize: screenWidth * 0.032,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                              if (userModel.type.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF07933E)
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_user_outlined,
                                        size: 16,
                                        color: const Color(0xFF07933E),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        userModel.type,
                                        style: TextStyle(
                                          fontFamily:
                                          ManagerFontFamily.fontFamily,
                                          fontSize: screenWidth * 0.032,
                                          color: const Color(0xFF07933E),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: Colors.white,
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Column(
                    children: CustomListOptions(context, userModel),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
