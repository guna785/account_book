import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'DataBase/DBhelper.dart';
import 'DataBase/Models/User.dart';
import 'Home.dart';
import 'Register.dart';
import 'app_localisation.dart';

final storage = new FlutterSecureStorage();

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _form = GlobalKey<FormState>(); //for storing form state.
  DBHelper dbHelper;

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
                              .getTranslationKey("loginButton"),
                          style: TextStyle(fontSize: 20),
                        )),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppLocalisation.of(context)
                              .getTranslationKey("LoginFieldsUsername"),
                        ),
                        validator: (text) {
                          if (!(text.length > 3 && text.isNotEmpty)) {
                            return AppLocalisation.of(context)
                                .getTranslationKey("LoginFieldsErrorUsername");
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextFormField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppLocalisation.of(context)
                              .getTranslationKey("LoginFieldsPassword"),
                        ),
                        validator: (text) {
                          if (!(text.length >= 6 && text.isNotEmpty)) {
                            return AppLocalisation.of(context)
                                .getTranslationKey("LoginFieldsErrorPassword");
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
                      child: Text(AppLocalisation.of(context)
                          .getTranslationKey("forgetPasswordContent")),
                    ),
                    Container(
                        height: 50,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.deepOrangeAccent,
                          child: Text(AppLocalisation.of(context)
                              .getTranslationKey("loginButton")),
                          onPressed: () async {
                            final isValid = _form.currentState.validate();
                            if (!isValid) {
                              return;
                            }
                            List<User> users = await dbHelper.signInUser(nameController.text,passwordController.text);
                            if (users.length != 0) {
                              await storage.write(
                                  key: 'userName', value: nameController.text);
                              await storage.write(
                                  key: 'userID', value: users[0].id.toString());
                              await storage.write(
                                  key: 'email', value: users[0].email);
                              await storage.write(
                                  key: 'phone', value: users[0].phone);

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
                                        content: Text(
                                            AppLocalisation.of(context)
                                                .getTranslationKey(
                                                    "AlertWarningLoginBody")),
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
                            .getTranslationKey("registerButtonText")),
                        FlatButton(
                          textColor: Colors.deepOrange,
                          child: Text(
                            AppLocalisation.of(context)
                                .getTranslationKey("registerButtonName"),
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            //signup screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Register()),
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
