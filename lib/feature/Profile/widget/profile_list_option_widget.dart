import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pallon_lastversion/feature/Profile/widget/update_password_widget.dart';
import 'package:pallon_lastversion/feature/language/view/language_view.dart';
import 'package:pallon_lastversion/feature/privacy%20policy/view/privacy_policy_view.dart';
import 'package:pallon_lastversion/feature/terms%20of%20use/view/terms_of_use_view.dart';

import '../../../models/user_model.dart';
import '../../AddStaff/view/add_staff_view.dart';
import '../../items/view/item_view.dart';
import '../function/profile_function.dart';
import 'custome_optione_tile.dart';
import 'update_profile_widget.dart';

List<Widget> CustomListOptions(BuildContext context, UserModel user) {
  final screenHeight = MediaQuery.of(context).size.height;

  List<Widget> admin = [
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Update Profile'.tr,
      Icons.person_outline,
          () => Get.to(
            () => UpdateProfileWidget(user),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    buildOptionTile(
      context,
      'Update Password'.tr,
      Icons.password,
          () => Get.to(
            () =>  UpdatePassword(),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Add New Staff'.tr,
      Icons.person_add_alt,
          () => Get.to(
            () =>  AddStaffView(),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Items'.tr,
      Icons.storefront_sharp,
          () => Get.to(
            () =>  ItemView(),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Language'.tr,
      Icons.language,
          () => Get.bottomSheet(
         LanguageView(),
        isScrollControlled: true,
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Terms of Use'.tr,
      Icons.description_outlined,
          () => Get.to(
            () =>  TermOfUseView(),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Privacy Policy'.tr,
      Icons.privacy_tip_outlined,
          () => Get.to(
            () =>  PrivacyPolicyView(),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Remove Account'.tr,
      Icons.remove_circle_outline,
          () => confirmRemoveAccountDialog(context),

    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Logout'.tr,
      Icons.logout_outlined,
          () => logout(context),
    ),
  ];

  List<Widget> client = [
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Update Profile'.tr,
      Icons.person_outline,
          () => Get.to(
            () => UpdateProfileWidget(user),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Update Password'.tr,
      Icons.password,
          () => Get.to(
            () =>  UpdatePassword(),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Language'.tr,
      Icons.language,
          () => Get.bottomSheet(
         LanguageView(),
        isScrollControlled: true,
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Terms of Use'.tr,
      Icons.description_outlined,
          () => Get.to(
            () =>  TermOfUseView(),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Privacy Policy'.tr,
      Icons.privacy_tip_outlined,
          () => Get.to(
            () =>  PrivacyPolicyView(),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Logout'.tr,
      Icons.logout_outlined,
          () => logout(context),
    ),
  ];

  List<Widget> staff = [
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Update Profile'.tr,
      Icons.person_outline,
          () => Get.to(
            () => UpdateProfileWidget(user),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Update Password'.tr,
      Icons.password,
          () => Get.to(
            () =>  UpdatePassword(),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Language'.tr,
      Icons.language,
          () => Get.bottomSheet(
         LanguageView(),
        isScrollControlled: true,
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Terms of Use'.tr,
      Icons.description_outlined,
          () => Get.to(
            () =>  TermOfUseView(),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Privacy Policy'.tr,
      Icons.privacy_tip_outlined,
          () => Get.to(
            () =>  PrivacyPolicyView(),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 400),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    buildOptionTile(
      context,
      'Logout'.tr,
      Icons.logout_outlined,
          () => logout(context),
    ),
  ];

  return user.type == "Admin"
      ? admin
      : user.type == "staff"
      ? staff
      : client;
}
