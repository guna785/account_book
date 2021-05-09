import 'package:account_book/CongifData/MyConfigs.dart';
import 'package:account_book/DataBase/DBhelper.dart';
import 'package:account_book/DataBase/Models/AccountBook.dart';
import 'package:account_book/DataBase/Models/InExp.dart';
import 'package:account_book/Models/FilterChipData.dart';
import 'package:account_book/Models/ListViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../app_localisation.dart';

final storage = new FlutterSecureStorage();
String userName = "", Name = "", email = "", phone = "";
int userId, bookId;
int income = 0, expense = 0,  totalRecordCount = 0;
DBHelper dbHelper;
List<ListViewModel> listOfData = [];
TextEditingController searchTextEditController = TextEditingController();
class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  TextEditingController inAmtController = TextEditingController();
  TextEditingController inReasonController = TextEditingController();
  TextEditingController expAmtController = TextEditingController();
  TextEditingController expReasonController = TextEditingController();
  TextEditingController InExpDateController = TextEditingController();
  TextEditingController editAmtController = TextEditingController();
  TextEditingController editReasonController = TextEditingController();
  TextEditingController accountController = TextEditingController();

  final double spacing = 8;
  bool isFilterEnabled = false;
  String selectedFilter = "";
  String filterContext = "";
  List<DateTime> filterDates = [DateTime.now(), DateTime.now()];

  List<ChoiceChipData> filterList = [
    ChoiceChipData(
      label: 'Today',
      isSelected: false,
      selectedColor: Colors.deepOrangeAccent,
      textColor: Colors.white,
    ),
    ChoiceChipData(
      label: 'This Week',
      isSelected: false,
      selectedColor: Colors.deepOrangeAccent,
      textColor: Colors.white,
    ),
    ChoiceChipData(
      label: 'Last Week',
      isSelected: false,
      selectedColor: Colors.deepOrangeAccent,
      textColor: Colors.white,
    ),
    ChoiceChipData(
      label: 'This Month',
      isSelected: false,
      selectedColor: Colors.deepOrangeAccent,
      textColor: Colors.white,
    ),
    ChoiceChipData(
      label: 'Last Month',
      isSelected: false,
      selectedColor: Colors.deepOrangeAccent,
      textColor: Colors.white,
    ),
    ChoiceChipData(
      label: 'Custom',
      isSelected: false,
      selectedColor: Colors.deepOrangeAccent,
      textColor: Colors.white,
    )
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              child: Text('$selectedFilter'),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black38.withAlpha(10),
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: searchTextEditController,
                      decoration: InputDecoration(
                        hintText: AppLocalisation.of(this.context)
                            .getTranslationKey("HomeDashboardSearchText"),
                        hintStyle: TextStyle(
                          color: Colors.black.withAlpha(120),
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (String keyword) async {
                        MyConfigs.srch = keyword;
                        MyConfigs.offset = 0;
                      },
                    ),
                  ),
                  Icon(
                    Icons.search,
                    color: Colors.black.withAlpha(120),
                  ),
                  IconButton(
                      onPressed: () async {
                        showDialog(
                            context: this.context,
                            builder: (BuildContext context) {
                              return _dateFilterDialog();
                            });
                      },
                      icon: Icon(
                        Icons.filter_alt,
                        color: Colors.deepOrangeAccent,
                      ))
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 10),
                padding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                child: Table(
                  children: [
                    TableRow(children: [
                      Card(
                        elevation: 10.0,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(AppLocalisation.of(this.context)
                                  .getTranslationKey("HomeDashboardIncome")),
                              leading: Icon(
                                Icons.add,
                                color: Colors.green,
                              ),
                            ),
                            ListTile(
                              title: Text('$income'),
                              leading: Icon(
                                MdiIcons.currencyInr,
                                color: Colors.green,
                              ),
                            )
                          ],
                        ),
                      ),
                      Card(
                        elevation: 10.0,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(AppLocalisation.of(this.context)
                                  .getTranslationKey("HomeDashboardExpense")),
                              leading: Icon(
                                Icons.minimize,
                                color: Colors.red,
                              ),
                            ),
                            ListTile(
                              title: Text('$expense'),
                              leading: Icon(
                                MdiIcons.currencyInr,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                      )
                    ])
                  ],
                )),
            FutureBuilder<List<dynamic>>(
              future: _fetchData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List data = snapshot.data;
                  return Expanded(child: _dataListView(data), );
                } else if (snapshot.hasError) {
                  return Text('No Data Found');
                }
                return Center(child: CircularProgressIndicator());
              },
            )
          ],
        ),
      ),
      persistentFooterButtons: <Widget>[
        PopupMenuButton<bookItem>(
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  border: Border.all(color: Colors.orangeAccent),
                  borderRadius: BorderRadius.circular(10.0)),
              padding: EdgeInsets.all(10.0),
              child: Text(MyConfigs.bItem.name, style: TextStyle(color: Colors.white))),
          onSelected: (value) async {
            if (value.name != "New Book") {
              setState(() {
                MyConfigs.bItem = value;
              });
            } else {
              TextEditingController accountController = TextEditingController();
              showDialog(
                  context: this.context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return _accountCreateDialog();
                  });
            }
          },
          itemBuilder: (BuildContext context) {
            return MyConfigs.selectBooks.reversed.toList().map((bookItem choice) {
              return PopupMenuItem<bookItem>(
                value: choice,
                child: ListTile(title: Text(choice.name)),
              );
            }).toList();
          },
        ),
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
          onPressed: () {
            showDialog(
                context: this.context,
                builder: (BuildContext context) {
                  return _addIncomeDialog();
                });
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
          onPressed: () {
            showDialog(
                context: this.context,
                builder: (BuildContext context) {
                  return _addExpenseDialog();
                });
          },
          child: Icon(
            MdiIcons.minus,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<List<ListViewModel>> _fetchData() async {
    Map<String, String> allValues = await storage.readAll();
    setState(() {
      userName = allValues['userName'];
      email = allValues['email'];
      userId = int.parse(allValues['userID']);
      phone = allValues['phone'];
    });

    print(isFilterEnabled);
    print(filterContext);
    dbHelper
        .getInExpByCondition(userId, MyConfigs.bItem.id, MyConfigs.srch, MyConfigs.limit, MyConfigs.offset,
        isFilterEnabled, filterContext, filterDates)
        .then((value) => setState(() {
      value.forEach((note) {
        income = note.income;
        expense = note.expense;
        totalRecordCount = note.recodCount;
        MyConfigs.offset == 0
            ? listOfData = note.inexp
            : listOfData.addAll(note.inexp);
      });
    }));
    return listOfData;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = DBHelper();
  }
  ListView _dataListView(data) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(child: Center(

          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(
                    color: data[index].transType == 0
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    width: 2.0)),
            // color: listOfData[index].transType==0?Colors.greenAccent:Colors.orangeAccent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                        child: ListTile(
                          leading: Icon(
                            data[index].transType == 0
                                ? MdiIcons.creditCardPlus
                                : MdiIcons.creditCardMinus,
                            color: data[index].transType == 0
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text("\u20B9 " + data[index].amount.toString(),
                              style: TextStyle(
                                  color: data[index].transType == 0
                                      ? Colors.green
                                      : Colors.red),
                              textAlign: TextAlign.left),
                          subtitle: Text(data[index].reason),
                        )),
                    Expanded(
                        child: Text(DateFormat.yMMMMd('en_US')
                            .format(data[index].transactionDate)
                            .toString()))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                        child: ListTile(
                          title: Text("Balance"),
                          subtitle:
                          Text("\u20B9 " + data[index].balance.toString()),
                        )),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        final _form =
                        GlobalKey<FormState>(); //for storing form state.
                        editAmtController.clear();
                        editAmtController.text = data[index].amount.toString();
                        editReasonController.clear();
                        editReasonController.text = data[index].reason;
                        InExpDateController.clear();
                        InExpDateController.text = DateFormat('yyyy-MM-dd')
                            .format(data[index].transactionDate)
                            .toString();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                scrollable: true,
                                title: Stack(children: <Widget>[
                                  //_getCloseButton(this.context),
                                  Text(data[index].transType == 0
                                      ? AppLocalisation.of(context)
                                      .getTranslationKey(
                                      "HomeDashboardIncome")
                                      : AppLocalisation.of(context)
                                      .getTranslationKey(
                                      "HomeDashboardExpense")),
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
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Form(
                                    key: _form,
                                    child: Column(
                                      children: <Widget>[
                                        TextFormField(
                                          controller: editAmtController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText:
                                            AppLocalisation.of(context)
                                                .getTranslationKey(
                                                "incomeAddAmount"),
                                            icon: Icon(
                                              MdiIcons.currencyInr,
                                              color: Colors.deepOrangeAccent,
                                            ),
                                          ),
                                          validator: (text) {
                                            if (!(text.isNotEmpty)) {
                                              return AppLocalisation.of(context)
                                                  .getTranslationKey(
                                                  "AddErrorsAmount");
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          controller: editReasonController,
                                          decoration: InputDecoration(
                                            labelText:
                                            AppLocalisation.of(context)
                                                .getTranslationKey(
                                                "incomeAddDetail"),
                                            icon: Icon(
                                              Icons.info,
                                              color: Colors.deepOrangeAccent,
                                            ),
                                          ),
                                          validator: (text) {
                                            if (!(text.isNotEmpty)) {
                                              return AppLocalisation.of(context)
                                                  .getTranslationKey(
                                                  "AddErrorsDetail");
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          readOnly: true,
                                          controller: InExpDateController,
                                          decoration: InputDecoration(
                                            labelText: AppLocalisation.of(
                                                this.context)
                                                .getTranslationKey("inExpDate"),
                                            icon: Icon(
                                              MdiIcons.calendar,
                                              color: Colors.deepOrangeAccent,
                                            ),
                                          ),
                                          validator: (text) {
                                            if (!(text.isNotEmpty)) {
                                              return AppLocalisation.of(
                                                  this.context)
                                                  .getTranslationKey(
                                                  "inExpDateError");
                                            }
                                            return null;
                                          },
                                          onTap: () async {
                                            var date = await showDatePicker(
                                                context: this.context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2100));
                                            InExpDateController.text =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(date)
                                                    .toString();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.green)),
                                      child: Text(AppLocalisation.of(context)
                                          .getTranslationKey(
                                          "incomeAddSubmit")),
                                      onPressed: () async {
                                        final isValid =
                                        _form.currentState.validate();
                                        if (!isValid) {
                                          return;
                                        }
                                        var inEx = await dbHelper.updateInExp(
                                            InExp(
                                                data[index].id,
                                                int.parse(
                                                    editAmtController.text),
                                                data[index].transType,
                                                MyConfigs.bookId,
                                                userId,
                                                editReasonController.text,
                                                DateTime.now(),
                                                DateTime.parse(
                                                    InExpDateController.text),""));
                                        MyConfigs.offset = 0;
                                        InExpDateController.clear();
                                        Navigator.of(context).pop();
                                      })
                                ],
                              );
                            });
                      },
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Stack(children: <Widget>[
                                //_getCloseButton(this.context),
                                Text(
                                    AppLocalisation.of(context)
                                        .getTranslationKey(
                                        "AlertWarningHeading"),
                                    style: TextStyle(color: Colors.red)),
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
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                              content: Text(AppLocalisation.of(context)
                                  .getTranslationKey(
                                  "deleteWarningHeading")),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    dbHelper.deleteInExp(data[index].id);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text("okay"),
                                ),
                              ],
                            ));
                      },
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
          margin: EdgeInsets.only(top:4,bottom: 0,left: 4,right: 4),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        );
      },
    );
  }

  _getCloseButton(context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          alignment: FractionalOffset.topRight,
          child: GestureDetector(
            child: Icon(
              Icons.clear,
              color: Colors.red,
            ),
            onTap: () {
              Navigator.pop(this.context);
            },
          ),
        ),
      ),
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

  _addIncomeDialog() {
    final _form = GlobalKey<FormState>(); //for storing form state.
    InExpDateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
    return AlertDialog(
      scrollable: true,
      shape: _defaultShape(),
      title: Stack(children: <Widget>[
        //_getCloseButton(this.context),
        Text(AppLocalisation.of(this.context)
            .getTranslationKey("incomeAddHeading")),
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
      //title: Text(AppLocalisation.of(this.context).getTranslationKey("incomeAddHeading")),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _form,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: inAmtController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalisation.of(this.context)
                      .getTranslationKey("incomeAddAmount"),
                  icon: Icon(
                    MdiIcons.currencyInr,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
                validator: (text) {
                  if (!(text.isNotEmpty)) {
                    return AppLocalisation.of(this.context)
                        .getTranslationKey("AddErrorsAmount");
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: inReasonController,
                decoration: InputDecoration(
                  labelText: AppLocalisation.of(this.context)
                      .getTranslationKey("incomeAddDetail"),
                  icon: Icon(
                    Icons.info,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
                validator: (text) {
                  if (!(text.isNotEmpty)) {
                    return AppLocalisation.of(this.context)
                        .getTranslationKey("AddErrorsDetail");
                  }
                  return null;
                },
              ),
              TextFormField(
                readOnly: true,
                controller: InExpDateController,
                decoration: InputDecoration(
                  labelText: AppLocalisation.of(this.context)
                      .getTranslationKey("inExpDate"),
                  icon: Icon(
                    MdiIcons.calendar,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
                validator: (text) {
                  if (!(text.isNotEmpty)) {
                    return AppLocalisation.of(this.context)
                        .getTranslationKey("inExpDateError");
                  }
                  return null;
                },
                onTap: () async {
                  var date = await showDatePicker(
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.deepOrangeAccent,
                              // header background color
                              onPrimary: Colors.white,
                              // header text color
                              onSurface: Colors.black, // body text color
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                primary: Colors.deepOrange, // button text color
                              ),
                            ),
                          ),
                          child: child,
                        );
                      },
                      context: this.context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100));
                  InExpDateController.text =
                      DateFormat('yyyy-MM-dd').format(date).toString();
                },
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
              final isValid = _form.currentState.validate();
              if (!isValid) {
                return;
              }
              InExp inEx = await dbHelper.addInExp(InExp(
                  null,
                  int.parse(inAmtController.text),
                  0,
                  MyConfigs.bItem.id,
                  userId,
                  inReasonController.text,
                  DateTime.now(),
                  DateTime.parse(InExpDateController.text),""));
              MyConfigs.offset = 0;
              inAmtController.clear();
              inReasonController.clear();
              InExpDateController.clear();
              Navigator.of(this.context).pop();
            })
      ],
    );
  }

  _addExpenseDialog() {
    final _form = GlobalKey<FormState>(); //for storing form state.
    InExpDateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
    return AlertDialog(
      scrollable: true,
      shape: _defaultShape(),
      title: Stack(children: <Widget>[
        //_getCloseButton(this.context),
        Text(AppLocalisation.of(this.context)
            .getTranslationKey("expenseAddHeading")),
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
      // title: Text(AppLocalisation.of(this.context).getTranslationKey("expenseAddHeading")),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _form,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: expAmtController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalisation.of(this.context)
                      .getTranslationKey("incomeAddAmount"),
                  icon: Icon(
                    MdiIcons.currencyInr,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
                validator: (text) {
                  if (!(text.isNotEmpty)) {
                    return AppLocalisation.of(this.context)
                        .getTranslationKey("AddErrorsAmount");
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: expReasonController,
                decoration: InputDecoration(
                  labelText: AppLocalisation.of(this.context)
                      .getTranslationKey("incomeAddDetail"),
                  icon: Icon(
                    Icons.info,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
                validator: (text) {
                  if (!(text.isNotEmpty)) {
                    return AppLocalisation.of(this.context)
                        .getTranslationKey("AddErrorsDetail");
                  }
                  return null;
                },
              ),
              TextFormField(
                readOnly: true,
                controller: InExpDateController,
                decoration: InputDecoration(
                  labelText: AppLocalisation.of(this.context)
                      .getTranslationKey("inExpDate"),
                  icon: Icon(
                    MdiIcons.calendar,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
                validator: (text) {
                  if (!(text.isNotEmpty)) {
                    return AppLocalisation.of(this.context)
                        .getTranslationKey("inExpDateError");
                  }
                  return null;
                },
                onTap: () async {
                  var date = await showDatePicker(
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.deepOrangeAccent,
                              // header background color
                              onPrimary: Colors.white,
                              // header text color
                              onSurface: Colors.black, // body text color
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                primary: Colors.deepOrange, // button text color
                              ),
                            ),
                          ),
                          child: child,
                        );
                      },
                      context: this.context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100));
                  InExpDateController.text = DateFormat('yyyy-MM-dd')
                      .format(date)
                      .toString(); // date.toString().substring(0,10);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
            child: Text(AppLocalisation.of(this.context)
                .getTranslationKey("expenseAddSubmit")),
            onPressed: () async {
              final isValid = _form.currentState.validate();
              if (!isValid) {
                return;
              }
              InExp inEx = await dbHelper.addInExp(InExp(
                  null,
                  int.parse(expAmtController.text),
                  1,
                  MyConfigs.bItem.id,
                  userId,
                  expReasonController.text,
                  DateTime.now(),
                  DateTime.parse(InExpDateController.text),
                  ""
              ));
              MyConfigs.offset = 0;
              expAmtController.clear();
              expReasonController.clear();
              InExpDateController.clear();
              Navigator.of(this.context).pop();
            })
      ],
    );
  }

  _dateFilterDialog() {
    final _form = GlobalKey<FormState>(); //for storing form state.
    return AlertDialog(
      scrollable: true,
      shape: _defaultShape(),
      title: Stack(children: <Widget>[
        //_getCloseButton(this.context),
        Text("Date Filter"),
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
      // title: Text(AppLocalisation.of(this.context).getTranslationKey("expenseAddHeading")),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          children: [
            buildChoiceChips(),
          ],
        ),
      ),
    );
  }

  Widget buildChoiceChips() => Wrap(
    runSpacing: spacing,
    spacing: spacing,
    children: filterList
        .map((choiceChip) => ChoiceChip(
      label: Text(choiceChip.label),
      labelStyle: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.white),
      onSelected: (isSelected) async {
        if (choiceChip.label == "Custom" && isSelected) {
          /* final List<DateTime> picked = await DateRangePicker.showDatePicker(
              context: this.context,
              initialFirstDate: new DateTime.now(),
              initialLastDate: (new DateTime.now()).add(new Duration(days: 7)),
              firstDate: new DateTime(2015),
              lastDate: new DateTime(DateTime.now().year + 2)
          );*/
          var picked = await showDateRangePicker(
              context: this.context,
              firstDate: DateTime(DateTime.now().year - 5),
              lastDate: DateTime(DateTime.now().year + 5),
              initialDateRange: DateTimeRange(
                end: DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day + 13),
                start: DateTime.now(),
              ),
              builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.deepOrangeAccent,
                        primaryVariant: Colors.deepOrangeAccent,
                        // header background color
                        onPrimary: Colors.white,
                        // header text color
                        onSurface: Colors.black, // body text color
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          primary: Colors
                              .deepOrange, // button text color
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 400.0,
                          ),
                          child: child,
                        )
                      ],
                    ));
              });
          print(picked);
          if (picked != null) {
            print(picked);
            setState(() {
              isFilterEnabled = true;
              filterContext = choiceChip.label;
              filterDates = [picked.start, picked.end];
              selectedFilter = DateFormat.yMMMMd('en_US')
                  .format(picked.start)
                  .toString() +
                  " - " +
                  DateFormat.yMMMMd('en_US')
                      .format(picked.end)
                      .toString();
              filterList = filterList.map((otherChip) {
                final newChip = otherChip.copy(isSelected: false);
                return choiceChip == newChip
                    ? newChip.copy(isSelected: isSelected)
                    : newChip;
              }).toList();
            });
          } else {
            setState(() {
              selectedFilter = "";
              filterContext = "";
              isFilterEnabled = false;
              filterList = filterList.map((otherChip) {
                final newChip = otherChip.copy(isSelected: false);
                return choiceChip == newChip
                    ? newChip.copy(isSelected: false)
                    : newChip;
              }).toList();
            });
          }
        } else {
          setState(() {
            filterList = filterList.map((otherChip) {
              final newChip = otherChip.copy(isSelected: false);
              return choiceChip == newChip
                  ? newChip.copy(isSelected: isSelected)
                  : newChip;
            }).toList();
            selectedFilter = isSelected ? choiceChip.label : "";
            filterContext = isSelected ? choiceChip.label : "";
            isFilterEnabled = isSelected;
          });
        }

        Navigator.of(this.context).pop();
      },
      selected: choiceChip.isSelected,
      selectedColor: Colors.green,
      backgroundColor: Colors.deepOrangeAccent,
    ))
        .toList(),
  );
}
