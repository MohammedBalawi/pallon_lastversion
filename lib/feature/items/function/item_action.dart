import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/admin/reports_v1.dart';

import '../../../models/item_model.dart';

final FirebaseFirestore _firestore=FirebaseFirestore.instance;

void SaveNewItem(ItemModel item,File image,BuildContext context)async{
  try{
    final path = "item/photos/item-${DateTime.now().toString()}.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(image);
    final snapshot = await uploadTask.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    await _firestore.collection('item').doc().set({
      'count':item.count.toString(),
      'Item':item.name,
      'id':item.id,
      'price':item.price.toString(),
      'pic':urlDownload,
      'show':item.show.toString(),
      'pricebuy':item.pricebuy.toString(),
      'des':item.des.toString(),
    }).whenComplete(()async{
      await _firestore.collection('itemhistory').doc().set({
        'count':item.count.toString(),
        'Item':item.name,
        'id':item.id,
        'price':item.price.toString(),
        'pic':urlDownload,
        'show':item.show.toString(),
        'pricebuy':item.pricebuy.toString(),
        'type':"add",
        'time':DateTime.now().toString(),
      }).whenComplete((){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item Save Successfully!'),
            backgroundColor: Color(0xFF07933E),
          ),
        );
        Get.back();
      });
    });
  }
  catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item Save Field!"),
        backgroundColor: Color(0xFF07933E),
      ),
    );
    Get.back();
  }
}
void EditItemAction(ItemModel item,File image,BuildContext context,int last)async{
  try{
    if(image!=null){
      final path = "item/photos/item-${DateTime.now().toString()}.jpg";
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      await _firestore.collection('item').doc(item.doc).update({
        'count':item.count.toString(),
        'Item':item.name,
        'id':item.id,
        'price':item.price.toString(),
        'pic':urlDownload,
        'show':item.show.toString(),
        'des':item.des.toString()
      }).whenComplete(()async{
        int x=last-item.count;
        if(x!=0){
          await _firestore.collection('itemhistory').doc().set({
            'count':x>0?x.toString():x.abs().toString(),
            'Item':item.name,
            'id':item.id,
            'price':item.price.toString(),
            'pic':item.pic,
            'show':item.show.toString(),
            'pricebuy':item.pricebuy.toString(),
            'type':x>0?"remove":"add",
            'time':DateTime.now().toString(),
          }).whenComplete((){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item Remove Successfully!'),
                backgroundColor: Color(0xFF07933E),
              ),
            );
            Get.back();
          });
        }
        else{
          Get.back();
        }
      });
    }
    else{
      await _firestore.collection('item').doc(item.doc).update({
        'count':item.count.toString(),
        'Item':item.name,
        'id':item.id,
        'price':item.price.toString(),
        'pic':item.pic,
        'show':item.show.toString()
      }).whenComplete((){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item Updated Successfully!'),
            backgroundColor: Color(0xFF07933E),
          ),
        );
        Get.back();
      });
    }

  }
  catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item Updated Field!"),
        backgroundColor: Color(0xFF07933E),
      ),
    );
    Get.back();
  }
}


void EditItemAction2(ItemModel item,BuildContext context,int lastcount)async{
  try{
    await _firestore.collection('item').doc(item.doc).update({
      'count':item.count.toString(),
      'Item':item.name,
      'id':item.id,
      'price':item.price.toString(),
      'pic':item.pic,
      'show':item.show.toString(),
      'des':item.des.toString()
    }).whenComplete(()async{
      int x=lastcount-item.count;
      if(x!=0){
        await _firestore.collection('itemhistory').doc().set({
          'count':x>0?x.toString():x.abs().toString(),
          'Item':item.name,
          'id':item.id,
          'price':item.price.toString(),
          'pic':item.pic,
          'show':item.show.toString(),
          'pricebuy':item.pricebuy.toString(),
          'type':x>0?"remove":"add",
          'time':DateTime.now().toString(),
        }).whenComplete((){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item Remove Successfully!'),
              backgroundColor: Color(0xFF07933E),
            ),
          );
          Get.back();
        });
      }
      else{
        Get.back();
      }
    });

  }
  catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item Updated Field!"),
        backgroundColor: Color(0xFF07933E),
      ),
    );
    Get.back();
  }
}


void RemoveItem(ItemModel item,BuildContext context)async{
  try{
    await _firestore.collection('item').doc(item.doc).delete().whenComplete(()async{
      await _firestore.collection('itemhistory').doc().set({
        'count':item.count.toString(),
        'Item':item.name,
        'id':item.id,
        'price':item.price.toString(),
        'pic':item.pic,
        'show':item.show.toString(),
        'pricebuy':item.pricebuy.toString(),
        'type':"remove",
        'time':DateTime.now().toString(),
      }).whenComplete((){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item Remove Successfully!'),
            backgroundColor: Color(0xFF07933E),
          ),
        );
        Get.back();
      });
    });
  }
  catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item Remove Field!'),
        backgroundColor: Color(0xFF07933E),
      ),
    );
    Get.back();
  }
}


Future<List<ItemModel>> GetAllStore(BuildContext context)async{
  List<ItemModel> items=[];
  try{
    await _firestore.collection('item').get().then((value){
      for(int i=0;i<value.size;i++){
        items.add(
          ItemModel(doc: value.docs[i].id, id: value.docs[i].get('id'),
              name: value.docs[i].get('Item'), count: int.parse(value.docs[i].get('count')),
              price: double.parse(value.docs[i].get('price')), pic: value.docs[i].get('pic'),
              show: bool.parse(value.docs[i].get('show')))
        );

      }
    });
    return items;
  }
  catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ),
    );
    return items;
  }
}



