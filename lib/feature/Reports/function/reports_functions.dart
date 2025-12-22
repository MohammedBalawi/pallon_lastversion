import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:pallon_lastversion/models/item_model.dart';
import 'package:pallon_lastversion/models/req_data_model.dart';
import 'package:pallon_lastversion/models/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import '../../../Core/Widgets/common_widgets.dart';
import 'package:pdf/widgets.dart' as pw;


Future<void> StoreexportToExcel(BuildContext context,List<ItemModel> item) async {
  try{
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    List<CellValue> row=[
      TextCellValue("ID"),
      TextCellValue("Name"),
      TextCellValue("Time"),
      TextCellValue("Action"),
      TextCellValue("Count"),
    ];
    sheet.appendRow(row);
    for(int i=0;i<item.length;i++){
      List<CellValue> row=[
        TextCellValue(item[i].id),
        TextCellValue(item[i].name),
        TextCellValue(item[i].time.toString()),
        TextCellValue(item[i].action.toString()),
        TextCellValue(item[i].count.toString()),
      ];
      sheet.appendRow(row);
    }
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/reports.xlsx';
    final file = File(path)..createSync(recursive: true);
    file.writeAsBytesSync(excel.encode()!);
    await Share.shareXFiles([XFile(path)], text: 'Store Reports Excel File');
  }
  catch(e){
    ErrorCustom(context,e.toString());
  }
}

Future<void> StoreexportToPdf(BuildContext context,List<ItemModel> item) async{
  try{
    final pdf = pw.Document();
    pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
            build: (pw.Context context){
            return [
              pw.Text('Store Reports', style: pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['ID', 'Name', 'Time','Action','Count'],
                data: item.map((it){

                  return [
                    it.id,
                    it.name.toString(),
                    it.time.toString(),
                    it.action.toString(),
                    it.count.toString()
                  ];
                }).toList()
              )
            ];
            }
        )
    );
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/reports.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(path)], text: 'Store Reports PDF File');
  }
  catch(e){
    ErrorCustom(context,e.toString());
  }
}

Future<void> UserexportToExcel(BuildContext context,List<UserModel> user) async {
  try{
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    List<CellValue> row=[
      TextCellValue("NO"),
      TextCellValue("Name"),
      TextCellValue("Email"),
      TextCellValue("Phone"),
      TextCellValue("Type"),
    ];
    sheet.appendRow(row);
    for(int i=0;i<user.length;i++){
      List<CellValue> row=[
        TextCellValue((i+1).toString()),
        TextCellValue(user[i].name),
        TextCellValue(user[i].email.toString()),
        TextCellValue(user[i].phone.toString()),
        TextCellValue(user[i].type.toString()),
      ];
      sheet.appendRow(row);
    }
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/userreports.xlsx';
    final file = File(path)..createSync(recursive: true);
    file.writeAsBytesSync(excel.encode()!);
    await Share.shareXFiles([XFile(path)], text: 'User Reports Excel File');
  }
  catch(e){
    ErrorCustom(context,e.toString());
  }
}


Future<void> UserexportToPdf(BuildContext context,List<UserModel> user) async{
  try{
    final pdf = pw.Document();
    pdf.addPage(
        pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context){
              int i=0;
              return [
                pw.Text('User Reports', style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                    headers: ['No', 'Name', 'Email','Phone','Type'],
                    data: user.map((it){
                      i++;
                      return [
                        i.toString(),
                        it.name.toString(),
                        it.email.toString(),
                        it.phone.toString(),
                        it.type.toString()
                      ];
                    }).toList()
                )
              ];
            }
        )
    );
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/Userreports.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(path)], text: 'User Reports PDF File');
  }
  catch(e){
    ErrorCustom(context,e.toString());
  }
}

Future<void> OrderexportToPdf(BuildContext context,List<ReqDataModel> req) async{
  try{
    final pdf = pw.Document();
    pdf.addPage(
        pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context){
              int i=0;
              return [
                pw.Text('Order Reports', style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                    headers: ['No', 'Name', 'Owner Of Event','Phone','Address','Type Of Event',
                    'Type Of Building','Created By','Date','Deposit','Total','Status'],
                    data: req.map((it){
                      i++;
                      return [
                        i.toString(),
                        it.name.toString(),
                        it.ownerOfevent.toString(),
                        it.phone.toString(),
                        it.address.toString(),
                        it.typeOfEvent.toString(),
                        it.typeOfBuilding.toString(),
                        it.createby.toString(),
                        it.date.toString(),
                        it.deposite.toString(),
                        it.total.toString(),
                        it.status.toString(),
                      ];
                    }).toList()
                )
              ];
            }
        )
    );
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/orderreports.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(path)], text: 'order Reports PDF File');
  }
  catch(e){
    ErrorCustom(context,e.toString());
  }
}

Future<void> OrderexportToExcel(BuildContext context,List<ReqDataModel> req) async {
  try{
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    List<CellValue> row=[
      TextCellValue("NO"),
      TextCellValue("Name"),
      TextCellValue("Owner Of Event"),
      TextCellValue("Phone"),
      TextCellValue("Address"),
      TextCellValue("Type Of Event"),
      TextCellValue("Type Of Building"),
      TextCellValue("Created By"),
      TextCellValue("Date"),
      TextCellValue("Deposit"),
      TextCellValue("Total"),
      TextCellValue("Status"),
    ];
    sheet.appendRow(row);
    for(int i=0;i<req.length;i++){
      List<CellValue> row=[
        TextCellValue((i+1).toString()),
        TextCellValue(req[i].name),
        TextCellValue(req[i].ownerOfevent.toString()),
        TextCellValue(req[i].phone.toString()),
        TextCellValue(req[i].address.toString()),
        TextCellValue(req[i].typeOfEvent.toString()),
        TextCellValue(req[i].typeOfBuilding.toString()),
        TextCellValue(req[i].createby.toString()),
        TextCellValue(req[i].date.toString()),
        TextCellValue(req[i].deposite.toString()),
        TextCellValue(req[i].total.toString()),
        TextCellValue(req[i].status.toString()),
      ];
      sheet.appendRow(row);
    }
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/orderreports.xlsx';
    final file = File(path)..createSync(recursive: true);
    file.writeAsBytesSync(excel.encode()!);
    await Share.shareXFiles([XFile(path)], text: 'order Reports Excel File');
  }
  catch(e){
    ErrorCustom(context,e.toString());
  }
}