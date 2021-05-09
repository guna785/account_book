import 'package:account_book/Models/ListViewModel.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';

const PdfColor green = PdfColor.fromInt(0xff9ce5d0);
const PdfColor lightGreen = PdfColor.fromInt(0xffcdf1e7);
const sep = 120.0;


class ExportToPDF{

  static void export(List<ListViewModel> listDoc,String book,BuildContext context) async{
    final tableHeaders = [
      'Date#',
      'Reason',
      'Credit',
      'Debit',
      'Balance'
    ];

    if(listDoc.length>0){
      final doc = pw.Document(title: 'Income and Expense', author: 'David PHAM-VAN');

      var r=listDoc.length.remainder(10);
      var q=listDoc.length>10? (listDoc.length-r)/10:0;

      var dstart=0;
      final profileImage = pw.MemoryImage(
        (await rootBundle.load('assets/Icons/icon.png')).buffer.asUint8List(),
      );
      final pageTheme = await _myPageTheme(PdfPageFormat.a4);
      doc.addPage(
        pw.MultiPage(
          pageTheme: pageTheme,
          build: (pw.Context context) => [
            pw.Partitions(
              children: [
                pw.Partition(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Container(
                        padding: const pw.EdgeInsets.only(left: 30, bottom: 20),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            pw.Text('Income and Expense',
                                textScaleFactor: 2,
                                style: pw.Theme.of(context)
                                    .defaultTextStyle
                                    .copyWith(fontWeight: pw.FontWeight.bold)),
                            pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
                            pw.Text(book,
                                textScaleFactor: 1.2,
                                style: pw.Theme.of(context)
                                    .defaultTextStyle
                                    .copyWith(
                                    fontWeight: pw.FontWeight.bold,
                                    color: green)),
                            pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                            pw.Center(
                                child: pw.Column(
                                    children: [
                                      pw.Table.fromTextArray(
                                        border: null,
                                        cellAlignment: pw.Alignment.centerLeft,
                                        headerDecoration: pw.BoxDecoration(
                                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                                          color: PdfColors.orangeAccent,
                                        ),
                                        headerHeight: 25,
                                        cellHeight: 40,
                                        cellAlignments: {
                                          0: pw.Alignment.centerLeft,
                                          1: pw.Alignment.centerLeft,
                                          2: pw.Alignment.centerRight,
                                          3: pw.Alignment.center,
                                          4: pw.Alignment.centerRight,
                                        },
                                        headerStyle: pw.TextStyle(
                                          color: PdfColors.white,
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                        cellStyle: const pw.TextStyle(
                                          color: PdfColors.blueGrey800,
                                          fontSize: 10,
                                        ),
                                        rowDecoration: pw.BoxDecoration(
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                              color: PdfColors.blueGrey900,
                                              width: .5,
                                            ),
                                          ),
                                        ),
                                        headers: List<String>.generate(
                                          tableHeaders.length,
                                              (col) => tableHeaders[col],
                                        ),
                                        data: List<List<String>>.generate(
                                          q==0?listDoc.length:10,
                                              (row) => List<String>.generate(
                                            tableHeaders.length,
                                                (col) {

                                              switch (col) {
                                                case 0:
                                                  return DateFormat('yyyy-MM-dd').format(listDoc[row].transactionDate).toString() ;
                                                case 1:
                                                  return listDoc[row].reason;
                                                case 2:
                                                  return listDoc[row].transType==0?listDoc[row].amount.toString():"-";
                                                case 3:
                                                  return listDoc[row].transType==0?"-":listDoc[row].amount.toString();
                                                case 4:
                                                  return listDoc[row].balance.toString();
                                              }
                                              return '';
                                            },
                                          ),
                                        ),
                                      )
                                    ]
                                )
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),

              ],
            ),

          ],
        ),
      );
      q--;
      if(listDoc.length<10){
        r=0;
      }
      while(q>0){
        dstart+=10;
        doc.addPage(
          pw.MultiPage(
            pageTheme: pageTheme,
            build: (pw.Context context) => [
              pw.Partitions(
                children: [
                  pw.Partition(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Container(
                          padding: const pw.EdgeInsets.only(left: 30, bottom: 20),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: <pw.Widget>[
                              pw.Text('Income and Expense',
                                  textScaleFactor: 2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(fontWeight: pw.FontWeight.bold)),
                              pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
                              pw.Text(book,
                                  textScaleFactor: 1.2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(
                                      fontWeight: pw.FontWeight.bold,
                                      color: green)),
                              pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                              pw.Center(
                                  child: pw.Column(
                                      children: [
                                        pw.Table.fromTextArray(
                                          border: null,
                                          cellAlignment: pw.Alignment.centerLeft,
                                          headerDecoration: pw.BoxDecoration(
                                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                                            color: PdfColors.orangeAccent,
                                          ),
                                          headerHeight: 25,
                                          cellHeight: 40,
                                          cellAlignments: {
                                            0: pw.Alignment.centerLeft,
                                            1: pw.Alignment.centerLeft,
                                            2: pw.Alignment.centerRight,
                                            3: pw.Alignment.center,
                                            4: pw.Alignment.centerRight,
                                          },
                                          headerStyle: pw.TextStyle(
                                            color: PdfColors.white,
                                            fontSize: 10,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                          cellStyle: const pw.TextStyle(
                                            color: PdfColors.blueGrey800,
                                            fontSize: 10,
                                          ),
                                          rowDecoration: pw.BoxDecoration(
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                color: PdfColors.blueGrey900,
                                                width: .5,
                                              ),
                                            ),
                                          ),
                                          headers: List<String>.generate(
                                            tableHeaders.length,
                                                (col) => tableHeaders[col],
                                          ),
                                          data: List<List<String>>.generate(
                                            10,
                                                (row) => List<String>.generate(
                                              tableHeaders.length,
                                                  (col) {

                                                switch (col) {
                                                  case 0:
                                                    return  DateFormat('yyyy-MM-dd').format(listDoc[row+dstart].transactionDate).toString() ;
                                                  case 1:
                                                    return listDoc[row+dstart].reason;
                                                  case 2:
                                                    return listDoc[row+dstart].transType==0?listDoc[row+dstart].amount.toString():"-";
                                                  case 3:
                                                    return listDoc[row+dstart].transType==0?"-":listDoc[row+dstart].amount.toString();
                                                  case 4:
                                                    return listDoc[row+dstart].balance.toString();
                                                }
                                                return '';
                                              },
                                            ),
                                          ),
                                        )
                                      ]
                                  )
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),

            ],
          ),
        );
        q--;
      }
      if(r>0){
        dstart=dstart+ 10;
        doc.addPage(
          pw.MultiPage(
            pageTheme: pageTheme,
            build: (pw.Context context) => [
              pw.Partitions(
                children: [
                  pw.Partition(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Container(
                          padding: const pw.EdgeInsets.only(left: 30, bottom: 20),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: <pw.Widget>[
                              pw.Text('Income and Expense',
                                  textScaleFactor: 2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(fontWeight: pw.FontWeight.bold)),
                              pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
                              pw.Text(book,
                                  textScaleFactor: 1.2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(
                                      fontWeight: pw.FontWeight.bold,
                                      color: green)),
                              pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                              pw.Center(
                                  child: pw.Column(
                                      children: [
                                        pw.Table.fromTextArray(
                                          border: null,
                                          cellAlignment: pw.Alignment.centerLeft,
                                          headerDecoration: pw.BoxDecoration(
                                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                                            color: PdfColors.orangeAccent,
                                          ),
                                          headerHeight: 25,
                                          cellHeight: 40,
                                          cellAlignments: {
                                            0: pw.Alignment.centerLeft,
                                            1: pw.Alignment.centerLeft,
                                            2: pw.Alignment.centerRight,
                                            3: pw.Alignment.center,
                                            4: pw.Alignment.centerRight,
                                          },
                                          headerStyle: pw.TextStyle(
                                            color: PdfColors.white,
                                            fontSize: 10,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                          cellStyle: const pw.TextStyle(
                                            color: PdfColors.blueGrey800,
                                            fontSize: 10,
                                          ),
                                          rowDecoration: pw.BoxDecoration(
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                color: PdfColors.blueGrey900,
                                                width: .5,
                                              ),
                                            ),
                                          ),
                                          headers: List<String>.generate(
                                            tableHeaders.length,
                                                (col) => tableHeaders[col],
                                          ),
                                          data: List<List<String>>.generate(
                                            r,
                                                (row) => List<String>.generate(
                                              tableHeaders.length,
                                                  (col) {

                                                switch (col) {
                                                  case 0:
                                                    return  DateFormat('yyyy-MM-dd').format(listDoc[row+dstart].transactionDate).toString() ;
                                                  case 1:
                                                    return listDoc[row+dstart].reason;
                                                  case 2:
                                                    return listDoc[row+dstart].transType==0?listDoc[row+dstart].amount.toString():"-";
                                                  case 3:
                                                    return listDoc[row+dstart].transType==0?"-":listDoc[row+dstart].amount.toString();
                                                  case 4:
                                                    return listDoc[row+dstart].balance.toString();
                                                }
                                                return '';
                                              },
                                            ),
                                          ),
                                        )
                                      ]
                                  )
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),

            ],
          ),
        );
      }
      final path= await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);
      final file = File( path+'/Report'+DateTime.now().hashCode.toString()+'.pdf');
      await file.writeAsBytes(await doc.save());
      showDialog(context:context,
          builder: (ctx)=>AlertDialog(
            scrollable: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: Colors.deepOrange,
              ),
            ),
            title: Text("Success !!!..",style: TextStyle(color: Colors.green)),
            content: Text("PDF Exported Successfully ...!!!"),
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
            content: Text("No Data Available to Export ...!!!"),
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
  static void exportAndShare(List<ListViewModel> listDoc,String book,BuildContext context) async{
    final tableHeaders = [
      'Date#',
      'Reason',
      'Credit',
      'Debit',
      'Balance'
    ];

    if(listDoc.length>0){
      final doc = pw.Document(title: 'Income and Expense', author: 'David PHAM-VAN');

      var r=listDoc.length.remainder(10);
      var q=listDoc.length>10? (listDoc.length-r)/10:0;
      var dstart=0;
      final profileImage = pw.MemoryImage(
        (await rootBundle.load('assets/Icons/icon.png')).buffer.asUint8List(),
      );
      final pageTheme = await _myPageTheme(PdfPageFormat.a4);
      doc.addPage(
        pw.MultiPage(
          pageTheme: pageTheme,
          build: (pw.Context context) => [
            pw.Partitions(
              children: [
                pw.Partition(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Container(
                        padding: const pw.EdgeInsets.only(left: 30, bottom: 20),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            pw.Text('Income and Expense',
                                textScaleFactor: 2,
                                style: pw.Theme.of(context)
                                    .defaultTextStyle
                                    .copyWith(fontWeight: pw.FontWeight.bold)),
                            pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
                            pw.Text(book,
                                textScaleFactor: 1.2,
                                style: pw.Theme.of(context)
                                    .defaultTextStyle
                                    .copyWith(
                                    fontWeight: pw.FontWeight.bold,
                                    color: green)),
                            pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                            pw.Center(
                                child: pw.Column(
                                    children: [
                                      pw.Table.fromTextArray(
                                        border: null,
                                        cellAlignment: pw.Alignment.centerLeft,
                                        headerDecoration: pw.BoxDecoration(
                                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                                          color: PdfColors.orangeAccent,
                                        ),
                                        headerHeight: 25,
                                        cellHeight: 40,
                                        cellAlignments: {
                                          0: pw.Alignment.centerLeft,
                                          1: pw.Alignment.centerLeft,
                                          2: pw.Alignment.centerRight,
                                          3: pw.Alignment.center,
                                          4: pw.Alignment.centerRight,
                                        },
                                        headerStyle: pw.TextStyle(
                                          color: PdfColors.white,
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                        cellStyle: const pw.TextStyle(
                                          color: PdfColors.blueGrey800,
                                          fontSize: 10,
                                        ),
                                        rowDecoration: pw.BoxDecoration(
                                          border: pw.Border(
                                            bottom: pw.BorderSide(
                                              color: PdfColors.blueGrey900,
                                              width: .5,
                                            ),
                                          ),
                                        ),
                                        headers: List<String>.generate(
                                          tableHeaders.length,
                                              (col) => tableHeaders[col],
                                        ),
                                        data: List<List<String>>.generate(
                                          q==0?r:10,
                                              (row) => List<String>.generate(
                                            tableHeaders.length,
                                                (col) {

                                              switch (col) {
                                                case 0:
                                                  return DateFormat('yyyy-MM-dd').format(listDoc[row].transactionDate).toString() ;
                                                case 1:
                                                  return listDoc[row].reason;
                                                case 2:
                                                  return listDoc[row].transType==0?listDoc[row].amount.toString():"-";
                                                case 3:
                                                  return listDoc[row].transType==0?"-":listDoc[row].amount.toString();
                                                case 4:
                                                  return listDoc[row].balance.toString();
                                              }
                                              return '';
                                            },
                                          ),
                                        ),
                                      )
                                    ]
                                )
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),

              ],
            ),

          ],
        ),
      );
      q--;
      if(listDoc.length<10){
        r=0;
      }
      while(q>0){
        dstart+=10;
        doc.addPage(
          pw.MultiPage(
            pageTheme: pageTheme,
            build: (pw.Context context) => [
              pw.Partitions(
                children: [
                  pw.Partition(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Container(
                          padding: const pw.EdgeInsets.only(left: 30, bottom: 20),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: <pw.Widget>[
                              pw.Text('Income and Expense',
                                  textScaleFactor: 2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(fontWeight: pw.FontWeight.bold)),
                              pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
                              pw.Text(book,
                                  textScaleFactor: 1.2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(
                                      fontWeight: pw.FontWeight.bold,
                                      color: green)),
                              pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                              pw.Center(
                                  child: pw.Column(
                                      children: [
                                        pw.Table.fromTextArray(
                                          border: null,
                                          cellAlignment: pw.Alignment.centerLeft,
                                          headerDecoration: pw.BoxDecoration(
                                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                                            color: PdfColors.orangeAccent,
                                          ),
                                          headerHeight: 25,
                                          cellHeight: 40,
                                          cellAlignments: {
                                            0: pw.Alignment.centerLeft,
                                            1: pw.Alignment.centerLeft,
                                            2: pw.Alignment.centerRight,
                                            3: pw.Alignment.center,
                                            4: pw.Alignment.centerRight,
                                          },
                                          headerStyle: pw.TextStyle(
                                            color: PdfColors.white,
                                            fontSize: 10,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                          cellStyle: const pw.TextStyle(
                                            color: PdfColors.blueGrey800,
                                            fontSize: 10,
                                          ),
                                          rowDecoration: pw.BoxDecoration(
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                color: PdfColors.blueGrey900,
                                                width: .5,
                                              ),
                                            ),
                                          ),
                                          headers: List<String>.generate(
                                            tableHeaders.length,
                                                (col) => tableHeaders[col],
                                          ),
                                          data: List<List<String>>.generate(
                                            10,
                                                (row) => List<String>.generate(
                                              tableHeaders.length,
                                                  (col) {

                                                switch (col) {
                                                  case 0:
                                                    return  DateFormat('yyyy-MM-dd').format(listDoc[row+dstart].transactionDate).toString() ;
                                                  case 1:
                                                    return listDoc[row+dstart].reason;
                                                  case 2:
                                                    return listDoc[row+dstart].transType==0?listDoc[row+dstart].amount.toString():"-";
                                                  case 3:
                                                    return listDoc[row+dstart].transType==0?"-":listDoc[row+dstart].amount.toString();
                                                  case 4:
                                                    return listDoc[row+dstart].balance.toString();
                                                }
                                                return '';
                                              },
                                            ),
                                          ),
                                        )
                                      ]
                                  )
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),

            ],
          ),
        );
        q--;
      }
      if(r>0){
        dstart+=10;
        doc.addPage(
          pw.MultiPage(
            pageTheme: pageTheme,
            build: (pw.Context context) => [
              pw.Partitions(
                children: [
                  pw.Partition(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Container(
                          padding: const pw.EdgeInsets.only(left: 30, bottom: 20),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: <pw.Widget>[
                              pw.Text('Income and Expense',
                                  textScaleFactor: 2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(fontWeight: pw.FontWeight.bold)),
                              pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
                              pw.Text(book,
                                  textScaleFactor: 1.2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(
                                      fontWeight: pw.FontWeight.bold,
                                      color: green)),
                              pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
                              pw.Center(
                                  child: pw.Column(
                                      children: [
                                        pw.Table.fromTextArray(
                                          border: null,
                                          cellAlignment: pw.Alignment.centerLeft,
                                          headerDecoration: pw.BoxDecoration(
                                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                                            color: PdfColors.orangeAccent,
                                          ),
                                          headerHeight: 25,
                                          cellHeight: 40,
                                          cellAlignments: {
                                            0: pw.Alignment.centerLeft,
                                            1: pw.Alignment.centerLeft,
                                            2: pw.Alignment.centerRight,
                                            3: pw.Alignment.center,
                                            4: pw.Alignment.centerRight,
                                          },
                                          headerStyle: pw.TextStyle(
                                            color: PdfColors.white,
                                            fontSize: 10,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                          cellStyle: const pw.TextStyle(
                                            color: PdfColors.blueGrey800,
                                            fontSize: 10,
                                          ),
                                          rowDecoration: pw.BoxDecoration(
                                            border: pw.Border(
                                              bottom: pw.BorderSide(
                                                color: PdfColors.blueGrey900,
                                                width: .5,
                                              ),
                                            ),
                                          ),
                                          headers: List<String>.generate(
                                            tableHeaders.length,
                                                (col) => tableHeaders[col],
                                          ),
                                          data: List<List<String>>.generate(
                                            r,
                                                (row) => List<String>.generate(
                                              tableHeaders.length,
                                                  (col) {

                                                switch (col) {
                                                  case 0:
                                                    return  DateFormat('yyyy-MM-dd').format(listDoc[row+dstart].transactionDate).toString() ;
                                                  case 1:
                                                    return listDoc[row+dstart].reason;
                                                  case 2:
                                                    return listDoc[row+dstart].transType==0?listDoc[row+dstart].amount.toString():"-";
                                                  case 3:
                                                    return listDoc[row+dstart].transType==0?"-":listDoc[row+dstart].amount.toString();
                                                  case 4:
                                                    return listDoc[row+dstart].balance.toString();
                                                }
                                                return '';
                                              },
                                            ),
                                          ),
                                        )
                                      ]
                                  )
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),

            ],
          ),
        );
      }
      final path= await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);
      var pathString=path+'/Report'+DateTime.now().hashCode.toString()+'.pdf';
      final file = File(pathString);
      await file.writeAsBytes(await doc.save());
      Share.shareFiles(['$pathString'], text: 'InCome and ExPense Report');
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
            content: Text("No Data Available to Share ...!!!"),
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
  static Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
    final bgShape = await rootBundle.loadString('assets/resume.svg');

    format = format.applyMargin(
        left: 2.0 * PdfPageFormat.cm,
        top: 4.0 * PdfPageFormat.cm,
        right: 2.0 * PdfPageFormat.cm,
        bottom: 2.0 * PdfPageFormat.cm);
    return pw.PageTheme(
      pageFormat: format,
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Regular.ttf')),
        bold: pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Bold.ttf')),
        icons: pw.Font.ttf(await rootBundle.load('assets/fonts/OpenSans-Light.ttf')),
      ),
      buildBackground: (pw.Context context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Stack(
            children: [
              pw.Positioned(
                child: pw.SvgImage(svg: bgShape),
                left: 0,
                top: 0,
              ),
              pw.Positioned(
                child: pw.Transform.rotate(
                    angle: pi, child: pw.SvgImage(svg: bgShape)),
                right: 0,
                bottom: 0,
              ),
            ],
          ),
        );
      },
    );
  }



}
class _UrlText extends pw.StatelessWidget {
  _UrlText(this.text, this.url);

  final String text;
  final String url;

  @override
  pw.Widget build(pw.Context context) {
    return pw.UrlLink(
      destination: url,
      child: pw.Text(text,
          style: const pw.TextStyle(
            decoration: pw.TextDecoration.underline,
            color: PdfColors.blue,
          )),
    );
  }
}



