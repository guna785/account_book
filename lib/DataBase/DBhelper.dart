import 'package:account_book/Models/DashBoardModel.dart';
import 'package:account_book/Models/ListViewModel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'Models/AccountBook.dart';
import 'Models/InExp.dart';
import 'Models/User.dart';
import 'SQlTables.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'AccountBook.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE ' +
        SQlTables.User +
        ' (id INTEGER PRIMARY KEY, name TEXT,username TEXT,password TEXT,phone TEXT,email TEXT,createdAt DATETIME)');
    await db.execute('CREATE TABLE ' +
        SQlTables.Book +
        ' (id INTEGER PRIMARY KEY, name TEXT,userID INTEGER,createdAt DATETIME)');
    await db.execute('CREATE TABLE ' +
        SQlTables.inexp +
        ' (id INTEGER PRIMARY KEY, amount INTEGER,balance INTEGER,transType INTEGER,userID INTEGER,bookId INTEGER,reason TEXT,fileLocation TEXT,createdAt DATETIME,transactionDate DATETIME)');
  }

  Future<User> addUser(User user) async {
    var dbClient = await db;
    user.id = await dbClient.insert(SQlTables.User, user.toMap());
    return user;
  }

  Future<List<User>> signInUser(String userName, String password) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(SQlTables.User,
        columns: [
          'id',
          'name',
          'username',
          'password',
          'phone',
          'email',
          'createdAt'
        ],
        where: "username=$userName AND password=$password");
    List<User> users = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        users.add(User.fromMap(maps[i]));
      }
    }
    return users;
  }

  Future<List<User>> getUsers() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(SQlTables.User, columns: [
      'id',
      'name',
      'username',
      'password',
      'phone',
      'email',
      'createdAt'
    ]);
    List<User> users = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        users.add(User.fromMap(maps[i]));
      }
    }
    return users;
  }

  Future<int> deleteUser(int id) async {
    var dbClient = await db;
    return await dbClient.delete(
      SQlTables.User,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateUser(User user) async {
    var dbClient = await db;
    return await dbClient.update(
      SQlTables.User,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  ///
  /// Account Book
  ///

  Future<AccountBook> addBook(AccountBook book) async {
    var dbClient = await db;
    book.id = await dbClient.insert(SQlTables.Book, book.toMap());
    return book;
  }

  Future<List<AccountBook>> getBook() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(SQlTables.Book, columns: ['id', 'name', 'userID', 'createdAt']);
    List<AccountBook> books = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        books.add(AccountBook.fromMap(maps[i]));
      }
    }
    return books;
  }

  Future<int> deleteBook(int id) async {
    var dbClient = await db;
    return await dbClient.delete(
      SQlTables.Book,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateBook(AccountBook book) async {
    var dbClient = await db;
    return await dbClient.update(
      SQlTables.Book,
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  ///
  /// Get InCome and Expense
  ///

  Future<InExp> addInExp(InExp inexp) async {
    var dbClient = await db;
    inexp.id = await dbClient.insert(SQlTables.inexp, inexp.toMap());
    return inexp;
  }

  Future<List<InExp>> getInExp() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(SQlTables.inexp, columns: ['id', 'amount','balance','transType','userID','bookId','reason','fileLocation','createdAt','transactionDate']);
    List<InExp> inexp = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        inexp.add(InExp.fromMap(maps[i]));
      }
    }
    return inexp;
  }

  Future<List<DashBoardModel>> getInExpByCondition(int userId,int bookId,String scrh,int limit, int offset,bool filterSate,String filterContext,List<DateTime> filterDate) async {
    var dbClient = await db;
    List<DashBoardModel> dash=[];
    print(filterContext);
    if(!filterSate){
      List<Map> maps = await dbClient.query(SQlTables.inexp, columns: ['id', 'amount','balance','transType','userID','bookId','reason','createdAt','transactionDate'],where: "userId=$userId AND  bookId=$bookId AND  reason LIKE '%$scrh%' ",orderBy: " transactionDate ASC");

      List<ListViewModel> inexp = [];
      int inx=0,exp=0;
      if (maps.length > 0) {
        for (int i = 0; i < maps.length; i++) {
          InExp inex=InExp.fromMap(maps[i]);
          if(inex.transType==0){
            inx+=inex.amount;
          }
          else{
            exp+=inex.amount;
          }
          int bal=inx-exp;
          inexp.add(ListViewModel(inex.id, inex.transType, inex.reason, inex.amount,bal, inex.createdAt,inex.transactionDate));
        }
      }
      int income=0,expense=0,count=0;
      var incomeResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+ " WHERE userID=$userId AND bookId=$bookId AND transType=0 AND reason LIKE '%$scrh%' ORDER BY transactionDate ASC");
      income =incomeResult.toList()[0]["sum"]==null?0:incomeResult.toList()[0]["sum"];
      var expenseResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+" WHERE  userID=$userId AND bookId=$bookId AND  transType=1 AND  reason LIKE '%$scrh%'  ORDER BY transactionDate ASC ");
      expense=expenseResult.toList()[0]["sum"]==null?0:expenseResult.toList()[0]["sum"];
      count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM '+SQlTables.inexp));
      dash.add( DashBoardModel(income, expense, inexp.reversed.toList(),count));
    }
    else{
      String firstDate, lastDate;
      List<ListViewModel> inexp = [];
      if(filterContext=="Today"){
        firstDate=DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
        lastDate=DateFormat('yyyy-MM-dd').format((new DateTime.now()).add(new Duration(days: 1))).toString();
        List<Map> maps = await dbClient.query(SQlTables.inexp, columns: ['id', 'amount','balance','transType','userID','bookId','reason','createdAt','transactionDate'],where: "userId=$userId AND  bookId=$bookId AND  reason LIKE '%$scrh%'  AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')" ,orderBy: " transactionDate ASC");
        int inx=0,exp=0;
        if (maps.length > 0) {
          for (int i = 0; i < maps.length; i++) {
            InExp inex=InExp.fromMap(maps[i]);
            if(inex.transType==0){
              inx+=inex.amount;
            }
            else{
              exp+=inex.amount;
            }
            int bal=inx-exp;
            inexp.add(ListViewModel(inex.id, inex.transType, inex.reason, inex.amount,bal, inex.createdAt,inex.transactionDate));
          }
        }
        int income=0,expense=0,count=0;
        var incomeResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+ " WHERE userID=$userId AND bookId=$bookId AND transType=0 AND reason LIKE '%$scrh%'  AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')   ORDER BY transactionDate ASC");
        income =incomeResult.toList()[0]["sum"]==null?0:incomeResult.toList()[0]["sum"];
        var expenseResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+" WHERE  userID=$userId AND bookId=$bookId AND  transType=1 AND  reason LIKE '%$scrh%' AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')  ORDER BY transactionDate ASC");
        expense=expenseResult.toList()[0]["sum"]==null?0:expenseResult.toList()[0]["sum"];
        count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM '+SQlTables.inexp));
        dash.add( DashBoardModel(income, expense, inexp.reversed.toList(),count));
      }
      else if(filterContext=="This Week"){
        lastDate=DateFormat('yyyy-MM-dd').format((new DateTime.now()).add(new Duration(days: 1))).toString();
        firstDate=DateFormat('yyyy-MM-dd').format((new DateTime.now()).add(new Duration(days: -7))).toString();
        List<Map> maps = await dbClient.query(SQlTables.inexp, columns: ['id', 'amount','balance','transType','userID','bookId','reason','createdAt','transactionDate'],where: "userId=$userId AND  bookId=$bookId AND  reason LIKE '%$scrh%'  AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')",orderBy: " transactionDate ASC");
        int inx=0,exp=0;
        if (maps.length > 0) {
          for (int i = 0; i < maps.length; i++) {
            InExp inex=InExp.fromMap(maps[i]);
            if(inex.transType==0){
              inx+=inex.amount;
            }
            else{
              exp+=inex.amount;
            }
            int bal=inx-exp;
            inexp.add(ListViewModel(inex.id, inex.transType, inex.reason, inex.amount,bal, inex.createdAt,inex.transactionDate));
          }
        }
        int income=0,expense=0,count=0;
        var incomeResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+ " WHERE userID=$userId AND bookId=$bookId AND transType=0 AND reason LIKE '%$scrh%' AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')  ORDER BY transactionDate ASC");
        income =incomeResult.toList()[0]["sum"]==null?0:incomeResult.toList()[0]["sum"];
        var expenseResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+" WHERE  userID=$userId AND bookId=$bookId AND  transType=1 AND  reason LIKE '%$scrh%' AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')  ORDER BY transactionDate ASC");
        expense=expenseResult.toList()[0]["sum"]==null?0:expenseResult.toList()[0]["sum"];
        count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM '+SQlTables.inexp));
        dash.add( DashBoardModel(income, expense, inexp.reversed.toList(),count));

      }
      else if(filterContext=="Last Week"){
        lastDate=DateFormat('yyyy-MM-dd').format(DateTime.now().add(new Duration(days: -7))).toString();
        firstDate=DateFormat('yyyy-MM-dd').format((new DateTime.now()).add(new Duration(days: -14))).toString();
        List<Map> maps = await dbClient.query(SQlTables.inexp, columns: ['id', 'amount','balance','transType','userID','bookId','reason','createdAt','transactionDate'],where: "userId=$userId AND  bookId=$bookId AND  reason LIKE '%$scrh%'  AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')",orderBy: " transactionDate ASC");
        int inx=0,exp=0;
        if (maps.length > 0) {
          for (int i = 0; i < maps.length; i++) {
            InExp inex=InExp.fromMap(maps[i]);
            if(inex.transType==0){
              inx+=inex.amount;
            }
            else{
              exp+=inex.amount;
            }
            int bal=inx-exp;
            inexp.add(ListViewModel(inex.id, inex.transType, inex.reason, inex.amount,bal, inex.createdAt,inex.transactionDate));
          }
        }
        int income=0,expense=0,count=0;
        var incomeResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+ " WHERE userID=$userId AND bookId=$bookId AND transType=0 AND reason LIKE '%$scrh%' AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')  ORDER BY transactionDate ASC");
        income =incomeResult.toList()[0]["sum"]==null?0:incomeResult.toList()[0]["sum"];
        var expenseResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+" WHERE  userID=$userId AND bookId=$bookId AND  transType=1 AND  reason LIKE '%$scrh%' AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')  ORDER BY transactionDate ASC");
        expense=expenseResult.toList()[0]["sum"]==null?0:expenseResult.toList()[0]["sum"];
        count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM '+SQlTables.inexp));
        dash.add( DashBoardModel(income, expense, inexp.reversed.toList(),count));
      }
      else if(filterContext=="This Month"){
        lastDate=DateFormat('yyyy-MM-dd').format((new DateTime.now()).add(new Duration(days: 1))).toString();
        firstDate=DateFormat('yyyy-MM-dd').format((new DateTime.now()).add(new Duration(days: -30))).toString();
        List<Map> maps = await dbClient.query(SQlTables.inexp, columns: ['id', 'amount','balance','transType','userID','bookId','reason','createdAt','transactionDate'],where: "userId=$userId AND  bookId=$bookId AND  reason LIKE '%$scrh%'  AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')",orderBy: " transactionDate ASC");
        int inx=0,exp=0;
        if (maps.length > 0) {
          for (int i = 0; i < maps.length; i++) {
            InExp inex=InExp.fromMap(maps[i]);
            if(inex.transType==0){
              inx+=inex.amount;
            }
            else{
              exp+=inex.amount;
            }
            int bal=inx-exp;
            inexp.add(ListViewModel(inex.id, inex.transType, inex.reason, inex.amount,bal, inex.createdAt,inex.transactionDate));
          }
        }
        int income=0,expense=0,count=0;
        var incomeResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+ " WHERE userID=$userId AND bookId=$bookId AND transType=0 AND reason LIKE '%$scrh%' AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')  ORDER BY transactionDate ASC");
        income =incomeResult.toList()[0]["sum"]==null?0:incomeResult.toList()[0]["sum"];
        var expenseResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+" WHERE  userID=$userId AND bookId=$bookId AND  transType=1 AND  reason LIKE '%$scrh%' AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')  ORDER BY transactionDate ASC");
        expense=expenseResult.toList()[0]["sum"]==null?0:expenseResult.toList()[0]["sum"];
        count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM '+SQlTables.inexp));
        dash.add( DashBoardModel(income, expense, inexp.reversed.toList(),count));
      }
      else if(filterContext=="Last Month"){
        lastDate=DateFormat('yyyy-MM-dd').format(DateTime.now().add(new Duration(days: -30))).toString();
        firstDate=DateFormat('yyyy-MM-dd').format((new DateTime.now()).add(new Duration(days: -60))).toString();
        List<Map> maps = await dbClient.query(SQlTables.inexp, columns: ['id', 'amount','balance','transType','userID','bookId','reason','createdAt','transactionDate'],where: "userId=$userId AND  bookId=$bookId AND  reason LIKE '%$scrh%'  AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')",orderBy: " transactionDate ASC");
        int inx=0,exp=0;
        if (maps.length > 0) {
          for (int i = 0; i < maps.length; i++) {
            InExp inex=InExp.fromMap(maps[i]);
            if(inex.transType==0){
              inx+=inex.amount;
            }
            else{
              exp+=inex.amount;
            }
            int bal=inx-exp;
            inexp.add(ListViewModel(inex.id, inex.transType, inex.reason, inex.amount,bal, inex.createdAt,inex.transactionDate));
          }
        }
        int income=0,expense=0,count=0;
        var incomeResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+ " WHERE userID=$userId AND bookId=$bookId AND transType=0 AND reason LIKE '%$scrh%' AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')   ORDER BY transactionDate ASC");
        income =incomeResult.toList()[0]["sum"]==null?0:incomeResult.toList()[0]["sum"];
        var expenseResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+" WHERE  userID=$userId AND bookId=$bookId AND  transType=1 AND  reason LIKE '%$scrh%' AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')   ORDER BY transactionDate ASC");
        expense=expenseResult.toList()[0]["sum"]==null?0:expenseResult.toList()[0]["sum"];
        count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM '+SQlTables.inexp));
        dash.add( DashBoardModel(income, expense, inexp.reversed.toList(),count));
      }
      else if(filterContext=="Custom"){
        firstDate=DateFormat('yyyy-MM-dd').format(filterDate[0]).toString();
        lastDate=DateFormat('yyyy-MM-dd').format(filterDate[1]).toString();
        List<Map> maps = await dbClient.query(SQlTables.inexp, columns: ['id', 'amount','balance','transType','userID','bookId','reason','createdAt','transactionDate'],where: "userId=$userId AND  bookId=$bookId AND  reason LIKE '%$scrh%'  AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')" ,orderBy: " transactionDate ASC");
        int inx=0,exp=0;
        if (maps.length > 0) {
          for (int i = 0; i < maps.length; i++) {
            InExp inex=InExp.fromMap(maps[i]);
            if(inex.transType==0){
              inx+=inex.amount;
            }
            else{
              exp+=inex.amount;
            }
            int bal=inx-exp;
            inexp.add(ListViewModel(inex.id, inex.transType, inex.reason, inex.amount,bal, inex.createdAt,inex.transactionDate));
          }
        }
        int income=0,expense=0,count=0;
        var incomeResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+ " WHERE userID=$userId AND bookId=$bookId AND transType=0 AND reason LIKE '%$scrh%' AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')   ORDER BY transactionDate ASC");
        income =incomeResult.toList()[0]["sum"]==null?0:incomeResult.toList()[0]["sum"];
        var expenseResult=await dbClient.rawQuery("SELECT SUM(amount) as sum FROM "+SQlTables.inexp+" WHERE  userID=$userId AND bookId=$bookId AND  transType=1 AND  reason LIKE '%$scrh%' AND transactionDate BETWEEN date('$firstDate') AND date('$lastDate')   ORDER BY transactionDate ASC");
        expense=expenseResult.toList()[0]["sum"]==null?0:expenseResult.toList()[0]["sum"];
        count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM '+SQlTables.inexp));
        dash.add( DashBoardModel(income, expense, inexp.reversed.toList(),count));
      }
    }

    return dash;
  }
  Future<InExp>  getLastRecord(int userId,int bookId) async{
    var dbClient = await db;
    List<Map> maps = await dbClient.query(SQlTables.inexp, columns: ['id', 'amount','balance','transType','userID','bookId','reason','createdAt','transactionDate'],where: 'userID=$userId AND bookId=$bookId' ,orderBy: 'DESC',limit: 1);
    List<InExp> inExp = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        inExp.add(InExp.fromMap(maps[i]));
      }
    }
    return inExp.first;
  }

  Future<int> deleteInExp(int id) async {
    var dbClient = await db;
    return await dbClient.delete(
      SQlTables.inexp,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateInExp(InExp inexp) async {
    var dbClient = await db;
    return await dbClient.update(
      SQlTables.inexp,
      inexp.toMap(),
      where: 'id = ?',
      whereArgs: [inexp.id],
    );
  }
  void deleteAll() async{
    var dbClient = await db;
    await dbClient.rawQuery("DELETE FROM "+SQlTables.Book);
    await dbClient.rawQuery("DELETE FROM "+SQlTables.inexp);
  }
  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
