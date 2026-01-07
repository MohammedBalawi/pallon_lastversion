import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Core/Utils/storage_upload.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/banner_model.dart';


final FirebaseFirestore _firestore=FirebaseFirestore.instance;

void AddBannerSame(BuildContext context,XFile image)async{
  try{
    String doc=DateTime.now().toString();
    final path = "item/photos/item-${DateTime.now().toString()}.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await uploadXFile(ref, image);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    await _firestore.collection('banner').doc(doc).set({
      'doc':doc,
      "action":urlDownload,
      'typeaction':'same',
      'path':urlDownload
    }).whenComplete((){
      Get.back();
    });
  }
  catch(e){
    showErrorDialog(context, e.toString());
  }
}


void AddBannerLink(BuildContext context,XFile image,TextEditingController link)async{
  try{
    String doc=DateTime.now().toString();
    final path = "item/photos/item-${DateTime.now().toString()}.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await uploadXFile(ref, image);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    await _firestore.collection('banner').doc(doc).set({
      'doc':doc,
      "action":link.text,
      'typeaction':'link',
      'path':urlDownload
    }).whenComplete((){
      Get.back();
    });
  }
  catch(e){
    showErrorDialog(context, e.toString());
  }
}

void AddBannerImage(BuildContext context,XFile image,XFile image2)async{
  try{
    String doc=DateTime.now().toString();
    final path = "item/photos/item-${DateTime.now().toString()}.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await uploadXFile(ref, image);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    final path2 = "item/photos/item-${DateTime.now().toString()}.jpg";
    final ref2 = FirebaseStorage.instance.ref().child(path2);
    final uploadTask2 = await uploadXFile(ref2, image2);
    final snapshot2 = await uploadTask2.whenComplete(() {});
    final urlDownload2 = await snapshot2.ref.getDownloadURL();
    await _firestore.collection('banner').doc(doc).set({
      'doc':doc,
      "action":urlDownload2,
      'typeaction':'link',
      'path':urlDownload
    }).whenComplete((){
      Get.back();
    });
  }
  catch(e){
    showErrorDialog(context, e.toString());
  }
}

void DeleteBanner(BuildContext context,BannerModel banner)async{
  try{
    await _firestore.collection('banner').doc(banner.doc).delete().whenComplete((){
      Get.back();
    });
  }
  catch(e){
    showErrorDialog(context, e.toString());
  }
}

void UpdateSame(BuildContext context ,XFile image,String doc)async{
  try{
    final path = "item/photos/item-${DateTime.now().toString()}.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await uploadXFile(ref, image);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    await _firestore.collection('banner').doc(doc).update({
      "action":urlDownload,
      'typeaction':'same',
      'path':urlDownload
    }).whenComplete((){
      Get.back();
    });
  }
  catch(e){
    showErrorDialog(context, e.toString());
  }
}

void UpdateImage(BuildContext context,XFile image,String doc)async{
  try{
    final path = "item/photos/item-${DateTime.now().toString()}.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await uploadXFile(ref, image);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    await _firestore.collection('banner').doc(doc).update({
      "action":urlDownload,
      'typeaction':'image',
    }).whenComplete((){
      Get.back();
    });
  }
  catch(e){
    showErrorDialog(context, e.toString());
  }
}


void UpdateImage2(BuildContext context,XFile image,String doc)async{
  try{
    final path = "item/photos/item-${DateTime.now().toString()}.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await uploadXFile(ref, image);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    await _firestore.collection('banner').doc(doc).update({
      'typeaction':'image',
      'path':urlDownload
    }).whenComplete((){
      Get.back();
    });
  }
  catch(e){
    showErrorDialog(context, e.toString());
  }
}


void UpdateImage3(BuildContext context,XFile image,XFile image2,String doc)async{
  try{
    final path = "item/photos/item-${DateTime.now().toString()}.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await uploadXFile(ref, image);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    final path2 = "item/photos/item-${DateTime.now().toString()}.jpg";
    final ref2 = FirebaseStorage.instance.ref().child(path2);
    final uploadTask2 = await uploadXFile(ref2, image2);
    final snapshot2 = await uploadTask2.whenComplete(() {});
    final urlDownload2 = await snapshot2.ref.getDownloadURL();
    await _firestore.collection('banner').doc(doc).update({
      'action':urlDownload2,
      'typeaction':'image',
      'path':urlDownload
    }).whenComplete((){
      Get.back();
    });
  }
  catch(e){
    showErrorDialog(context, e.toString());
  }
}

void UpdateLink(BuildContext context,String doc,TextEditingController link)async{
  try{
    await _firestore.collection('banner').doc(doc).update({
      'action':link.text.toString(),
      'typeaction':'link',
    }).whenComplete((){
      Get.back();
    });
  }
  catch(e){
    showErrorDialog(context, e.toString());
  }
}

void UpdateLink2(BuildContext context,String doc,XFile image)async{
  try{
    final path = "item/photos/item-${DateTime.now().toString()}.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await uploadXFile(ref, image);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    await _firestore.collection('banner').doc(doc).update({
      'path':urlDownload,
      'typeaction':'link',
    }).whenComplete((){
      Get.back();
    });
  }
  catch(e){
    showErrorDialog(context, e.toString());
  }
}

void UpdateLink3(BuildContext context,String doc,XFile image,TextEditingController link)async{
  try{
    final path = "item/photos/item-${DateTime.now().toString()}.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = await uploadXFile(ref, image);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    await _firestore.collection('banner').doc(doc).update({
      'path':urlDownload,
      'typeaction':'link',
      'action':link.text.toString()
    }).whenComplete((){
      Get.back();
    });
  }
  catch(e){
    showErrorDialog(context, e.toString());
  }
}

