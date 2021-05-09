class User{
  int id;
  String name;
  String username;
  String password;
  String phone;
  String email;
  DateTime createdAt;

  User(this.id,this.name,this.username,this.password,this.phone,this.email,this.createdAt);
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'username':username,
      'password':password,
      'phone':phone,
      'email':email,
      'createdAt':createdAt.toString()
    };
    return map;
  }

  User.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    username=map['username'];
    password=map['password'];
    phone=map['phone'];
    email=map['email'];
    createdAt= DateTime.parse( map['createdAt']);
  }

}