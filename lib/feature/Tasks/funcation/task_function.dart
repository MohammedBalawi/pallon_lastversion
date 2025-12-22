import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/models/image_model.dart';
import 'package:pallon_lastversion/models/item_model.dart';
import 'package:pallon_lastversion/models/order_model.dart';
import 'package:pallon_lastversion/models/user_model.dart';
import '../../../Core/Widgets/common_widgets.dart';
import '../../../models/req_data_model.dart';
import '../../../models/task_model.dart';


final FirebaseAuth _auth=FirebaseAuth.instance;
final FirebaseFirestore _firestore=FirebaseFirestore.instance;


Future<TaskModel> GetTaskReq(TaskModel task,BuildContext context)async{
  try{
    await _firestore.collection('req').doc(task.doc).get().then((value){
      task.req=ReqDataModel(doc:value.id ,name: value.get('name'), fees: value.get('fees'), total: value.get('total'),
          des: [], item: [], float: value.get('float'), address: value.get('address'),
          date: value.get('date'), hour: value.get('hour'), phone: value.get('phone'),
          createby: value.get('createby'),
          deposite: value.get('deposit'), design: value.get('desgin'), notes: value.get('notes'),
          ownerOfevent: value.get('ownerofevent'),
          status: value.get('status'), typeby: value.get('typeCreate'), typeOfBuilding: value.get('typeofbuilding'),
          typeOfEvent: value.get('typeofevent'),
          branch:value.get("branch") ,typebank: value.get("banktype"));
      task.req!.orderNumber=value.get('ordernumber');
      task.req!.task=value.get('task');
    });
    return task;
  }
  catch(e){
    ErrorCustom(context, e.toString());
    return task;
  }
}

Future<List<TaskModel>>GetAdminTask(DateTime date,BuildContext context)async{
  List<TaskModel> tasks=[];
  try{
    int day=date.day;
    int month=date.month;
    int year=date.year;
    String dateQuery="$day/$month/$year";
    await _firestore.collection('req').where('status',isEqualTo: 'order').get().then((value)async{
      for(int i=0;i<value.size;i++){
        if(dateQuery==value.docs[i].get('date')){
          TaskModel task=TaskModel(doc: value.docs[i].id);
          task=await GetTaskReq(task, context);
          tasks.add(task);
        }
      }
    });
    return tasks;
  }
  catch(e){
    ErrorCustom(context, e.toString());
    return tasks;
  }
}

Future<List<TaskModel>> GetUserTaskDate(DateTime date,BuildContext context)async{
  List<TaskModel> tasks=[];
  try{
    List<String> taskdocs=[];
    int day=date.day;
    int month=date.month;
    int year=date.year;
    String dateQuery="$day/$month/$year";
    await _firestore.collection('user').doc(_auth.currentUser!.uid).collection('task').get().then((value){
      for(int i=0;i<value.size;i++){
        taskdocs.add(value.docs[i].get('doc'));
      }
    }).whenComplete(()async{
      for(int i=0;i<taskdocs.length;i++){
        await _firestore.collection('req').doc(taskdocs[i]).get().then((value)async{
          if(dateQuery==value.get('date')){
            TaskModel task=TaskModel(doc: value.id);
            task=await GetTaskReq(task, context);
            tasks.add(task);
          }
        });
      }
    });
    return tasks;
  }
  catch(e){
    ErrorCustom(context, e.toString());
   return tasks;
  }
}

Future<List<ImageModel>> GetDesginerTask(OrderModel order,BuildContext context)async{
  List<ImageModel> list=[];
  try{
    await _firestore.collection('req').doc(order.req!.doc).collection('designer').get().then((value){
      for(int i=0;i<value.size;i++){
        list.add(
          ImageModel(doc: value.docs[i].id, path: value.docs[i].get('path'))
        );
      }
    });
    return list;
  }
  catch(e){
    ErrorCustom(context, e.toString());
    return list;
  }
}

void AddComment(TextEditingController comment,BuildContext context,UserModel user,String coll,String doc)async{
  try{
    await _firestore.collection("req").doc(doc).collection(coll).doc().set({
      'name':user.name,
      'pic':user.pic,
      'type':user.type,
      'text':comment.text
    }).whenComplete((){
      Get.back();
    });
  }
  catch(e){
    ErrorCustom(context, e.toString());
  }
}

void FinishTask(BuildContext context,OrderModel order,String next,String status)async{
  try{
    await _firestore.collection('req').doc(order.req!.doc).update({
      'task':next,
      'taskstatus':status,
    }).whenComplete((){
      Get.back();
    });
  }
  catch(e){
    ErrorCustom(context, e.toString());
  }
}

void UploadDesgin(List<File> image,BuildContext context,OrderModel order)async{
  try{
    for(int i=0;i<image.length;i++){
      final path = "item/photos/item-${DateTime.now().toString()}.jpg";
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(image[i]!);
      final snapshot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      await _firestore.collection('req').doc(order.req!.doc).collection('designer').doc().set({
        'path':urlDownload
      });
    }
  }
  catch(e){
    ErrorCustom(context, e.toString());
  }
}

void RemoveDesign(BuildContext context,ImageModel image,OrderModel order)async{
  try{
    await _firestore.collection('req').doc(order.req!.doc).collection("designer")
        .doc(image.doc).delete();
  }
  catch(e){
    ErrorCustom(context, e.toString());
  }
}

