// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:isar/isar.dart';

part 'product.g.dart';

@Collection()
class Product {
  Id? id;
  String? title;
  double? price;
  String? description;
  String? category;
  String? image;
  Rating? rating;
  Product({
    this.id,
    this.title,
    this.price,
    this.description,
    this.category,
    this.image,
    this.rating,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': rating?.toJson(),
    };
  }
}

@embedded
class Rating {
  double? rate;
  int? count;
  Rating({
    this.rate,
    this.count,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rate': rate,
      'count': count,
    };
  }
}
