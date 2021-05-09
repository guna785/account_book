class InExp{
  int id;
  int amount;
  int transType;
  int userID;
  int bookId;
  String reason;
  String fileLocation;
  DateTime createdAt;
  DateTime transactionDate;
  InExp(this.id,this.amount,this.transType,this.bookId,this.userID,this.reason,this.createdAt,this.transactionDate,this.fileLocation);
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'amount': amount,
      'transType':transType,
      'userID':userID,
      'bookId':bookId,
      'reason':reason,
      'createdAt':createdAt.toString(),
      'transactionDate':transactionDate.toString(),
      'fileLocation':fileLocation
    };
    return map;
  }

  InExp.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    amount = map['amount'];
    transType=map['transType'];
    userID=map['userID'];
    bookId=map['bookId'];
    reason=map['reason'];
    createdAt= DateTime.parse( map['createdAt']);
    transactionDate=DateTime.parse(map['transactionDate']);
    fileLocation=map['fileLocation'];
  }
}