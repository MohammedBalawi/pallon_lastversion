import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/feature/Client/widget/stream_banners.dart';
import 'package:pallon_lastversion/feature/Client/widget/stream_client_req.dart';
import '../../../Core/Widgets/custom_item_card.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/user_model.dart';
import '../../Catalog/Funcation/catalog_function.dart';
import '../../Catalog/view/catalog_view.dart';
import '../../InBox/view/inbox_view.dart';
import '../../MainScreen/function/main_function.dart';
import '../view/client_req_view.dart';

class ClientHomeWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _ClientHomeWidget();
  }

}

class _ClientHomeWidget extends State<ClientHomeWidget>{
  List<CatalogItemModel> _allItem=[];
  final FirebaseAuth _auth=FirebaseAuth.instance;
  UserModel userModel=UserModel(doc: "doc", email: "email", phone: "phone", name: "name", pic: "pic", type: "type");
  @override
  void initState() {
    super.initState();
    GetUserType();
    getItemsSearch();
  }
  void GetUserType()async{
    userModel =(await GetUserData(_auth.currentUser!.uid))!;
    setState(() {
      userModel;
    });
  }
  void getItemsSearch()async{
    List<CatalogItemModel> item=await GetAllItems(context);
    setState(() {
      _allItem=item;
    });
    print(_allItem.length);
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,'.tr,
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            userModel.name == "name" || userModel.name.isEmpty
                                ? userModel.email
                                : userModel.name,
                            style: TextStyle(
                              fontSize: screenWidth * 0.065,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: screenWidth * 0.06,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.notifications,
                              color: const Color(0xFF07933E),
                              size: screenWidth * 0.06,
                            ),
                          ),
                          SizedBox(width: 5,),
                          CircleAvatar(
                            radius: screenWidth * 0.06,
                            backgroundColor: Colors.white,
                            child: IconButton(onPressed: (){
                              Get.to(InBoxView(userModel),duration: Duration(seconds: 1),transition: Transition.fadeIn);
                            },
                                icon: Icon(
                                  Icons.inbox,
                                  color: const Color(0xFF07933E),
                                  size: screenWidth * 0.06,
                                ),)
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight*0.02),
            StreamBanner(context),
            SizedBox(height: screenHeight*0.02,),
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.08,
                  right: screenWidth * 0.08,
                  top: screenHeight * 0.02,
                  bottom: screenHeight * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Catalog Items'.tr,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      Get.to(CatalogView(),duration: Duration(seconds: 1),transition: Transition.cupertino);
                    },
                    child: Text(
                      'Show All'.tr,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight*0.67,
              child: GradSearch(_allItem,context),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.08,
                  right: screenWidth * 0.08,
                  top: screenHeight * 0.02,
                  bottom: screenHeight * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Requests'.tr,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      Get.to(ClientReqView(),duration: Duration(seconds: 1),transition: Transition.cupertino);
                    },
                    child: Text(
                      'Show All'.tr,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color:  Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight*0.5,
              child: StreamClientReq(context,false),
            ),
            SizedBox(height: screenHeight*0.04,),
          ],
        ),
      ),
    );
  }
  Widget GradSearch(List<CatalogItemModel> items,BuildContext context){
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return  Padding(
      padding: const EdgeInsets.all(18.0),
      child: GridView.builder(
          itemCount: items.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: screenWidth * 0.03,
            mainAxisSpacing: screenHeight * 0.02,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index){
            return InkWell(
              child: CustomItemCard(items[index]),
              onTap: (){
                // Get.to(ItemDetailsCatalogView(widget.cat,widget.sub,widget.sub.items[index]),duration: Duration(seconds: 1),
                //     transition: Transition.fadeIn);
              },
            );
          }
      ),
    );
  }
}