void AddVendorTask(BuildContext context,ItemModel item,OrderModel order)async{
  try{
    await _firestore.collection('req').doc(order.req!.doc).collection("vendor").doc().set({
      'id':item.doc,
      'count':item.count,
      'price':item.price,
      'name':item.name,
      'pic':item.pic,
      'show':item.show,
      'pricebuy':item.pricebuy
    }).whenComplete(()async{
      int count=0;
      await _firestore.collection('item').doc(item.doc).get().then((value){
        int old=int.parse(value.get('count'));
        count=old-item.count;
      }).whenComplete(()async{
        await _firestore.collection('item').doc(item.doc).update({
          'count':count.toString()
        }).whenComplete(()async{
          await _firestore.collection('itemhistory').doc().set({
            'count':item.count,
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
                content: Text('Item Add Successfully!'),
                backgroundColor: Color(0xFF07933E),
              ),
            );
          });
        });
      });
    });
  }
  catch(e){
    ErrorCustom(context, e.toString());
  }
}

void DeleteVendorItem(BuildContext context,ItemModel item,OrderModel order)async{
  try{
    String id=item.id;
    int count=item.count;
    int old=0;
    await _firestore.collection('req').doc(order.req!.doc).collection('vendor')
        .doc(item.doc).delete().whenComplete(()async{
          await _firestore.collection('item').doc(id).get().then((value){
            old=int.parse(value.get('count'));
          }).whenComplete(()async{
            count=count+old;
            await _firestore.collection('item').doc(id).update({
              'count':count.toString()
            }).whenComplete(()async{
              await _firestore.collection('itemhistory').doc().set({
                'count':item.count,
                'Item':item.name,
                'id':item.id,
                'price':item.price.toString(),
                'pic':item.pic,
                'show':item.show.toString(),
                'pricebuy':item.pricebuy.toString(),
                'type':"add",
                'time':DateTime.now().toString(),
              }).whenComplete((){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item Remove Successfully!'),
                    backgroundColor: Color(0xFF07933E),
                  ),
                );
              });
            });
          });
    });
  }
  catch(e){
    ErrorCustom(context, e.toString());
  }
}
void UpdateDriverTask(BuildContext context,String status,String doc)async{
  try{
    await _firestore.collection('req').doc(doc).update({
      'taskstatus':status
    });
  }
  catch(e){
    ErrorCustom(context, e.toString());
  }
}

void UpdateItemTask(BuildContext context,String status,String doc)async{
  try{
    List<int> count=[];
    List<String> items=[];
    List<String> names=[];
    await _firestore.collection('req').doc(doc).collection('vendor').get().then((value){
      for(int i=0;i<value.size;i++){
        count.add(value.docs[i].get('count'));
        items.add(value.docs[i].get('id'));
        names.add(value.docs[i].get('name'));
      }
    }).then((value)async{
      for(int i=0;i<items.length;i++){
        int number=0;
        await _firestore.collection('item').doc(items[i]).get().then((value){
          number=int.parse(value.get('count'));
        }).then((value)async{
          int total=count[i]+number;
          await _firestore.collection('item').doc(items[i]).update({
            'count':total.toString()
          }).whenComplete(()async{
            await _firestore.collection('req').doc(doc).update({
              "taskstatus":status,
            }).whenComplete(()async{
              await _firestore.collection('itemhistory').doc().set({
                'Item':names[i],
                'count':count[i],
                'id':items[i],
                'pic':"",
                "price":"0.0",
                "show":"false",
                "time":DateTime.now().toString(),
                'type':"add",
              });
            });
          });
        });
      }
    });
  }
  catch(e){
    ErrorCustom(context, e.toString());
  }
}

void FinishOrder(BuildContext context,String doc)async{
  try{
    await _firestore.collection('req').doc(doc).update({
      'task':'finish',
      'status':"finish"
    }).whenComplete(()async{
      List<String> staffdoc=[];
      await _firestore.collection('req').doc(doc).collection('jop').get().then((value){
        staffdoc.add(value.docs[0].get('Coordinator'));
        staffdoc.add(value.docs[0].get('Designer'));
        staffdoc.add(value.docs[0].get('Driver'));
        staffdoc.add(value.docs[0].get('Vendor'));
      }).whenComplete(()async{
        for(int i=0;i<staffdoc.length;i++){
          String id="";
          await _firestore.collection('user').doc(staffdoc[i]).collection('task').where('doc',isEqualTo: doc).get().then((value){
            id=value.docs[0].id;
          }).then((value)async{
            await _firestore.collection('user').doc(staffdoc[i]).collection('task').doc(id).delete();
          });
        }
      });
    });
  }
  catch(e){
    ErrorCustom(context, e.toString());
  }
}


Future<List<ItemModel>> getorderitem(BuildContext context,OrderModel order)async{
  List<ItemModel> items=[];
  try{
    await _firestore.collection('req').doc(order.req!.doc).collection('vendor').get().then((value){
      for(int i=0;i<value.size;i++){
        items.add(
            ItemModel(
                doc: value.docs[i].id,
                id: value.docs[i].get('id'), name: value.docs[i].get('name'),
                count: value.docs[i].get('count'),
                price: value.docs[i].get('price'), pic: value.docs[i].get('pic'),
                show: value.docs[i].get('show')));
      }
    });
    return items;
  }
  catch(e){
    ErrorCustom(context, e.toString());
    return items;
  }
}