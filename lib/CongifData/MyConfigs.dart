import 'package:account_book/Models/ListViewModel.dart';

class MyConfigs{
  static String book="";
  static List<bookItem> selectBooks;
  static int bookId;
  static bookItem bItem;
  static String srch="";
  static int limit=10;
  static int offset=0;
  static bool isFilterEnabled=false;
  static String filterContext="";
  static  List<DateTime> filterDates = [DateTime.now(), DateTime.now()];
}