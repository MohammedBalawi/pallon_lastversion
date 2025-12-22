import 'package:pallon_lastversion/models/sub_sub_cat.dart';
import 'catalog_item_model.dart';

class SubCatModel{
  String doc;
  String pic;
  String sub;
  List<SubSubCatModel> subsub=[];
  List<CatalogItemModel> items=[];
  SubCatModel({
    required this.doc,
    required this.sub,
    required this.pic,
    List<SubSubCatModel>? subsub,
    List<CatalogItemModel>? items,
  })  : subsub = subsub ?? [],
        items = items ?? [];
}