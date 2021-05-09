import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'CongifData/MyConfigs.dart';
import 'DataBase/DBhelper.dart';
import 'DataBase/Models/AccountBook.dart';
import 'Exporter/ExportToExcel.dart';
import 'Exporter/ExportToPDF.dart';
import 'Models/ListViewModel.dart';
import 'Pages/About.dart';
import 'Pages/Calculator.dart';
import 'Pages/Dashboard.dart';
import 'Pages/Help.dart';
import 'Pages/Profile.dart';
import 'app_localisation.dart';

DBHelper dbHelper;
final storage = new FlutterSecureStorage();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget bodyWidget;
  String userName = "", email = "",appbarTitle="Income Expense";
  int userId;
  TextEditingController accountController = TextEditingController();

  Future _accountData() async {
    Map<String, String> allValues = await storage.readAll();
    setState(() {
      userName = allValues['userName'];
      email = allValues['email'];
      userId = int.parse(allValues['userID']);
      MyConfigs.selectBooks = [bookItem(0, "New Book")];
    });

    List<AccountBook> books = await dbHelper.getBook();
    print(books);
    books = books.where((element) => element.userID == userId).toList();

    books.forEach((element) {
      setState(() {
        MyConfigs.selectBooks.add(bookItem(element.id, element.name));
      });
    });
    if (books.length == 0) {
      showDialog(
          context: this.context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return _accountCreateDialog();
          });
    } else {
      setState(() {
        MyConfigs.book = books[0].name;
        MyConfigs.bookId = books[0].id;
        MyConfigs.bItem = bookItem(books[0].id, books[0].name);
        appbarTitle="Dashboard";
        bodyWidget=Dashboard();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper=DBHelper();
    _accountData();
    bodyWidget = Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$appbarTitle'),
          actions: <Widget>[
            IconButton(
              icon: Icon(MdiIcons.pdfBox),
              onPressed: () async {
                List<ListViewModel> listOfData = [];
                dbHelper
                    .getInExpByCondition(
                        userId,
                        MyConfigs.bItem.id,
                        MyConfigs.srch,
                        MyConfigs.limit,
                        MyConfigs.offset,
                        MyConfigs.isFilterEnabled,
                        MyConfigs.filterContext,
                        MyConfigs.filterDates)
                    .then((value) => value.forEach((note) {
                          listOfData = note.inexp;
                          ExportToPDF.export(
                              listOfData.reversed.toList(), MyConfigs.book, this.context);
                        }));

              },
            ),
            PopupMenuButton<Item>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value.name == "Export Excel") {
                  List<ListViewModel> listOfData = [];
                  dbHelper
                      .getInExpByCondition(
                      userId,
                      MyConfigs.bItem.id,
                      MyConfigs.srch,
                      MyConfigs.limit,
                      MyConfigs.offset,
                      MyConfigs.isFilterEnabled,
                      MyConfigs.filterContext,
                      MyConfigs.filterDates)
                      .then((value) => value.forEach((note) {
                    listOfData = note.inexp;
                    ExportToExcel.export(listOfData.reversed.toList(),
                        MyConfigs.book, this.context);
                  }));
                }
                if (value.name == "Profile") {
                  setState(() {
                    bodyWidget = Profile();
                  });
                }
                if (value.name == "Delete All") {
                  await dbHelper.deleteAll();
                  MyConfigs.selectBooks = [];
                  MyConfigs.selectBooks = [bookItem(0, "New Book")];
                  showDialog(
                      context: this.context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return _accountCreateDialog();
                      });
                }
                if (value.name == "Share") {
                  showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            scrollable: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Colors.deepOrange,
                              ),
                            ),
                            title: Stack(children: <Widget>[
                              //_getCloseButton(this.context),
                              Text(
                                "Share !!",
                                style: TextStyle(color: Colors.deepOrange),
                              ),
                              Align(
                                // These values are based on trial & error method
                                alignment: Alignment(1.05, -1.05),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(this.context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                            content: Container(
                              child: Column(
                                children: [
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.orangeAccent)),
                                      child: ListTile(
                                        title: Text(
                                          "PDF",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        leading: Icon(
                                          MdiIcons.pdfBox,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () async {
                                        List<ListViewModel> listOfData = [];
                                        dbHelper
                                            .getInExpByCondition(
                                            userId,
                                            MyConfigs.bItem.id,
                                            MyConfigs.srch,
                                            MyConfigs.limit,
                                            MyConfigs.offset,
                                            MyConfigs.isFilterEnabled,
                                            MyConfigs.filterContext,
                                            MyConfigs.filterDates)
                                            .then((value) => value.forEach((note) {
                                          listOfData = note.inexp;
                                          ExportToPDF.exportAndShare(
                                              listOfData.reversed.toList(),
                                              MyConfigs.book,
                                              this.context);
                                          Navigator.of(this.context).pop();
                                        }));

                                      }),
                                  Divider(
                                    thickness: 1,
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.orangeAccent)),
                                      child: ListTile(
                                        title: Text(
                                          "Excel",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        leading: Icon(
                                          MdiIcons.microsoftExcel,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () async {
                                        List<ListViewModel> listOfData = [];
                                        dbHelper
                                            .getInExpByCondition(
                                            userId,
                                            MyConfigs.bItem.id,
                                            MyConfigs.srch,
                                            MyConfigs.limit,
                                            MyConfigs.offset,
                                            MyConfigs.isFilterEnabled,
                                            MyConfigs.filterContext,
                                            MyConfigs.filterDates)
                                            .then((value) => value.forEach((note) {
                                          listOfData = note.inexp;

                                          ExportToExcel.exportAndShare(
                                              listOfData.reversed.toList(),
                                              MyConfigs.book,
                                              this.context);
                                          Navigator.of(this.context).pop();
                                        }));


                                        Navigator.of(this.context).pop();
                                      })
                                ],
                              ),
                            ),
                          ));
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  Item(
                      'Profile',
                      Icon(
                        Icons.account_circle,
                        color: Colors.deepOrange,
                      )),
                  Item(
                      'Delete All',
                      Icon(
                        Icons.delete_forever,
                        color: Colors.deepOrange,
                      )),
                  Item(
                      'Export Excel',
                      Icon(
                        MdiIcons.microsoftExcel,
                        color: Colors.deepOrange,
                      )),
                  Item(
                      'Share',
                      Icon(
                        Icons.share,
                        color: Colors.deepOrange,
                      )),
                ].map((Item choice) {
                  return PopupMenuItem<Item>(
                    value: choice,
                    child: ListTile(
                      title: Text(choice.name),
                      leading: choice.icon,
                    ),
                  );
                }).toList();
              },
            )
          ],
        ),
        drawer: Drawer(
          elevation: 10.0,
          child: Column(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text('$userName'),
                accountEmail: Text('$email'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    '$userName',
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                ),
              ),
              ListTile(
                title: Text(AppLocalisation.of(context)
                    .getTranslationKey("DrawerHome")),
                leading: Icon(
                  Icons.home,
                  color: Colors.deepOrange,
                ),
                onTap: () {
                  setState(() {
                    appbarTitle="Dashboard";
                    bodyWidget = Dashboard();
                  });
                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 0.1,
              ),
              ListTile(
                title: Text(AppLocalisation.of(context)
                    .getTranslationKey("DrawerCalculate")),
                leading: Icon(
                  MdiIcons.abacus,
                  color: Colors.deepOrange,
                ),
                onTap: () {
                  setState(() {
                    appbarTitle="EMI Calculator";
                    bodyWidget = Calculator();
                  });
                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 0.1,
              ),
              ListTile(
                title: Text(AppLocalisation.of(context)
                    .getTranslationKey("DrawerAbout")),
                leading: Icon(
                  Icons.info,
                  color: Colors.deepOrange,
                ),
                onTap: () {
                  setState(() {
                    appbarTitle="About";
                    bodyWidget = About();
                  });
                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 0.1,
              ),
              ListTile(
                title: Text(AppLocalisation.of(context)
                    .getTranslationKey("DrawerHelp")),
                leading: Icon(
                  Icons.help,
                  color: Colors.deepOrange,
                ),
                onTap: () {
                  setState(() {
                    appbarTitle="Help";
                    bodyWidget = Help();
                  });
                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 0.1,
              ),
            ],
          ),
        ),
        body:  bodyWidget,
    );
  }

  _accountCreateDialog() {
    return AlertDialog(
      scrollable: true,
      shape: _defaultShape(),
      title: Stack(children: <Widget>[
        //_getCloseButton(this.context),
        Text(
            AppLocalisation.of(this.context).getTranslationKey("addBookTitle")),
        Align(
          // These values are based on trial & error method
          alignment: Alignment(1.05, -1.05),
          child: InkWell(
            onTap: () {
              Navigator.pop(this.context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ]),
      content: Container(
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: accountController,
                decoration: InputDecoration(
                  labelText: AppLocalisation.of(this.context)
                      .getTranslationKey("addBookName"),
                  icon: Icon(
                    MdiIcons.account,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.green)),
            child: Text(AppLocalisation.of(this.context)
                .getTranslationKey("incomeAddSubmit")),
            onPressed: () async {
              var bks = await dbHelper.getBook();
              if (!bks
                  .any((element) => element.name == accountController.text)) {
                AccountBook acbook = await dbHelper.addBook(AccountBook(
                    null, accountController.text, userId, DateTime.now()));
                setState(() {
                  MyConfigs.book = acbook.name;
                  MyConfigs.bookId = acbook.id;
                  MyConfigs.bItem = bookItem(acbook.id, acbook.name);
                  MyConfigs.selectBooks.add(MyConfigs.bItem);
                  accountController.clear();
                  bodyWidget=Dashboard();
                });
              }
              Navigator.of(this.context).pop();
            })
      ],
    );
  }

  ShapeBorder _defaultShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: BorderSide(
        color: Colors.deepOrange,
      ),
    );
  }
}
