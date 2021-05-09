import 'package:flutter/material.dart';
class ListViewModel{
  int id;
  int amount;
  int transType;
  String reason;
  DateTime createdAt;
  int balance;
  DateTime transactionDate;
  ListViewModel(this.id,this.transType,this.reason,this.amount,this.balance,this.createdAt,this.transactionDate);
}
class Item {
  Item(this.name,this.icon);
  final String name;
  final Icon icon;
}
class bookItem{
  int id;
  String name;
  bookItem(this.id,this.name);
}