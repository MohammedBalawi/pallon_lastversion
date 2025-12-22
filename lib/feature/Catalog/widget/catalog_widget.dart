import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Utils/manager_fonts.dart';
import '../../../Core/Widgets/custom_item_card.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/user_model.dart';
import '../../MainScreen/function/main_function.dart';
import '../Funcation/catalog_function.dart';
import '../view/create_catalog_view.dart';
import 'catalog_stream_widget.dart';

class CatalogWidget extends StatefulWidget {
  const CatalogWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CatalogWidget();
  }
}

class _CatalogWidget extends State<CatalogWidget> {
  List<CatalogItemModel> _allItem = [];
  List<CatalogItemModel> _searchItem = [];
  bool get _isSearching => _searchItem.isNotEmpty || _name.text.isNotEmpty;

  final TextEditingController _name = TextEditingController();
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
    getItemsSearch();
    _getUserType();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _getUserType() async {
    if (_auth.currentUser != null) {
      final data = await GetUserData(_auth.currentUser!.uid);
      setState(() {
        userModel = data!;
      });
    }
  }

  Future<void> getItemsSearch() async {
    final List<CatalogItemModel> item = await GetAllItems(context);
    setState(() {
      _allItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: screenWidth * 0.06,
              right: screenWidth * 0.06,
              top: screenHeight * 0.06,
              bottom: screenHeight * 0.03,
            ),
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
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catalog'.tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,

                      fontSize: screenWidth * 0.085,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  Text(
                    'Search in all items'.tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,

                      color: Colors.white.withOpacity(0.85),
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  Material(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    borderRadius: BorderRadius.circular(30),
                    child: TextFormField(
                      controller: _name,

                      style:  TextStyle(color: Colors.black87,  fontFamily: ManagerFontFamily.fontFamily,),
                      decoration: InputDecoration(
                        hintText: 'Search Item'.tr,
                        hintStyle: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,

                          color: Colors.grey[500],
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: _name.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _name.clear();
                              _searchItem.clear();
                            });
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.014,
                          horizontal: screenWidth * 0.04,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      cursorColor: const Color(0xFF07933E),
                      onChanged: (value) {
                        final query = value.trim();
                        if (query.isEmpty) {
                          setState(() {
                            _searchItem.clear();
                          });
                        } else {
                          setState(() {
                            _searchItem = SearchItem(_allItem, query);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _isSearching
                  ? GradSearch(_searchItem)
                  : CatalogStreamWidget(userModel),
            ),
          ),
        ],
      ),

      floatingActionButton: userModel.type == "Admin"
          ? FloatingActionButton(
        onPressed: () {
          Get.bottomSheet(
            CreateCatalogView(),
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
            ),
            backgroundColor: Colors.white,
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      )
          : null,
    );
  }

  Widget GradSearch(List<CatalogItemModel> items) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No items found'.tr,
          style:  TextStyle(
            fontFamily: ManagerFontFamily.fontFamily,

            color: Colors.black54,
            fontSize: 16,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: screenHeight * 0.015),
        itemBuilder: (context, index) {
          return CustomItemCard(items[index]);
        },
      ),
    );
  }
}
