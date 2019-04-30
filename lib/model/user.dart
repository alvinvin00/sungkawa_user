class User {
  String uid, email, nama;

  User(this.uid, this.email, this.nama);

  Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['userId'] = user.uid;
    data['nama'] = user.nama;
    data['email'] = user.email;
    return data;
  }

  User.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['userId'];
    this.nama = mapData['nama'];
    this.email = mapData['email'];
  }
}
