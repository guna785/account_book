import 'package:account_book/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'DataBase/DBhelper.dart';
import 'DataBase/Models/User.dart';
import 'Login.dart';
import 'app_localisation.dart';

final storage = new FlutterSecureStorage();

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  DBHelper dbHelper;

  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalisation.of(context).getTranslationKey("AppName")),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          AppLocalisation.of(context)
                              .getTranslationKey("AppName"),
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 30),
                        )),
                    Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          AppLocalisation.of(context)
                              .getTranslationKey("registerButton"),
                          style: TextStyle(fontSize: 20),
                        )),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppLocalisation.of(context)
                              .getTranslationKey("RegisterFieldsName"),
                        ),
                        validator: (text) {
                          if (!(text.length > 3 && text.isNotEmpty)) {
                            return AppLocalisation.of(context)
                                .getTranslationKey("RegisterFieldsErrorName");
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextFormField(
                        controller: userNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppLocalisation.of(context)
                              .getTranslationKey("RegisterFieldsUsername"),
                        ),
                        validator: (text) {
                          if (!(text.length > 3 && text.isNotEmpty)) {
                            return AppLocalisation.of(context)
                                .getTranslationKey(
                                    "RegisterFieldsErrorUsername");
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppLocalisation.of(context)
                              .getTranslationKey("RegisterFieldsPassword"),
                        ),
                        validator: (text) {
                          if (!(text.length >= 6 && text.isNotEmpty)) {
                            return AppLocalisation.of(context)
                                .getTranslationKey(
                                    "RegisterFieldsErrorPassword");
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppLocalisation.of(context)
                              .getTranslationKey("RegisterFieldsEmail"),
                        ),
                        validator: (text) {
                          if (!(text.contains('@') && text.isNotEmpty)) {
                            return AppLocalisation.of(context)
                                .getTranslationKey("RegisterFieldsErrorEmail");
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: phoneController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppLocalisation.of(context)
                              .getTranslationKey("RegisterFieldsPhone"),
                        ),
                        validator: (text) {
                          if (!(text.length == 10 || text.isNotEmpty)) {
                            return AppLocalisation.of(context)
                                .getTranslationKey("RegisterFieldsErrorPhone");
                          }
                          return null;
                        },
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        //forgot password screen
                      },
                      textColor: Colors.blue,
                      child: Text(''),
                    ),
                    Container(
                        height: 50,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.deepOrangeAccent,
                          child: Text(AppLocalisation.of(context)
                              .getTranslationKey("registerButton")),
                          onPressed: () async {
                            final isValid = _form.currentState.validate();
                            if (!isValid) {
                              return;
                            }
                            List<User> users = await dbHelper.getUsers();
                            users = users
                                .where((element) =>
                                    element.username == userNameController.text)
                                .toList();
                            if (users.length == 0) {
                              User u = await dbHelper.addUser(User(
                                  null,
                                  nameController.text,
                                  userNameController.text,
                                  passwordController.text,
                                  phoneController.text,
                                  emailController.text,
                                  DateTime.now()));
                              await storage.write(
                                  key: 'userName',
                                  value: userNameController.text);
                              await storage.write(
                                  key: 'userID', value: u.id.toString());
                              await storage.write(
                                  key: 'email', value: emailController.text);
                              await storage.write(
                                  key: 'phone', value: phoneController.text);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home()),
                              );
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        title: Text(
                                            AppLocalisation.of(context)
                                                .getTranslationKey(
                                                    "AlertWarningHeading"),
                                            style:
                                                TextStyle(color: Colors.red)),
                                        content: Text(AppLocalisation.of(
                                                context)
                                            .getTranslationKey(
                                                "AlertWarningRegisterBody")),
                                        actions: <Widget>[
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                            },
                                            child: Text("okay"),
                                          ),
                                        ],
                                      ));
                            }
                          },
                        )),
                    Container(
                        child: Row(
                      children: <Widget>[
                        Text(AppLocalisation.of(context)
                            .getTranslationKey("loginButtonText")),
                        FlatButton(
                          textColor: Colors.deepOrange,
                          child: Text(
                            AppLocalisation.of(context)
                                .getTranslationKey("loginButtonName"),
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            //signup screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          },
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ))
                  ],
                ))));
  }
}
