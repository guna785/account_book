import 'package:account_book/Models/ListViewModel.dart';
import 'package:excel/excel.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:share/share.dart';
import 'dart:async';

class ExportToExcel{
  static void export(List<ListViewModel> listDoc,String book,BuildContext context) async{
    final tableHeaders = [
      'Date#',
      'Reason',
      'Credit',
      'Debit',
      'Balance'
    ];
    if(listDoc.length>0){
      var excel = Excel.createExcel();
      Sheet sh = excel[book];
      for(int i=0;i<tableHeaders.length;i++){
        sh.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i)).value =tableHeaders[i];
      }
      for (int row = 1; row <= listDoc.length; row++) {
        for (int col = 0; col < tableHeaders.length; col++) {
          switch (col) {
            case 0:
              sh.cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col)).value = DateFormat('yyyy-MM-dd').format(listDoc[row-1].transactionDate).toString() ;;
              break;
            case 1:
              sh.cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col)).value = listDoc[row-1].reason;
              break;
            case 2:
              sh.cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col)).value = listDoc[row-1].transType==0?listDoc[row-1].amount.toString():"";
              break;
            case 3:
              sh.cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col)).value = listDoc[row-1].transType==0?"":listDoc[row-1].amount.toString();
              break;
            case 4:
              sh.cell(CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col)).value = listDoc[row-1].balance;
              break;
          }

        }
      }
      var isSet = await excel.setDefaultSheet(sh.sheetName);
      if (isSet) {
        print(sh.sheetName+" is set to default sheet.");
      } else {
        print("Unable to set "+sh.sheetName+" to default sheet.");
      }
      final path= await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS)+'/Report'+DateTime.now().hashCode.toString()+'.xlsx';
      var onValue = await excel.encode();
      File(join(path))
        ..createSync(recursive: true)
        ..writeAsBytesSync(onValue);
      showDialog(context: context,
          builder: (ctx)=>AlertDialog(
            scrollable: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: Colors.deepOrange,
              ),
            ),
            title: Text("Success !!!..",style: TextStyle(color: Colors.green)),
            content: Text("Excel Report Exported Successfully ...!!!"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("okay"),
              ),

            ],
          )
      );
    }
    else{
      showDialog(context: context,
          builder: (ctx)=>AlertDialog(
            scrollable: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: Colors.deepOrange,
              ),
            ),
            title: Text("Warning !!!..",style: TextStyle(color: Colors.deepOrangeAccent)),
            content: Text("No Records to Export ...!!!"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("okay"),
              ),

            ],
          )
      );
    }
  }
  static void exportAndShare(List<ListViewModel> listDoc,String book,BuildContext context) async {
    final tableHeaders = [
      'Date#',
      'Reason',
      'Credit',
      'Debit',
      'Balance'
    ];
    if (listDoc.length > 0) {
      var excel = Excel.createExcel();
      Sheet sh = excel[book];
      for (int i = 0; i < tableHeaders.length; i++) {
        sh
            .cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i))
            .value = tableHeaders[i];
      }
      for (int row = 1; row <= listDoc.length; row++) {
        for (int col = 0; col < tableHeaders.length; col++) {
          switch (col) {
            case 0:
              sh
                  .cell(
                  CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                  .value = DateFormat('yyyy-MM-dd').format(listDoc[row-1].transactionDate).toString() ;
              break;
            case 1:
              sh
                  .cell(
                  CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                  .value = listDoc[row - 1].reason;
              break;
            case 2:
              sh
                  .cell(
                  CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                  .value = listDoc[row-1].transType==0?listDoc[row-1].amount.toString():"";
              break;
            case 3:
              sh
                  .cell(
                  CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                  .value =listDoc[row-1].transType==0?"":listDoc[row-1].amount.toString();
              break;
            case 4:
              sh
                  .cell(
                  CellIndex.indexByColumnRow(rowIndex: row, columnIndex: col))
                  .value = listDoc[row - 1].balance;
              break;
          }
        }
      }
      var isSet = await excel.setDefaultSheet(sh.sheetName);
      if (isSet) {
        print(sh.sheetName + " is set to default sheet.");
      } else {
        print("Unable to set " + sh.sheetName + " to default sheet.");
      }
      final path = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS) + '/Report' + DateTime
          .now()
          .hashCode
          .toString() + '.xlsx';
      var onValue = await excel.encode();
      File(join(path))
        ..createSync(recursive: true)
        ..writeAsBytesSync(onValue);
      Share.shareFiles(['$path'], text: 'InCome and ExPense Report');
    }
    else {
      showDialog(context: context,
          builder: (ctx) =>
              AlertDialog(
                scrollable: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                    color: Colors.deepOrange,
                  ),
                ),
                title: Text("Warning !!!..",
                    style: TextStyle(color: Colors.deepOrangeAccent)),
                content: Text("No Records to Export ...!!!"),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text("okay"),
                  ),

                ],
              )
      );
    }
  }
}