import 'dart:typed_data';

class Product{
  // the data field
  final int? produce_id;
  final String produce_name;
  final double unit_price;
  final String produce_type;
  final Uint8List produce_image;

  // constructor
  Product({
    required this.produce_id,
    required this.produce_name,
    required this.unit_price,
    required this.produce_type,
    required this.produce_image
  });

  // constructor return the instance
  // get the json and return with the new instance
  factory Product.fromMap(Map<String, dynamic> json) => Product(
    produce_id : json['produce_id'],
    produce_name: json['produce_name'],
    unit_price: json['unit_price'],
    produce_type: json['produce_type'],
    produce_image: json['produce_image'],
  );

  // return the map form of the data
  Map<String, dynamic> toMap(){
    return{
      'produce_id' : produce_id,
      'produce_name' : produce_name,
      'unit_price' : unit_price,
      'produce_type' : produce_type,
      'produce_image' : produce_image
    };
  }
}