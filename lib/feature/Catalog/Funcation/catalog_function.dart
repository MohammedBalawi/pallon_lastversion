import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/catalog_item_model.dart';
import '../../../models/catalog_model.dart';
import '../../../models/sub_cat_model.dart';
import '../../../models/sub_sub_cat.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<String> _uploadImageAndGetUrl(File image, String basePath) async {
  try {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = "$basePath-$fileName.jpg";
    debugPrint(' UPLOAD PATH => $path');

    final ref = FirebaseStorage.instance.ref().child(path);

    final data = await image.readAsBytes();

    final uploadTask = ref.putData(
      data,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    uploadTask.snapshotEvents.listen((snap) {
      debugPrint(
        'STATE=${snap.state}  BYTES=${snap.bytesTransferred}/${snap.totalBytes}',
      );
    });

    final snapshot = await uploadTask;
    final urlDownload = await snapshot.ref.getDownloadURL();

    debugPrint(' DOWNLOAD URL = $urlDownload');
    return urlDownload;
  } on FirebaseException catch (e) {
    debugPrint(' FIREBASE EX => code=${e.code}');
    debugPrint(' message=${e.message}');
    debugPrint(' plugin=${e.plugin}');
    debugPrint(' stack=${e.stackTrace}');
    rethrow;
  }
}

