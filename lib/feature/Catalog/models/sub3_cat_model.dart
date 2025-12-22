import '../../../models/catalog_item_model.dart';

class Sub3CatModel {
  String doc;
  String name;
  String pic;
   List<CatalogItemModel> items;

   List<Sub4CatModel> sub4;
  Sub3CatModel({
    required this.doc,
    required this.name,
    required this.pic,
    this.items = const [],
    this.sub4 = const [],
  });
  factory Sub3CatModel.fromMap(Map<String, dynamic> map) {
    return Sub3CatModel(
      doc: map['doc'] ?? '',
      name: map['name'] ?? map['sub3'] ?? '',
      pic: map['pic'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) => CatalogItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      sub4: (map['sub4'] as List<dynamic>? ?? [])
          .map((e) => Sub4CatModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doc': doc,
      'name': name,
      'pic': pic,
      'items': items.map((e) => e.toMap()).toList(),
      'sub4': sub4.map((e) => e.toMap()).toList(),
    };
  }
}

class Sub4CatModel {
  String doc;
  String name;
  String pic;
   List<CatalogItemModel> items;
  Sub4CatModel({
    required this.doc,
    required this.name,
    required this.pic,
    this.items = const [],
  });


  factory Sub4CatModel.fromMap(Map<String, dynamic> map) {
    return Sub4CatModel(
      doc: map['doc'] ?? '',
      name: map['name'] ?? map['sub4'] ?? '',
      pic: map['pic'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) => CatalogItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doc': doc,
      'name': name,
      'pic': pic,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}
