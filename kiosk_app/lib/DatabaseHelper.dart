import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_scale/HelperFunctions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'models/Product.dart' show Product;
import 'package:http/http.dart' as http;

class DatabaseHelper {
  DatabaseHelper._privateConstructor(); // the private constructor
  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor(); // instantiate the only 1 instance
  static Database? _database; // private database variable

  // method to get the database,
  // return the database from init database
  Future<Database> get database async => _database ??= await _initDatabase();

  // METHOD ; return a database instance
  Future<Database> _initDatabase() async {
    Directory documentsDirectory =
        await getApplicationDocumentsDirectory(); // 1. get the directory xx/xx/xx
    String path = join(documentsDirectory.path,
        'Products.db'); // 2. create a db path xx/xx/Products.db
    return await openDatabase(
      // 3. return the database using openDatabase
      path,
      version: 1,
      onCreate: _onCreate, // to create the database if db not exist
    );
  }

  // METHOD ; script to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Produce (
          produce_id int auto_increment,
          produce_name varchar(30),
          unit_price float,
          produce_type varchar(30),
          produce_image LONGBLOB,
          primary key (produce_id)
      );
      ''');
  }

  // METHOD ; fetch the products records in db into list
  Future<List<Product>> getProducts() async {
    Database db = await instance.database; // 1. get database instance
    var products = await db.query('Produce'); // 2. write query and get result
    List<Product> productList = products.isNotEmpty
        ? products.map((c) => Product.fromMap(c)).toList()
        : []; // 3. parse result to list using map function
    return productList; // 4. return the product list
  }

  // METHOD ; add product into the database
  Future<int> add(Product product) async {
    Database db = await instance.database;
    return await db.insert('Products', product.toMap());
  }

  // METHOD : Download the latest produce data from the remote database
  Future<void> get_latest_data() async {
    Database db = await instance.database;
    await db.execute("""
      drop table Produce;
    """);

    await db.execute('''
      CREATE TABLE Produce (
          produce_id int auto_increment,
          produce_name varchar(30),
          unit_price float,
          produce_type varchar(30),
          produce_image LONGBLOB,
          primary key (produce_id)
      );
      ''');

    Map config = await get_config();
    print(config);
    String host = config["sql_api_host"];
    http.Response response =
        await http.get(Uri.parse("http://" + host + "/produce_data"));
    var data = jsonDecode(response.body);

    print(data);

    await insert_json_products(data, db);
    print("inserted");
  }

  Future<void> insert_json_products(json, db) async {
    json.forEach((row) => db.insert("Produce", modified_row(row)));
  }

  Map<String, dynamic> modified_row(row) {
    row["produce_image"] = utf8.encode(row["produce_image"]);
    print(row);
    return row;
  }

  Future<List<DataRow>> get_data_row() async {
    var data = await getProducts();
    return data
        .map<DataRow>((product) => DataRow(cells: [
              DataCell(Container(
                  width: 30, //SET width
                  child: Text(product.produce_id.toString()))),
              DataCell(Container(
                  width: 100, //SET width
                  child: Text(product.produce_name.toString()))),
              DataCell(Container(
                  width: 100, //SET width
                  child: Text(product.unit_price.toString()))),
              DataCell(Container(
                  width: 150, //SET width
                  child: Text(product.produce_type.toString()))),
              DataCell(Container(
                width: 200,
                child: get_image_widget_from_unit8_img(product.produce_image),
              )),
            ]))
        .toList();
  }

  Future<bool> produce_in_database(String produce_name) async {
    Database db = await instance.database; // 1. get database instance
    List<Map> result = await db.rawQuery(
        'select produce_name from Produce where produce_name=?',
        [produce_name]);
    return result.length > 0;
  }

  Future<HashMap> produce_name_map_with_details() async {
    HashMap produce_name_hashed_rec = new HashMap();
    Database db = await instance.database; // 1. get database instance
    List<Map> result = await db.rawQuery('select * from Produce;');

    for (int i = 0; i < result.length; i++) {
      Map record_map = result[i];
      produce_name_hashed_rec[record_map["produce_name"]] = record_map;
    }

    return produce_name_hashed_rec;
  }

  Future<Map> get_config() async {
    final String response =
        await rootBundle.loadString('assets/app_config.json');
    final data = await json.decode(response);
    return data;
  }

}