Future<void> CreateSub3Catalog(
  BuildContext context,
  Catalog catalog,
  SubCatModel sub,
  SubSubCatModel subsub,
  File image,
  TextEditingController name,
) async {
  try {
    if (name.text.trim().isEmpty) {
      showErrorDialog(context, "Please Add Name");
      return;
    }

    final sub3Ref = _firestore
        .collection('Catalog')
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('sub3');

    final sub3Snap = await sub3Ref.get();
    if (sub3Snap.size >= 5) {
      showErrorDialog(
        context,
        "You can only create up to 5 level-4 categories here",
      );
      return;
    }

    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "Catalog/sub3",
    );

    final doc = DateTime.now().toString();
    await sub3Ref.doc(doc).set({
      'doc': doc,
      'name': name.text.trim(),
      'pic': urlDownload,
    }).whenComplete(() {
      Get.back();
    });
  } on FirebaseException catch (e) {
    showErrorDialog(context, "code: ${e.code}\nmessage: ${e.message}");
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<void> EditSub3Catalog(
  BuildContext context,
  Catalog catalog,
  SubCatModel sub,
  SubSubCatModel subsub,
  String sub3Doc,
  TextEditingController name,
) async {
  try {
    await _firestore
        .collection('Catalog')
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('sub3')
        .doc(sub3Doc)
        .update({
      'name': name.text.trim(),
    }).whenComplete(() {
      Get.back();
    });
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<void> EditSub3CatalogImage(
  BuildContext context,
  Catalog catalog,
  SubCatModel sub,
  SubSubCatModel subsub,
  String sub3Doc,
  TextEditingController name,
  File image,
) async {
  try {
    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "Catalog/sub3",
    );

    await _firestore
        .collection('Catalog')
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('sub3')
        .doc(sub3Doc)
        .update({
      'name': name.text.trim(),
      'pic': urlDownload,
    }).whenComplete(() {
      Get.back();
    });
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<void> DeleteSub3Catalog(
  BuildContext context,
  Catalog catalog,
  SubCatModel sub,
  SubSubCatModel subsub,
  String sub3Doc,
) async {
  try {
    await _firestore
        .collection('Catalog')
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('sub3')
        .doc(sub3Doc)
        .delete();
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<void> CreateSub3Item(
  BuildContext context,
  Catalog catalog,
  SubCatModel sub,
  SubSubCatModel subsub,
  String sub3Doc,
  TextEditingController name,
  TextEditingController des,
  TextEditingController price,
  File image,
) async {
  try {
    final itemsRef = _firestore
        .collection('Catalog')
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('sub3')
        .doc(sub3Doc)
        .collection('item');

    final itemsSnap = await itemsRef.get();
    if (itemsSnap.size >= 5) {
      showErrorDialog(context, "You can only create up to 5 items here");
      return;
    }

    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "item/photos/item",
    );

    final doc = DateTime.now().toString();
    await itemsRef.doc(doc).set({
      'doc': doc,
      'path': urlDownload,
      'name': name.text.trim(),
      'des': des.text.trim(),
      'price': price.text.trim(),
    }).whenComplete(() {
      Get.back();
    });
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<void> CreateSub4Catalog(
  BuildContext context,
  Catalog catalog,
  SubCatModel sub,
  SubSubCatModel subsub,
  String sub3Doc,
  File image,
  TextEditingController name,
) async {
  try {
    if (name.text.trim().isEmpty) {
      showErrorDialog(context, "Please Add Name");
      return;
    }

    final sub4Ref = _firestore
        .collection('Catalog')
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('sub3')
        .doc(sub3Doc)
        .collection('sub4');

    final sub4Snap = await sub4Ref.get();
    if (sub4Snap.size >= 5) {
      showErrorDialog(
        context,
        "You can only create up to 5 level-5 categories here",
      );
      return;
    }

    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "Catalog/sub4",
    );

    final doc = DateTime.now().toString();
    await sub4Ref.doc(doc).set({
      'doc': doc,
      'name': name.text.trim(),
      'pic': urlDownload,
    }).whenComplete(() {
      Get.back();
    });
  } on FirebaseException catch (e) {
    showErrorDialog(context, "code: ${e.code}\nmessage: ${e.message}");
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<void> CreateSub4Item(
  BuildContext context,
  Catalog catalog,
  SubCatModel sub,
  SubSubCatModel subsub,
  String sub3Doc,
  String sub4Doc,
  TextEditingController name,
  TextEditingController des,
  TextEditingController price,
  File image,
) async {
  try {
    final itemsRef = _firestore
        .collection('Catalog')
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('sub3')
        .doc(sub3Doc)
        .collection('sub4')
        .doc(sub4Doc)
        .collection('item');

    final itemsSnap = await itemsRef.get();
    if (itemsSnap.size >= 5) {
      showErrorDialog(context, "You can only create up to 5 items here");
      return;
    }

    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "item/photos/item",
    );

    final doc = DateTime.now().toString();
    await itemsRef.doc(doc).set({
      'doc': doc,
      'path': urlDownload,
      'name': name.text.trim(),
      'des': des.text.trim(),
      'price': price.text.trim(),
    }).whenComplete(() {
      Get.back();
    });
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<void> EditSub4Catalog(
  BuildContext context,
  Catalog catalog,
  SubCatModel sub,
  SubSubCatModel subsub,
  String sub3Doc,
  String sub4Doc,
  TextEditingController name,
) async {
  try {
    await _firestore
        .collection('Catalog')
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('sub3')
        .doc(sub3Doc)
        .collection('sub4')
        .doc(sub4Doc)
        .update({
      'name': name.text.trim(),
    }).whenComplete(() {
      Get.back();
    });
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<void> EditSub4CatalogImage(
  BuildContext context,
  Catalog catalog,
  SubCatModel sub,
  SubSubCatModel subsub,
  String sub3Doc,
  String sub4Doc,
  TextEditingController name,
  File image,
) async {
  try {
    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "Catalog/sub4",
    );

    await _firestore
        .collection('Catalog')
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('sub3')
        .doc(sub3Doc)
        .collection('sub4')
        .doc(sub4Doc)
        .update({
      'name': name.text.trim(),
      'pic': urlDownload,
    }).whenComplete(() {
      Get.back();
    });
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<void> DeleteSub4Catalog(
  BuildContext context,
  Catalog catalog,
  SubCatModel sub,
  SubSubCatModel subsub,
  String sub3Doc,
  String sub4Doc,
) async {
  try {
    await _firestore
        .collection('Catalog')
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('sub3')
        .doc(sub3Doc)
        .collection('sub4')
        .doc(sub4Doc)
        .delete();
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future<void> createCategory(
  TextEditingController name,
  File image,
  BuildContext context,
) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    debugPrint(' CURRENT USER = ${user?.uid}');

    if (name.text.trim().isEmpty) {
      showErrorDialog(context, "Please Add Name");
      return;
    }

    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "item/photos/item",
    );

    debugPrint(' CATEGORY IMAGE URL = $urlDownload');

    await _firestore.collection('Catalog').doc().set({
      'cat': name.text.trim(),
      'pic': urlDownload,
    });

    Get.back();
  } on FirebaseException catch (e) {
    debugPrint(' FIREBASE EX => code=${e.code}');
    debugPrint(' message=${e.message}');
    debugPrint(' plugin=${e.plugin}');
    debugPrint(' stack=${e.stackTrace}');
    showErrorDialog(
      context,
      "code: ${e.code}\nmessage: ${e.message}",
    );
  } catch (e, st) {
    debugPrint(' UNKNOWN ERROR: $e\n$st');
    showErrorDialog(context, e.toString());
  }
}

Future<void> EditCategoty2(
  Catalog cat,
  TextEditingController name,
  BuildContext context,
) async {
  try {
    await _firestore.collection('Catalog').doc(cat.doc).update({
      'cat': name.text.trim(),
    }).whenComplete(() {
      Get.back();
    });
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (EditCategoty2) => $e');
    debugPrint(' STACK => $st');
    showErrorDialog(context, e.toString());
  }
}

Future<void> EditCategoty(
  Catalog cat,
  File image,
  TextEditingController name,
  BuildContext context,
) async {
  try {
    String? urlDownload;

    if (image.path.isNotEmpty) {
      urlDownload = await _uploadImageAndGetUrl(
        image,
        "item/photos/item",
      );
    }

    final data = <String, dynamic>{
      'cat': name.text.trim(),
    };

    if (urlDownload != null) {
      data['pic'] = urlDownload;
    }

    await _firestore
        .collection('Catalog')
        .doc(cat.doc)
        .update(data)
        .whenComplete(
          () => Get.back(),
        );
  } on FirebaseException catch (e) {
    debugPrint(' FIREBASE EX => code=${e.code}');
    debugPrint(' message=${e.message}');
    debugPrint(' plugin=${e.plugin}');
    debugPrint(' stack=${e.stackTrace}');
    showErrorDialog(context, "code: ${e.code}\nmessage: ${e.message}");
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (EditCategoty) => $e');
    debugPrint(' STACK => $st');
    showErrorDialog(context, e.toString());
  }
}

Future<void> EditSubCategoryCatalogWidget(
  BuildContext context,
  File image,
  TextEditingController name,
  Catalog cat,
  SubCatModel sub,
) async {
  try {
    String? urlDownload;

    if (image.path.isNotEmpty) {
      urlDownload = await _uploadImageAndGetUrl(
        image,
        "item/photos/item",
      );
    }

    final data = <String, dynamic>{
      'sub': name.text.trim(),
    };

    if (urlDownload != null) {
      data['pic'] = urlDownload;
    }

    await _firestore
        .collection('Catalog')
        .doc(cat.doc)
        .collection('sub')
        .doc(sub.doc)
        .update(data)
        .whenComplete(() {
      Get.back();
    });
  } on FirebaseException catch (e) {
    debugPrint(' FIREBASE EX => code=${e.code}');
    debugPrint(' message=${e.message}');
    debugPrint(' plugin=${e.plugin}');
    debugPrint(' stack=${e.stackTrace}');
    showErrorDialog(context, "code: ${e.code}\nmessage: ${e.message}");
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (EditSubCategoryCatalogWidget) => $e');
    debugPrint(' STACK => $st');
    showErrorDialog(context, e.toString());
  }
}

Future<void> DeleteSubCategory(
  BuildContext context,
  Catalog cat,
  SubCatModel sub,
) async {
  try {
    await _firestore
        .collection('Catalog')
        .doc(cat.doc)
        .collection('sub')
        .doc(sub.doc)
        .delete();
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (DeleteSubCategory) => $e');
    debugPrint(' STACK => $st');
    showErrorDialog(context, e.toString());
  }
}

Future<void> createSubCategory(
  TextEditingController name,
  File image,
  BuildContext context,
  Catalog cat,
) async {
  try {
    if (name.text.trim().isEmpty) {
      showErrorDialog(context, "Please Add Name");
      return;
    }

    final subSnap = await _firestore
        .collection('Catalog')
        .doc(cat.doc)
        .collection('sub')
        .get();

    if (subSnap.size >= 5) {
      showErrorDialog(
        context,
        "You can only create up to 5 sub categories for this category",
      );
      return;
    }

    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "item/photos/item",
    );

    await _firestore
        .collection('Catalog')
        .doc(cat.doc)
        .collection('sub')
        .doc()
        .set({
      'sub': name.text.trim(),
      'pic': urlDownload,
    }).whenComplete(() {
      Get.back();
    });
  } on FirebaseException catch (e) {
    debugPrint(' FIREBASE EX => code=${e.code}');
    debugPrint(' message=${e.message}');
    debugPrint(' plugin=${e.plugin}');
    debugPrint(' stack=${e.stackTrace}');
    showErrorDialog(context, "code: ${e.code}\nmessage: ${e.message}");
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (createSubCategory) => $e');
    debugPrint(' STACK => $st');
    showErrorDialog(context, e.toString());
  }
}

Future<void> CreateItemWidgetFunction(
  BuildContext context,
  String pathh,
  String path2,
  TextEditingController name,
  TextEditingController des,
  TextEditingController price,
  File image,
) async {
  try {
    final itemsSnap = await _firestore.collection(pathh).get();
    if (itemsSnap.size >= 5) {
      showErrorDialog(context, "You can only create up to 5 items here");
      return;
    }

    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "item/photos/item",
    );

    final doc = DateTime.now().toString();
    await _firestore.collection(pathh).doc(doc).set({
      'doc': doc,
      'path': urlDownload,
      'name': name.text.trim(),
      'des': des.text.trim(),
      'price': price.text.trim(),
    }).whenComplete(() {
      Get.back();
    });
  } on FirebaseException catch (e) {
    debugPrint(' FIREBASE EX => code=${e.code}');
    debugPrint(' message=${e.message}');
    debugPrint(' plugin=${e.plugin}');
    debugPrint(' stack=${e.stackTrace}');
    showErrorDialog(context, "code: ${e.code}\nmessage: ${e.message}");
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (CreateItemWidgetFunction) => $e');
    debugPrint(' STACK => $st');
    showErrorDialog(context, e.toString());
  }
}

Future<void> CreateCatalogItems(
  BuildContext context,
  Catalog cat,
  SubCatModel sub,
  SubSubCatModel subsub,
  TextEditingController name,
  TextEditingController des,
  TextEditingController price,
  File image,
) async {
  try {
    final itemsRef = _firestore
        .collection('Catalog')
        .doc(cat.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection("item");

    final itemsSnap = await itemsRef.get();
    if (itemsSnap.size >= 5) {
      showErrorDialog(context, "You can only create up to 5 items here");
      return;
    }

    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "item/photos/item",
    );

    final doc = DateTime.now().toString();
    await itemsRef.doc(doc).set({
      'doc': doc,
      'path': urlDownload,
      'name': name.text.trim(),
      'des': des.text.trim(),
      'price': price.text.trim(),
    }).whenComplete(() {
      Get.back();
    });
  } on FirebaseException catch (e) {
    debugPrint(' FIREBASE EX => code=${e.code}');
    debugPrint(' message=${e.message}');
    debugPrint(' plugin=${e.plugin}');
    debugPrint(' stack=${e.stackTrace}');
    showErrorDialog(context, "code: ${e.code}\nmessage: ${e.message}");
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (CreateCatalogItems) => $e');
    debugPrint(' STACK => $st');
    showErrorDialog(context, e.toString());
  }
}

Future<void> EditItem(
  BuildContext context,
  TextEditingController name,
  TextEditingController des,
  TextEditingController price,
  String doc,
  String path,
) async {
  try {
    await _firestore.collection(path).doc(doc).update({
      'name': name.text.trim(),
      'price': price.text.trim(),
      'des': des.text.trim(),
    }).whenComplete(() {
      Get.back();
    });
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (EditItem) => $e');
    debugPrint(' STACK => $st');
    ErrorCustom(context, e.toString());
  }
}

Future<void> EditItemCataglog(
  BuildContext context,
  TextEditingController name,
  TextEditingController des,
  TextEditingController price,
  String doc,
  Catalog cat,
  SubCatModel sub,
  SubSubCatModel subsub,
) async {
  try {
    await _firestore
        .collection('Catalog')
        .doc(cat.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('item')
        .doc(doc)
        .update({
      'name': name.text.trim(),
      'price': price.text.trim(),
      'des': des.text.trim(),
    }).whenComplete(() {
      Get.back();
    });
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (EditItemCataglog) => $e');
    debugPrint(' STACK => $st');
    ErrorCustom(context, e.toString());
  }
}

Future<void> EditItem2(
  BuildContext context,
  TextEditingController name,
  TextEditingController des,
  TextEditingController price,
  String doc,
  String pathh,
  File image,
) async {
  try {
    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "item/photos/item",
    );

    await _firestore.collection(pathh).doc(doc).update({
      'name': name.text.trim(),
      'price': price.text.trim(),
      'des': des.text.trim(),
      'path': urlDownload,
    }).whenComplete(() {
      Get.back();
    });
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (EditItem2) => $e');
    debugPrint(' STACK => $st');
    ErrorCustom(context, e.toString());
  }
}

Future<void> EditItemCataglog2(
  BuildContext context,
  TextEditingController name,
  TextEditingController des,
  TextEditingController price,
  String doc,
  Catalog cat,
  SubCatModel sub,
  File image,
  SubSubCatModel subsub,
) async {
  try {
    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "item/photos/item",
    );

    await _firestore
        .collection('Catalog')
        .doc(cat.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('item')
        .doc(doc)
        .update({
      'name': name.text.trim(),
      'price': price.text.trim(),
      'des': des.text.trim(),
      'path': urlDownload,
    }).whenComplete(() {
      Get.back();
    });
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (EditItemCataglog2) => $e');
    debugPrint(' STACK => $st');
    ErrorCustom(context, e.toString());
  }
}

Future<void> DeleteItem(
  BuildContext context,
  String path,
  String doc,
) async {
  try {
    await _firestore.collection(path).doc(doc).delete().whenComplete(() {
      Get.back();
    });
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (DeleteItem) => $e');
    debugPrint(' STACK => $st');
    ErrorCustom(context, e.toString());
  }
}

Future<void> DeleteItemCatalog(
  BuildContext context,
  String doc,
  Catalog cat,
  SubCatModel sub,
  SubSubCatModel subsub,
) async {
  try {
    await _firestore
        .collection('Catalog')
        .doc(cat.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .collection('item')
        .doc(doc)
        .delete()
        .whenComplete(() {
      Get.back();
    });
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (DeleteItemCatalog) => $e');
    debugPrint(' STACK => $st');
    ErrorCustom(context, e.toString());
  }
}

Future<List<CatalogItemModel>> GetAllItems(BuildContext context) async {
  List<Catalog> cat = [];
  List<SubCatModel> sub = [];
  List<CatalogItemModel> items = [];

  try {
    await _firestore.collection('Catalog').get().then((value) async {
      for (int i = 0; i < value.size; i++) {
        cat.add(
          Catalog(
            doc: value.docs[i].id,
            cat: value.docs[i].get('cat'),
            pic: value.docs[i].get('pic'),
          ),
        );
        sub = [];

        await _firestore
            .collection('Catalog')
            .doc(cat[i].doc)
            .collection('sub')
            .get()
            .then((value) {
          for (int j = 0; j < value.size; j++) {
            sub.add(
              SubCatModel(
                doc: value.docs[j].id,
                sub: value.docs[j].get('sub'),
                pic: value.docs[j].get('pic'),
              ),
            );
          }
        }).whenComplete(() async {
          await _firestore
              .collection('Catalog')
              .doc(cat[i].doc)
              .collection('item')
              .get()
              .then((value) {
            for (int j = 0; j < value.size; j++) {
              items.add(
                CatalogItemModel(
                  doc: value.docs[j].id,
                  name: value.docs[j].get('name'),
                  path: value.docs[j].get('path'),
                  des: value.docs[j].get('des'),
                  price: value.docs[j].get('price'),
                ),
              );
            }
          });

          cat[i].sub = sub;

          for (int k = 0; k < cat[i].sub.length; k++) {
            await _firestore
                .collection('Catalog')
                .doc(cat[i].doc)
                .collection('sub')
                .doc(cat[i].sub[k].doc)
                .collection('subsub')
                .get()
                .then((value) async {
              for (int m = 0; m < value.size; m++) {
                cat[i].sub[k].subsub.add(
                      SubSubCatModel(
                        doc: value.docs[m].id,
                        subsub: value.docs[m].get('subsub'),
                        pic: value.docs[m].get('pic'),
                      ),
                    );
              }

              await _firestore
                  .collection('Catalog')
                  .doc(cat[i].doc)
                  .collection('sub')
                  .doc(cat[i].sub[k].doc)
                  .collection('item')
                  .get()
                  .then((value) {
                for (int j = 0; j < value.size; j++) {
                  items.add(
                    CatalogItemModel(
                      doc: value.docs[j].id,
                      name: value.docs[j].get('name'),
                      path: value.docs[j].get('path'),
                      des: value.docs[j].get('des'),
                      price: value.docs[j].get('price'),
                    ),
                  );
                }
              });

              for (int m = 0; m < cat[i].sub[k].subsub.length; m++) {
                await _firestore
                    .collection('Catalog')
                    .doc(cat[i].doc)
                    .collection('sub')
                    .doc(cat[i].sub[k].doc)
                    .collection('subsub')
                    .doc(cat[i].sub[k].subsub[m].doc)
                    .collection('item')
                    .get()
                    .then((value) {
                  for (int n = 0; n < value.size; n++) {
                    items.add(
                      CatalogItemModel(
                        doc: value.docs[n].id,
                        name: value.docs[n].get('name'),
                        path: value.docs[n].get('path'),
                        des: value.docs[n].get('des'),
                        price: value.docs[n].get('price'),
                      ),
                    );
                  }
                });
              }
            });
          }
        });
      }
    });
    return items;
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (GetAllItems) => $e');
    debugPrint(' STACK => $st');
    ErrorCustom(context, e.toString());
    return items;
  }
}

List<CatalogItemModel> SearchItem(
  List<CatalogItemModel> allitems,
  String text,
) {
  List<CatalogItemModel> items = [];
  final q = text.toLowerCase();

  for (int i = 0; i < allitems.length; i++) {
    if (allitems[i].name.toLowerCase().contains(q)) {
      items.add(allitems[i]);
    }
  }
  return items;
}

Future<void> CreateSubSubCatalog(
  BuildContext context,
  SubCatModel sub,
  Catalog catalog,
  File image,
  TextEditingController name,
) async {
  try {
    final subSubRef = _firestore
        .collection('Catalog')
        .doc(catalog.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub');

    final subSubSnap = await subSubRef.get();
    if (subSubSnap.size >= 5) {
      showErrorDialog(
        context,
        "You can only create up to 5 sub-sub categories here",
      );
      return;
    }

    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "Catalog/sub/subsub",
    );

    final doc = DateTime.now().toString();
    await subSubRef.doc(doc).set({
      'doc': doc,
      'pic': urlDownload,
      'subsub': name.text.trim(),
    }).whenComplete(() {
      Get.back();
    });
  } on FirebaseException catch (e) {
    debugPrint(' FIREBASE EX => code=${e.code}');
    debugPrint(' message=${e.message}');
    debugPrint(' plugin=${e.plugin}');
    debugPrint(' stack=${e.stackTrace}');
    showErrorDialog(context, "code: ${e.code}\nmessage: ${e.message}");
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (CreateSubSubCatalog) => $e');
    debugPrint(' STACK => $st');
    showErrorDialog(context, e.toString());
  }
}

Future<void> EditSubSubImage(
  BuildContext context,
  Catalog cat,
  SubCatModel sub,
  SubSubCatModel subsub,
  TextEditingController name,
  File image,
) async {
  try {
    final urlDownload = await _uploadImageAndGetUrl(
      image,
      "Catalog/sub/subsub",
    );

    await _firestore
        .collection('Catalog')
        .doc(cat.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .update({
      'pic': urlDownload,
      'subsub': name.text.trim(),
    }).whenComplete(() {
      Get.back();
    });
  } on FirebaseException catch (e) {
    debugPrint(' FIREBASE EX => code=${e.code}');
    debugPrint(' message=${e.message}');
    debugPrint(' plugin=${e.plugin}');
    debugPrint(' stack=${e.stackTrace}');
    showErrorDialog(context, "code: ${e.code}\nmessage: ${e.message}");
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (EditSubSubImage) => $e');
    debugPrint(' STACK => $st');
    showErrorDialog(context, e.toString());
  }
}

Future<void> EditSubSub(
  BuildContext context,
  Catalog cat,
  SubCatModel sub,
  SubSubCatModel subsub,
  TextEditingController name,
) async {
  try {
    await _firestore
        .collection('Catalog')
        .doc(cat.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .update({
      'subsub': name.text.trim(),
    }).whenComplete(() {
      Get.back();
    });
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (EditSubSub) => $e');
    debugPrint(' STACK => $st');
    showErrorDialog(context, e.toString());
  }
}

Future<void> DeleteSubSub(
  BuildContext context,
  Catalog cat,
  SubCatModel sub,
  SubSubCatModel subsub,
) async {
  try {
    await _firestore
        .collection('Catalog')
        .doc(cat.doc)
        .collection('sub')
        .doc(sub.doc)
        .collection('subsub')
        .doc(subsub.doc)
        .delete();
  } catch (e, st) {
    debugPrint(' UNKNOWN EX (DeleteSubSub) => $e');
    debugPrint(' STACK => $st');
    showErrorDialog(context, e.toString());
  }
}
