class AccountBook{
  int id;
  String name;
  int userID;
  DateTime createdAt;
  AccountBook(this.id,this.name,this.userID,this.createdAt);
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'userID':userID,
      'createdAt':createdAt.toString()
    };
    return map;
  }

  AccountBook.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    userID=map['userID'];
    createdAt= DateTime.parse( map['createdAt']);
  }
}