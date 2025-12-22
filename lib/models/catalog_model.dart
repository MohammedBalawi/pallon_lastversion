import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pallon_lastversion/models/sub_cat_model.dart';

class Catalog {
  final String doc;
  final String cat;
  final String pic;

  List<SubCatModel> sub;

  Catalog({
    required this.doc,
    required this.cat,
    required this.pic,
    List<SubCatModel>? sub,
  }) : sub = sub ?? [];

  static String _s(dynamic v, {String def = ""}) {
    if (v == null) return def;
    return v.toString();
  }

  factory Catalog.fromMap({
    required String docId,
    required Map<String, dynamic> data,
    List<SubCatModel> sub = const [],
  }) {
    return Catalog(
      doc: docId,
      cat: _s(data['cat']),
      pic: _s(data['pic']),
      sub: sub,
    );
  }

  factory Catalog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Catalog.fromMap(
      docId: doc.id,
      data: doc.data() ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cat': cat,
      'pic': pic,
    };
  }

  Catalog copyWith({
    String? doc,
    String? cat,
    String? pic,
    List<SubCatModel>? sub,
  }) {
    return Catalog(
      doc: doc ?? this.doc,
      cat: cat ?? this.cat,
      pic: pic ?? this.pic,
      sub: sub ?? List<SubCatModel>.from(this.sub),
    );
  }
}
