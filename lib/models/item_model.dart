class ItemModel {
  String doc;
  String id;
  String name;
  int count;
  double price;
  double? pricebuy;
  String pic;
  bool show;
  String? time;
  String? action;
  String? des;

  ItemModel({
    required this.doc,
    required this.id,
    required this.name,
    required this.count,
    required this.price,
    this.pricebuy,
    required this.pic,
    required this.show,
    this.time,
    this.action,
    this.des,
  });

  factory ItemModel.fromMap(
      Map<String, dynamic> map, {
        String? docId,
      }) {
    return ItemModel(
      doc: docId ?? (map['doc'] ?? '').toString(),
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      count: (map['count'] ?? 0) is int
          ? map['count']
          : int.tryParse((map['count'] ?? '0').toString()) ?? 0,
      price: (map['price'] ?? 0) is num
          ? (map['price'] as num).toDouble()
          : double.tryParse((map['price'] ?? '0').toString()) ?? 0.0,
      pricebuy: map['pricebuy'] == null
          ? null
          : (map['pricebuy'] is num
          ? (map['pricebuy'] as num).toDouble()
          : double.tryParse(map['pricebuy'].toString())),
      pic: (map['pic'] ?? '').toString(),
      show: map['show'] == null ? true : map['show'] == true,
      time: map['time']?.toString(),
      action: map['action']?.toString(),
      des: map['des']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "count": count,
      "price": price,
      "pricebuy": pricebuy,
      "pic": pic,
      "show": show,
      "time": time,
      "action": action,
      "des": des,
    };
  }

  ItemModel copyWith({
    String? doc,
    String? id,
    String? name,
    int? count,
    double? price,
    double? pricebuy,
    String? pic,
    bool? show,
    String? time,
    String? action,
    String? des,
  }) {
    return ItemModel(
      doc: doc ?? this.doc,
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      price: price ?? this.price,
      pricebuy: pricebuy ?? this.pricebuy,
      pic: pic ?? this.pic,
      show: show ?? this.show,
      time: time ?? this.time,
      action: action ?? this.action,
      des: des ?? this.des,
    );
  }
}
