import 'package:account_book/DataBase/DBhelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Login.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DBHelper dbHelper;
  final storage = new FlutterSecureStorage();
  String userName="",Name="",email="",phone="",book="";
  int userId,bookId;
  Future init(context) async {
    Map<String, String> allValues = await storage.readAll();
    setState(() {
      userName = allValues['userName'];
      email = allValues['email'];
      userId = int.parse( allValues['userID']);
      phone = allValues['phone'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init(context);
    dbHelper=DBHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }
  _body(BuildContext context) =>
      ListView(physics: BouncingScrollPhysics(), children: <Widget>[
        Container(
            padding: EdgeInsets.all(15),
            child: Column(children: <Widget>[_headerSignUp(), _formUI()]))
      ]);
  _headerSignUp() => Column(children: <Widget>[
    Container(height: 80, child: CircleAvatar(
      backgroundColor: Colors.orange,
      child: Text('$userName' ,style: TextStyle(color: Colors.white),),
      radius: 60,
    )),
    SizedBox(height: 12.0),
    Text('$userName',
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20.0,
            color: Colors.orange)),
  ]);
  _formUI() {
    return new Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 40.0),
          _email(),
          SizedBox(height: 12.0),
          _mobile(),
          SizedBox(height: 12.0),
          _SignOut(),
          SizedBox(height: 12.0),

        ],
      ),
    );
  }
  _SignOut(){
    return Row(
        children: <Widget>[
          _prefixIcon(Icons.lock),
          ElevatedButton(onPressed: () async{
            await storage.deleteAll();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          }, child: Text('Log Out',style: TextStyle(color: Colors.white),),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrangeAccent) ),)
        ]
    );
  }
  _email() {
    return Row(children: <Widget>[
      _prefixIcon(Icons.email),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Email',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: Colors.orangeAccent)),
          SizedBox(height: 1),
          Text('$email')
        ],
      )
    ]);
  }
  _mobile() {
    return Row(children: <Widget>[
      _prefixIcon(Icons.phone),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Mobile',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                  color: Colors.orangeAccent)),
          SizedBox(height: 1),
          Text('+91 $phone')
        ],
      )
    ]);
  }

  _prefixIcon(IconData iconData) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
      child: Container(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          margin: const EdgeInsets.only(right: 8.0),
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                  bottomRight: Radius.circular(10.0))),
          child: Icon(
            iconData,
            size: 20,
            color: Colors.deepOrangeAccent,
          )),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }

}
