class UserModel{
  String name;
  String email;
  String doc;
  String phone;
  String pic;
  String type;
  String? token;
  UserModel({required this.doc,required this.email,required this.phone, required this.name,
  required this.pic , required this.type});
}