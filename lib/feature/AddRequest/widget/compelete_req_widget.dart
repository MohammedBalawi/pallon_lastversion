import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../../../Core/Widgets/image_view.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/catalog_model.dart';
import '../../../models/item_model.dart';
import '../../../models/req_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';
import '../../../models/user_model.dart';
import '../../Catalog/models/sub3_cat_model.dart';
import '../../MainScreen/function/main_function.dart';
import '../../items/function/item_action.dart';
import '../functions/req_function.dart';

class CompeleteReqWidget extends StatefulWidget {
  final ReqModel req;
  final List<Catalog> cat;

  CompeleteReqWidget(this.req, this.cat, {super.key});

  @override
  State<StatefulWidget> createState() => _CompeleteReqWidget();
}

class _CompeleteReqWidget extends State<CompeleteReqWidget> {
  final TextEditingController _qtyController = TextEditingController(text: "1");
  final TextEditingController _itemnote = TextEditingController();

  List<ItemModel> _ItesmModels = [];
  UserModel userModel = UserModel(
    doc: "doc",
    email: "email",
    phone: "phone",
    name: "name",
    pic: "pic",
    type: "type",
  );

  FirebaseAuth _auth = FirebaseAuth.instance;

  double _totlaprice = 0.0;
  bool _AddDesgin = false;
  bool _showModel = false;

  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  List<Catalog> _fullCatalog = [];
  Catalog? _selectedCatalog;
  SubCatModel? _selectedSubCat;
  SubSubCatModel? _selectedSubSubCat;
  Sub3CatModel? _selectedSub3;
  Sub4CatModel? _selectedSub4;
  CatalogItemModel? _selectedItem;

  final List<CatalogItemModel> _selectedItems = [];

  final List<ItemModel> _selectedItemsStore = [];
  ItemModel? _selectedItemStore;

  String? _paymentMethod;
  String? _paymentDetails;

  final List<String> paymentMethods = [
    "نقدي",
    "اجل",
    "تحويل بنكي",
    "شبكة",
    "stc pay",
    "تابي",
    "تمارا",
  ];

  final List<String> bankTransferOptions = [
    "تحويل بنكي لحساب الأهلي - فرع الروضه",
    "تحويل بنكي لحساب الأهلي - فرع البساتين",
    "تحويل بنكي إلى بنك الإنماء",
  ];

  final List<String> cardOptions = [
    "شبكة - مدى",
    "شبكة - فيزا او ماستر كارد",
  ];

  bool get _needsPaymentDetails =>
      _paymentMethod == "تحويل بنكي" || _paymentMethod == "شبكة";

  String? get _finalPaymentValue {
    if (_paymentMethod == null) return null;

    if (_needsPaymentDetails) {
      if (_paymentDetails == null || _paymentDetails!.isEmpty) return null;
      return _paymentDetails;
    }
    return _paymentMethod;
  }

  String? _selectBranch;

  final TextEditingController _countController = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final TextEditingController _deposit = TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();

  final List<String> branch = [
    "فرع الروضة",
    "فرع البساتين",
    "توصيل",
    "توصيل و تركيب",
    "شحن خارج جدة"
  ];

  List<String> _reportfillter = ['Catalog', "Store", "Manual"];

  final TextEditingController _manualName = TextEditingController();
  final TextEditingController _manualPrice = TextEditingController();
  final TextEditingController _manualNotes = TextEditingController();
  File? _manualImage;

  int _selectreport = 0;

  final TextEditingController _addressController = TextEditingController();
  TextEditingController typeofbuilding = TextEditingController();
  TextEditingController float = TextEditingController();

  @override
  void initState() {
    super.initState();
    GetUserType();
    GetStore();
    _loadCatalog();
    // _fullCatalog = widget.cat;
  }

  void GetUserType() async {
    userModel = (await GetUserData(_auth.currentUser!.uid))!;
    setState(() {});
  }

  //   void GetUserType() async {
//     userModel = (await GetUserData(_auth.currentUser!.uid))!;
//     setState(() {});
//   }

