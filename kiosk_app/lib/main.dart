
import 'package:flutter/material.dart';
import 'package:smart_scale/ConfirmPayment.dart';
import 'package:smart_scale/ProduceDetect.dart';
import 'package:smart_scale/ProducePriceByWeight.dart';
import 'package:smart_scale/smart_scale/ProduceList.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'DatabaseHelper.dart';
import 'Home.dart';
import 'Maintain.dart';
import 'models/Product.dart';
import 'smart_scale/DatabaseHelper.dart';


// sql lite setup and usage : https://www.youtube.com/watch?v=noi6aYsP7Go

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      MaterialApp(
        initialRoute:  ProducePriceByWeight.route_name,
        routes: {
          '/home' : (context) => const Home(),
          '/maintenance' : (context) => Maintain(),
          '/produce_list' : (context) => ProduceList(),
          ProduceDetect.route_name : (context) => ProduceDetect(app_config: {},),
          ProducePriceByWeight.route_name: (context) => ProducePriceByWeight(app_config: {},),
          ConfirmPayment.route_name : (context) => ConfirmPayment(payment_detail: {},)
        },
      ));
}





