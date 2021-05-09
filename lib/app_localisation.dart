import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AppLocalisation{
  Locale locale;
  static const LocalizationsDelegate<AppLocalisation> delegate=_ApplocalisationDelegate();
  static AppLocalisation of(BuildContext context){
    return Localizations.of<AppLocalisation>(context, AppLocalisation);
  }
  AppLocalisation(this.locale);
  Map<String,String> languageMap=Map();
  Future load() async{
    final flieString=await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    final Map<String,dynamic> mapData=json.decode(flieString);
    languageMap=mapData.map((key, value) => MapEntry(key, value.toString()));
  }
  getTranslationKey(key){
    return languageMap[key];
  }
}
class _ApplocalisationDelegate extends LocalizationsDelegate<AppLocalisation>{
  const _ApplocalisationDelegate();
  @override
  bool isSupported(Locale locale) {
    // TODO: implement isSupported
    return ['en','ta'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalisation> load(Locale locale) async {
    // TODO: implement load
    AppLocalisation localisation=AppLocalisation(locale);
    await localisation.load();
    return localisation;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalisation> old) {
    // TODO: implement shouldReload
    throw UnimplementedError();
  }

}