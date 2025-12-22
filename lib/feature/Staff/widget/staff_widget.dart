import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/app.images.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';
import '../../../models/user_model.dart';
import '../../AddRequest/view/add_req_view.dart';
import '../../Calender/view/calender_view.dart';
import '../../Chat/view/chat_view.dart';
import '../../Home/view/home_view.dart';
import '../../MainScreen/function/main_function.dart';
import '../../Profile/view/profile_view.dart';

class StaffWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StaffWidget();
  }
}

class _StaffWidget extends State<StaffWidget> {
  UserModel userModel = UserModel(
      doc: "doc",
      email: "email",
      phone: "phone",
      name: "name",
      pic: "pic",
      type: "type");

  FirebaseAuth _auth = FirebaseAuth.instance;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    GetUserType();
  }

  void GetUserType() async {
    UserModel? user = await GetUserData(_auth.currentUser!.uid);
    setState(() {
      userModel = user!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeView(),
      ChatView(),
      AddReqView(),
      CalenderView(),
      Profileview(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,

        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        elevation: 10,

        selectedItemColor: const Color(0xFF07933E),

        unselectedItemColor: Colors.grey.shade400,

        selectedLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF07933E),
          fontFamily: ManagerFontFamily.fontFamily,

        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontFamily: ManagerFontFamily.fontFamily,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade400,
        ),

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppImages.iconHome,
              color: currentIndex == 0 ? Color(0xFF07933E) : Colors.grey,
            ),
            label: 'Home'.tr,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
             AppImages.chat,
              height: 30,
              color: currentIndex == 1 ? Color(0xFF07933E) : Colors.grey,
            ),
            label: 'Message'.tr,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppImages.plusCircle,
              height: 30,
              color: currentIndex == 2 ? Color(0xFF07933E) : Colors.grey,
            ),
            label: 'Add'.tr,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppImages.timer,
              height: 25,
              color: currentIndex == 3 ? Color(0xFF07933E) : Colors.grey,
            ),
            label: 'Calendar'.tr,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppImages.profileIcon,
              color: currentIndex == 4 ? Color(0xFF07933E) : Colors.grey,
            ),
            label: 'Profile'.tr,
          ),
        ],
      ),
    );
  }
}
