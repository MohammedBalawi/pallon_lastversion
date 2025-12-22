import '../feature/Catalog/models/sub3_cat_model.dart';
import 'catalog_item_model.dart';

class SubSubCatModel{
  String doc;
  String subsub;
  String pic;
  List<CatalogItemModel> items=[];

   List<Sub3CatModel> sub3;

  SubSubCatModel({
    required this.doc,
    required this.subsub,
    required this.pic,
    this.items = const [],
    this.sub3 = const [],
  });

  factory SubSubCatModel.fromMap(Map<String, dynamic> map) {
    return SubSubCatModel(
      doc: map['doc'] ?? '',
      subsub: map['subsub'] ?? map['name'] ?? '',
      pic: map['pic'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) => CatalogItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      sub3: (map['sub3'] as List<dynamic>? ?? [])
          .map((e) => Sub3CatModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doc': doc,
      'subsub': subsub,
      'pic': pic,
      'items': items.map((e) => e.toMap()).toList(),
      'sub3': sub3.map((e) => e.toMap()).toList(),
    };
  }
}