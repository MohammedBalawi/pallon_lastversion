class CatalogItemModel{
  String des;
  String doc;
  String name;
  String path;
  String price;
  int count=1;
  CatalogItemModel({
   required this.doc,required this.name,
   required this.path,required this.des,
   required this.price
});
  factory CatalogItemModel.fromMap(Map<String, dynamic> map) {
    return CatalogItemModel(
      doc: map['doc'] ?? '',
      name: map['name'] ?? '',
      des: map['des'] ?? '',
      price: map['price']?.toString() ?? '0',
      path: map['path'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doc': doc,
      'name': name,
      'des': des,
      'price': price,
      'path': path,
      'count': count,
    };
  }
}