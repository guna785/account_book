import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Home.dart';
import 'Login.dart';
import 'app_localisation.dart';

final storage = new FlutterSecureStorage();
String uname="";
Future main() async{
  WidgetsFlutterBinding.ensureInitialized();

  uname = await storage.read(key: 'userName');

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.deepOrangeAccent,
          primaryColorDark: Colors.deepOrangeAccent,
          primaryColorLight: Colors.orange,
          primaryIconTheme: IconThemeData(
            opacity: 5,
            color: Colors.white,
          ),
          secondaryHeaderColor: Colors.grey,
          selectedRowColor: Colors.orange,
          shadowColor: Colors.black
      ),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ta', 'IN')
      ],
      localizationsDelegates: [
        AppLocalisation.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback: (locale, supportedLocaleList) {
        for (var v in supportedLocaleList) {
          if (v.languageCode == locale.languageCode &&
              v.countryCode == locale.countryCode) {
            return locale;
          }
        }
        return supportedLocaleList.first;
      },
      home: SplashScreen(),
    ));
  });
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }
  Future<Timer> loadData() async {
    return new Timer(Duration(seconds: 5), onDoneLoading);
  }

  onDoneLoading() async {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => (uname==null || uname=="") ?Login():Home()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color:Colors.orangeAccent
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: Container(
                        child: Column( mainAxisAlignment: MainAxisAlignment.center,
                            children:<Widget>[  CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 80.0,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/Icons/money.gif',
                                  filterQuality: FilterQuality.high,
                                  fit: BoxFit.fill,),
                              ),
                            ),
                              Padding(padding: EdgeInsets.only(top: 10.0)),
                              Text(AppLocalisation.of(context).getTranslationKey("AppName"),
                                  style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold))
                            ]
                        )
                    )
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      Text('Please Wait ....',style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold))
                    ],
                  ),
                )

              ],
            )

          ],
        )
    );
  }
}


