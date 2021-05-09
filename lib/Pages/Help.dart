import 'package:flutter/material.dart';

import '../app_localisation.dart';
class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top:4,bottom: 0,left: 4,right: 4),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        color: Colors.white,
        child: Center(child: Text(AppLocalisation.of(this.context).getTranslationKey("Help"),
            textAlign: TextAlign.center)));
  }
}