  void GetStore() async {
    _ItesmModels = await GetAllStore(context);
    setState(() {});
  }

  Future<void> _loadCatalog() async {
    final data = await GetFullCatalogTree();
    setState(() {
      _fullCatalog = data;
    });
  }

  Future<ImageSource?> _showPickSourceSheet() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCE232B).withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFFCE232B),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "اختر مصدر الصورة".tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF222222),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded,
                      color: Color(0xFF07933E)),
                  title: Text(
                    "كاميرا".tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => Get.back(result: ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded,
                      color: Color(0xFF07933E)),
                  title: Text(
                    "معرض الصور".tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => Get.back(result: ImageSource.gallery),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickManualImage() async {
    final source = await _showPickSourceSheet();
    if (source == null) return;

    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (file != null) {
      setState(() => _manualImage = File(file.path));
    }
  }

  Future<void> _pickImage() async {
    final source = await _showPickSourceSheet();
    if (source == null) return;

    if (source == ImageSource.gallery) {
      final List<XFile>? pickedFiles =
          await _picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() => _images.addAll(pickedFiles.map((x) => File(x.path))));
      }
    } else {
      final XFile? file =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (file != null) {
        setState(() => _images.add(File(file.path)));
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _addOrMergeItem(CatalogItemModel item, int qty) {
    final double itemPrice = double.tryParse(item.price) ?? 0.0;

    final existing = _selectedItems.firstWhereOrNull(
      (e) => e.name.trim().toLowerCase() == item.name.trim().toLowerCase(),
    );

    if (existing != null) {
      existing.count += qty;
      if (item.des.isNotEmpty) {
        if (existing.des.isEmpty) {
          existing.des = item.des;
        } else {
          existing.des = '${existing.des}\n${item.des}';
        }
      }
    } else {
      final newItem = CatalogItemModel(
        doc: item.doc,
        name: item.name,
        des: item.des,
        price: itemPrice.toStringAsFixed(2),
        path: item.path,
      );
      newItem.count = qty;
      _selectedItems.add(newItem);
    }

    _totlaprice += itemPrice * qty;

    _qtyController.text = "1";
    _itemnote.clear();
  }

  void _addItemToTable() {
    if (_selectedItem == null) return;

    final int qty = int.tryParse(_qtyController.text) ?? 1;

    final temp = CatalogItemModel(
      doc: _selectedItem!.doc,
      name: _selectedItem!.name,
      des: _itemnote.text,
      price: _selectedItem!.price,
      path: _selectedItem!.path,
    );

    _addOrMergeItem(temp, qty);

    setState(() {
      _selectedItem = null;
    });
  }

  TextFormField? _addressField() {
    if (_selectBranch == "توصيل" ||
        _selectBranch == "توصيل و تركيب" ||
        _selectBranch == "شحن خارج جدة") {
      return TextFormField(
        controller: _addressController,
        decoration: _dropdownDecoration("Address".tr),
        validator: (v) {
          if (v == null || v.isEmpty) {
            return "Address is required".tr;
          }
          return null;
        },
      );
    }
    return null;
  }

  TextFormField? _floatTextField() {
    if (_selectBranch == "توصيل" ||
        _selectBranch == "توصيل و تركيب" ||
        _selectBranch == "شحن خارج جدة") {
      return TextFormField(
        controller: float,
        decoration: _dropdownDecoration("Floor Number".tr),
        validator: (v) {
          if (v == null || v.isEmpty) {
            return "Floor number is required".tr;
          }
          return null;
        },
      );
    }
    return null;
  }

  TextFormField? _buildType() {
    if (_selectBranch == "توصيل" ||
        _selectBranch == "توصيل و تركيب" ||
        _selectBranch == "شحن خارج جدة") {
      return TextFormField(
        controller: typeofbuilding,
        decoration: _dropdownDecoration("Building Type".tr),
        validator: (v) {
          if (v == null || v.isEmpty) {
            return "Building type is required".tr;
          }
          return null;
        },
      );
    }
    return null;
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  DropdownStyleData _dropdownStyle(BuildContext context) {
    return DropdownStyleData(
      maxHeight: 300,
      width: MediaQuery.of(context).size.width * 0.9,
      elevation: 6,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      offset: const Offset(0, 8),
    );
  }

  Widget _buildCatalogCard() {
    final itemImg = (_selectedItem == null)
        ? null
        : _imageProviderSafe(_selectedItem!.path);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.category, color: Color(0xFF07933E)),
                const SizedBox(width: 8),
                Text(
                  "Select From Catalog".tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCatalogDropdown(),
            if (_selectedCatalog?.sub.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              _buildSubCatDropdown(),
            ],
            if (_selectedSubCat?.subsub.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              _buildSubSubCatDropdown(),
            ],
            if (_selectedSubSubCat?.sub3.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              _buildSub3Dropdown(),
            ],
            if (_selectedSub3?.sub4.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              _buildSub4Dropdown(),
            ],
            const SizedBox(height: 16),
            _buildItemDropdown(),
            const SizedBox(height: 16),
            if (_selectedItem != null) ...[
              Center(
                child: InkWell(
                  onTap: () {
                    final url = _selectedItem!.path.trim();
                    if (url.isEmpty) return;

                    Get.to(
                      () => ViewImage(url),
                      transition: Transition.zoom,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: itemImg,
                    child: itemImg == null
                        ? const Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 28)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "Price: ${_selectedItem!.price}",
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    decoration: _dropdownDecoration("Quantity".tr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                    controller: _itemnote,
                    decoration: InputDecoration(
                      labelText: 'Notes'.tr,
                      labelStyle:
                          TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addItemToTable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07933E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add Item'.tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.store, color: Color(0xFF07933E)),
                const SizedBox(width: 8),
                Text(
                  "Select From Store".tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStoreItemDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildManualCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, color: Color(0xFF07933E)),
                const SizedBox(width: 8),
                Text(
                  "Add Manual Item".tr,
                  style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildManualItemInputs(),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogDropdown() {
    final safeValue = _safeCatalogValue(_fullCatalog, _selectedCatalog);
    if (_fullCatalog.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: const Text("Loading catalog..."),
      );
    }
    return DropdownButtonFormField2<Catalog>(
      isExpanded: true,
      decoration: _dropdownDecoration("Select Catalog".tr),
      value: safeValue,
      items: _fullCatalog.map((cat) {
        final isLast = _fullCatalog.indexOf(cat) == _fullCatalog.length - 1;
        final img = _imageProviderSafe(cat.pic);

        return DropdownMenuItem<Catalog>(
          value: cat,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: img,
                    child: img == null
                        ? const Icon(Icons.image_not_supported,
                            size: 18, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cat.cat,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 6),
                Divider(height: 1, color: Colors.grey.shade200),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (Catalog? newValue) {
        setState(() {
          _selectedCatalog = newValue;
          _selectedSubCat = null;
          _selectedSubSubCat = null;
          _selectedSub3 = null;
          _selectedSub4 = null;
          _selectedItem = null;
        });
      },
      dropdownStyleData: _dropdownStyle(context),
      menuItemStyleData: const MenuItemStyleData(
        height: 64,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      selectedItemBuilder: (context) {
        return _fullCatalog.map((cat) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              cat.cat,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildSubCatDropdown() {
    final subs = _selectedCatalog?.sub ?? [];
    if (subs.isEmpty) return const SizedBox.shrink();

    final safeValue = _safeSubCatValue(subs, _selectedSubCat);

    return DropdownButtonFormField2<SubCatModel>(
      isExpanded: true,
      decoration: _dropdownDecoration("Select Sub-Category".tr),
      value: safeValue,
      items: subs.map((sub) {
        final isLast = subs.indexOf(sub) == subs.length - 1;
        final img = _imageProviderSafe(sub.pic);

        return DropdownMenuItem<SubCatModel>(
          value: sub,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: img,
                    child: img == null
                        ? const Icon(Icons.image_not_supported,
                            size: 18, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sub.sub,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 6),
                Divider(height: 1, color: Colors.grey.shade200),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (SubCatModel? v) {
        setState(() {
          _selectedSubCat = v;
          _selectedSubSubCat = null;
          _selectedSub3 = null;
          _selectedSub4 = null;
          _selectedItem = null;
        });
      },
      dropdownStyleData: _dropdownStyle(context),
      menuItemStyleData: const MenuItemStyleData(
        height: 64,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      selectedItemBuilder: (context) {
        return subs.map((sub) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              sub.sub,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildSubSubCatDropdown() {
    final subsubs = _selectedSubCat?.subsub ?? [];
    if (subsubs.isEmpty) return const SizedBox.shrink();

    final safeValue = _safeSubSubValue(subsubs, _selectedSubSubCat);

    return DropdownButtonFormField2<SubSubCatModel>(
      isExpanded: true,
      decoration: _dropdownDecoration("Select Sub-Sub-Category".tr),
      value: safeValue,
      items: subsubs.map((subsub) {
        final isLast = subsubs.indexOf(subsub) == subsubs.length - 1;
        final img = _imageProviderSafe(subsub.pic);

        return DropdownMenuItem<SubSubCatModel>(
          value: subsub,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: img,
                    child: img == null
                        ? const Icon(Icons.image_not_supported,
                            size: 18, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subsub.subsub,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 6),
                Divider(height: 1, color: Colors.grey.shade200),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (SubSubCatModel? v) {
        setState(() {
          _selectedSubSubCat = v;
          _selectedSub3 = null;
          _selectedSub4 = null;
          _selectedItem = null;
        });
      },
      dropdownStyleData: _dropdownStyle(context),
      menuItemStyleData: const MenuItemStyleData(
        height: 64,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      selectedItemBuilder: (context) {
        return subsubs.map((s) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              s.subsub,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildSub3Dropdown() {
    final list = _selectedSubSubCat?.sub3 ?? [];
    if (list.isEmpty) return const SizedBox.shrink();

    final safeValue = _safeSub3Value(list, _selectedSub3);

    return DropdownButtonFormField2<Sub3CatModel>(
      isExpanded: true,
      decoration: _dropdownDecoration("Select Sub3".tr),
      value: safeValue,
      items: list.map((s3) {
        final isLast = list.indexOf(s3) == list.length - 1;
        final img = _imageProviderSafe(s3.pic);

        return DropdownMenuItem<Sub3CatModel>(
          value: s3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: img,
                    child: img == null
                        ? const Icon(Icons.image_not_supported,
                            size: 18, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s3.name,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 6),
                Divider(height: 1, color: Colors.grey.shade200),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (Sub3CatModel? v) {
        setState(() {
          _selectedSub3 = v;
          _selectedSub4 = null;
          _selectedItem = null;
        });
      },
      dropdownStyleData: _dropdownStyle(context),
      menuItemStyleData: const MenuItemStyleData(
        height: 64,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      selectedItemBuilder: (context) {
        return list.map((s3) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              s3.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildSub4Dropdown() {
    final list = _selectedSub3?.sub4 ?? [];
    if (list.isEmpty) return const SizedBox.shrink();

    final safeValue = _safeSub4Value(list, _selectedSub4);

    return DropdownButtonFormField2<Sub4CatModel>(
      isExpanded: true,
      decoration: _dropdownDecoration("Select Sub4".tr),
      value: safeValue,
      items: list.map((s4) {
        final isLast = list.indexOf(s4) == list.length - 1;
        final img = _imageProviderSafe(s4.pic);

        return DropdownMenuItem<Sub4CatModel>(
          value: s4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: img,
                    child: img == null
                        ? const Icon(Icons.image_not_supported,
                            size: 18, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s4.name,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 6),
                Divider(height: 1, color: Colors.grey.shade200),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (Sub4CatModel? v) {
        setState(() {
          _selectedSub4 = v;
          _selectedItem = null;
        });
      },
      dropdownStyleData: _dropdownStyle(context),
      menuItemStyleData: const MenuItemStyleData(
        height: 64,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      selectedItemBuilder: (context) {
        return list.map((s4) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              s4.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildItemDropdown() {
    List<CatalogItemModel> availableItems = [];

    if (_selectedSub4 != null && _selectedSub4!.items.isNotEmpty) {
      availableItems = _selectedSub4!.items;
    } else if (_selectedSub3 != null && _selectedSub3!.items.isNotEmpty) {
      availableItems = _selectedSub3!.items;
    } else if (_selectedSubSubCat != null &&
        _selectedSubSubCat!.items.isNotEmpty) {
      availableItems = _selectedSubSubCat!.items;
    } else if (_selectedSubCat != null && _selectedSubCat!.items.isNotEmpty) {
      availableItems = _selectedSubCat!.items;
    }

    if (availableItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "No items in this section".tr,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final safeValue = _safeItemValue(availableItems, _selectedItem);

    return DropdownButtonFormField2<CatalogItemModel>(
      isExpanded: true,
      decoration: _dropdownDecoration("Select Item".tr),
      value: safeValue,
      items: availableItems.map((item) {
        final isLast =
            availableItems.indexOf(item) == availableItems.length - 1;
        final img = _imageProviderSafe(item.path);

        return DropdownMenuItem<CatalogItemModel>(
          value: item,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: img,
                    child: img == null
                        ? const Icon(Icons.image_not_supported,
                            size: 18, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 6),
                Divider(height: 1, color: Colors.grey.shade200),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (CatalogItemModel? v) {
        setState(() => _selectedItem = v);
      },
      dropdownStyleData: _dropdownStyle(context),
      menuItemStyleData: const MenuItemStyleData(
        height: 64,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      selectedItemBuilder: (context) {
        return availableItems.map((item) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              item.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: GestureDetector(
        onTap: _pickImage,
        child: _images.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined),
                    const SizedBox(height: 8),
                    Text(
                      "اضغط لإضافة صور (كاميرا/معرض)".tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        width: 150,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(_images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Catalog? _safeCatalogValue(List<Catalog> list, Catalog? v) {
    if (v == null) return null;
    final idx = list.indexWhere((e) => e.doc == v.doc);
    return idx == -1 ? null : list[idx];
  }

  SubCatModel? _safeSubCatValue(List<SubCatModel> list, SubCatModel? v) {
    if (v == null) return null;
    final idx = list.indexWhere((e) => e.doc == v.doc);
    return idx == -1 ? null : list[idx];
  }

  SubSubCatModel? _safeSubSubValue(
      List<SubSubCatModel> list, SubSubCatModel? v) {
    if (v == null) return null;
    final idx = list.indexWhere((e) => e.doc == v.doc);
    return idx == -1 ? null : list[idx];
  }

  Sub3CatModel? _safeSub3Value(List<Sub3CatModel> list, Sub3CatModel? v) {
    if (v == null) return null;
    final idx = list.indexWhere((e) => e.doc == v.doc);
    return idx == -1 ? null : list[idx];
  }

  Sub4CatModel? _safeSub4Value(List<Sub4CatModel> list, Sub4CatModel? v) {
    if (v == null) return null;
    final idx = list.indexWhere((e) => e.doc == v.doc);
    return idx == -1 ? null : list[idx];
  }

  CatalogItemModel? _safeItemValue(
      List<CatalogItemModel> list, CatalogItemModel? v) {
    if (v == null) return null;
    final idx = list.indexWhere((e) => e.doc == v.doc);
    return idx == -1 ? null : list[idx];
  }

  ImageProvider? _imageProviderSafe(String path) {
    final p = (path).trim();
    if (p.isEmpty) return null;
    if (p.startsWith("http")) return CachedNetworkImageProvider(p);
    final f = File(p);
    if (f.existsSync()) return FileImage(f);
    return null;
  }

  Widget _buildItemTable(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_selectedItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            "No items added yet".tr,
            style: TextStyle(
              fontFamily: ManagerFontFamily.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    List<DataRow> rows = _selectedItems.map((item) {
      final double unitPrice = double.tryParse(item.price) ?? 0.0;
      final double rowTotal = unitPrice * item.count;

      return DataRow(
        cells: [
          DataCell(
            Text(
              item.name,
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
            ),
          ),
          DataCell(
            item.path.isEmpty
                ? const CircleAvatar(child: Icon(Icons.image_not_supported))
                : (item.path.contains("http")
                    ? CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(item.path))
                    : CircleAvatar(
                        backgroundImage: FileImage(File(item.path)))),
          ),
          DataCell(Text(unitPrice.toStringAsFixed(2),
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily))),
          DataCell(Text(item.count.toString(),
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily))),
          DataCell(Text(rowTotal.toStringAsFixed(2),
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily))),
          DataCell(Text(item.des,
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily))),
          DataCell(
            IconButton(
              icon: const Icon(Icons.delete_outlined, color: Color(0xFFCE232B)),
              onPressed: () {
                setState(() {
                  _totlaprice -= rowTotal;
                  _selectedItems.remove(item);
                });
              },
            ),
          ),
        ],
      );
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: screenWidth * 0.08,
        columns: [
          _buildDataColumn('Name'.tr),
          _buildDataColumn('Image'.tr),
          _buildDataColumn('Price'.tr),
          _buildDataColumn('Count'.tr),
          _buildDataColumn('Total'.tr),
          _buildDataColumn('Notes'.tr),
          _buildDataColumn('Action'.tr),
        ],
        rows: rows,
      ),
    );
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF07933E),
          fontFamily: ManagerFontFamily.fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: _dropdownDecoration("طريقة الدفع".tr),
      value: _paymentMethod,
      items: paymentMethods.map((m) {
        return DropdownMenuItem<String>(
          value: m,
          child: Text(m,
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily)),
        );
      }).toList(),
      onChanged: (v) {
        setState(() {
          _paymentMethod = v;
          _paymentDetails = null;
        });
      },
      dropdownStyleData: _dropdownStyle(context),
      menuItemStyleData: const MenuItemStyleData(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildPaymentDetailsDropdown() {
    final List<String> options =
        _paymentMethod == "تحويل بنكي" ? bankTransferOptions : cardOptions;

    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: _dropdownDecoration("تفاصيل الدفع".tr),
      value: _paymentDetails,
      items: options.map((o) {
        return DropdownMenuItem<String>(
          value: o,
          child: Text(o,
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily)),
        );
      }).toList(),
      onChanged: (v) => setState(() => _paymentDetails = v),
      dropdownStyleData: _dropdownStyle(context),
      menuItemStyleData: const MenuItemStyleData(
        height: 55,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildManualItemInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextFormField(
          controller: _manualName,
          decoration: _dropdownDecoration("Item Name".tr),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _manualPrice,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: _dropdownDecoration("Price".tr),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _itemnote,
          decoration: _dropdownDecoration("Notes".tr),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickManualImage,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: _manualImage == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          "اضغط لإضافة صورة (كاميرا/معرض)".tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      _manualImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _qtyController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          decoration: _dropdownDecoration("Quantity".tr),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addManualItemToTable,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07933E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              "Add Manual Item".tr,
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addManualItemToTable() {
    if (_manualName.text.isEmpty || _manualPrice.text.isEmpty) {
      showErrorDialog(context, "Please fill name & price".tr);
      return;
    }

    final int qty = int.tryParse(_qtyController.text) ?? 1;

    final temp = CatalogItemModel(
      doc: "manual_${DateTime.now().millisecondsSinceEpoch}",
      name: _manualName.text,
      price: _manualPrice.text,
      des: _itemnote.text,
      path: _manualImage != null ? _manualImage!.path : "",
    );

    _addOrMergeItem(temp, qty);

    setState(() {
      _manualName.clear();
      _itemnote.clear();
      _manualNotes.clear();
      _manualPrice.clear();
      _manualImage = null;
    });
  }

  Widget _buildStoreItemDropdown() {
    if (_ItesmModels.isEmpty) {
      return Center(
        child: Text(
          "No store items available".tr,
          style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField2<ItemModel>(
            isExpanded: true,
            decoration: _dropdownDecoration("Select Store Item".tr),
            value: _selectedItemStore,
            items: _ItesmModels.map((item) {
              final isLast =
                  _ItesmModels.indexOf(item) == _ItesmModels.length - 1;
              return DropdownMenuItem<ItemModel>(
                value: item,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                    ),
                    if (!isLast) ...[
                      const SizedBox(height: 6),
                      Divider(height: 1, color: Colors.grey.shade200),
                    ],
                  ],
                ),
              );
            }).toList(),
            onChanged: (ItemModel? newValue) {
              setState(() => _selectedItemStore = newValue);
            },
            dropdownStyleData: _dropdownStyle(context),
            menuItemStyleData: const MenuItemStyleData(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            selectedItemBuilder: (context) {
              return _ItesmModels.map((item) {
                return Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
                  ),
                );
              }).toList();
            },
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _itemnote,
          decoration: InputDecoration(
            labelText: 'Notes'.tr,
            labelStyle: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _qtyController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          decoration: _dropdownDecoration("Quantity".tr),
        ),
        const SizedBox(height: 12),
        _selectedItemStore != null
            ? CircleAvatar(
                radius: 40,
                backgroundImage:
                    CachedNetworkImageProvider(_selectedItemStore!.pic),
              )
            : const SizedBox.shrink(),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addStoreItemToTable,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07933E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add Store Item'.tr,
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addStoreItemToTable() {
    if (_selectedItemStore == null) return;

    final int qty = int.tryParse(_qtyController.text) ?? 1;

    CatalogItemModel temp = CatalogItemModel(
      doc: _selectedItemStore!.doc,
      name: _selectedItemStore!.name,
      des: _itemnote.text,
      price: _selectedItemStore!.price.toString(),
      path: _selectedItemStore!.pic,
    );

    _addOrMergeItem(temp, qty);

    setState(() {
      _selectedItemStore = null;
    });
  }

  Widget _buildBranchDropdown() {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: _dropdownDecoration("Receiving".tr),
      value: _selectBranch,
      items: branch.map((b) {
        return DropdownMenuItem<String>(
          value: b,
          child: Text(
            b,
            style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectBranch = v),
      dropdownStyleData: _dropdownStyle(context),
      menuItemStyleData: const MenuItemStyleData(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      selectedItemBuilder: (context) {
        return branch.map((b) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              b,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: ManagerFontFamily.fontFamily),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _FillterReportWidget(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _reportfillter.length,
      itemBuilder: (context, index) {
        final bool selected = _selectreport == index;
        return InkWell(
          onTap: () {
            setState(() {
              _selectreport = index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF07933E) : Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(20),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.center,
              child: Text(
                _reportfillter[index].tr,
                style: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black87,
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

  double? _parseDeposit(String input) {
    final s = input.trim();
    if (s.isEmpty) return null;

    final cleaned = s.replaceAll(' ', '').replaceAll(',', '.');

    return double.tryParse(cleaned);
  }

  Widget _buildSubmitButton(
    BuildContext context,
    double screenHeight,
    double screenWidth,
  ) {
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.07,
      child: ElevatedButton(
        onPressed: () {
          if (_selectedItems.isNotEmpty || _selectedItemsStore.isNotEmpty) {
            if (_selectBranch != null && _selectBranch!.isNotEmpty) {
              if (_finalPaymentValue != null) {
                final depositVal = _parseDeposit(_deposit.text);
                if (depositVal == null) {
                  showErrorDialog(context, "الرجاء إدخال عربون صحيح".tr);
                  return;
                }

                double fees = _totlaprice - depositVal;

                if (fees >= 0) {
                  if (!mounted) return;
                  setState(() => _showModel = true);

                  widget.req.Address = _addressController.text;
                  widget.req.Float = float.text;
                  widget.req.TypeOfBuilding = typeofbuilding.text;

                  if (_AddDesgin) {
                    Submit2(
                      context,
                      userModel,
                      _AddDesgin,
                      widget.req,
                      _images,
                      _selectedItems,
                      _notes.text,
                      depositVal,
                      fees,
                      _totlaprice,
                      _selectBranch.toString(),
                      _finalPaymentValue!,
                    );
                  } else {
                    Submit(
                      context,
                      userModel,
                      _AddDesgin,
                      widget.req,
                      _selectedItems,
                      _notes.text,
                      depositVal,
                      fees,
                      _totlaprice,
                      _selectBranch.toString(),
                      _finalPaymentValue!,
                    );
                  }
                } else {
                  showErrorDialog(context,
                      "You entered a deposit greater than the total amount".tr);
                }
              } else {
                showErrorDialog(context, "الرجاء اختيار طريقة الدفع".tr);
              }
            } else {
              showErrorDialog(context, "Please Select Branch".tr);
            }
          } else {
            showErrorDialog(context, "Please Select Items".tr);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCE232B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Price".tr,
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              " $_totlaprice",
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: screenWidth * 0.06,
              right: screenWidth * 0.06,
              top: screenHeight * 0.02,
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
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 70.0, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete Request'.tr,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ModalProgressHUD(
              color: Colors.white,
              inAsyncCall: _showModel,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (userModel.type != "client") ...[
                        SizedBox(
                          height: screenHeight * 0.08,
                          child: _FillterReportWidget(context),
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (_selectreport == 0) ...[
                        _buildCatalogCard(),
                      ],
                      if (_selectreport == 1) ...[
                        const SizedBox(height: 12),
                        _buildStoreCard(),
                      ],
                      if (_selectreport == 2) ...[
                        const SizedBox(height: 12),
                        _buildManualCard(),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        "Selected Items".tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildItemTable(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _AddDesgin,
                            onChanged: (v) {
                              setState(() {
                                _AddDesgin = !_AddDesgin;
                              });
                            },
                          ),
                          Text(
                            "Add Special Design".tr,
                            style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (_AddDesgin) ...[
                        const SizedBox(height: 8),
                        _buildImagePicker(context),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        "Notes".tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                        ),
                        controller: _notes,
                        maxLines: 3,
                        decoration: _dropdownDecoration("Request Notes".tr),
                      ),
                      const SizedBox(height: 16),
                      if (userModel.type != "Client") ...[
                        Text(
                          "Deposit".tr,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _deposit,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]')),
                          ],
                          decoration: _dropdownDecoration("Deposit Amount".tr),

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "الرجاء إدخال قيمة العربون";
                            }

                            final cleaned = value
                                .trim()
                                .replaceAll(' ', '')
                                .replaceAll(',', '.');

                            final parsed = double.tryParse(cleaned);
                            if (parsed == null) {
                              return "قيمة العربون غير صحيحة";
                            }

                            if (parsed < 0) {
                              return "العربون لا يمكن أن يكون سالب";
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentMethodDropdown(),
                        if (_needsPaymentDetails) ...[
                          const SizedBox(height: 12),
                          _buildPaymentDetailsDropdown(),
                        ],
                      ],
                      const SizedBox(height: 16),
                      _buildBranchDropdown(),
                      if (_addressField() != null) ...[
                        const SizedBox(height: 16),
                        _addressField()!,
                      ],
                      if (_floatTextField() != null) ...[
                        const SizedBox(height: 16),
                        _floatTextField()!,
                      ],
                      if (_buildType() != null) ...[
                        const SizedBox(height: 16),
                        _buildType()!,
                      ],
                      const SizedBox(height: 24),
                      _buildSubmitButton(context, screenHeight, screenWidth),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
