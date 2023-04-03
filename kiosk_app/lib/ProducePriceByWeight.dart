import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_scale/ConfirmPayment.dart';
import 'package:smart_scale/DatabaseHelper.dart';
import 'package:smart_scale/HelperFunctions.dart';

import 'Home.dart';

class ProducePriceByWeight extends StatefulWidget {
  const ProducePriceByWeight({Key? key, required this.app_config})
      : super(key: key);
  final Map app_config;
  static const String route_name = "/produce_price_by_weight";

  @override
  State<ProducePriceByWeight> createState() => _ProducePriceByWeightState();
}

class _ProducePriceByWeightState extends State<ProducePriceByWeight> {
  final textController = TextEditingController();
  late MqttServerClient client;
  var data_map = new Map();
  late bool produce_is_in_db;
  late HashMap db_produce;
  List<String> list = <String>['One', 'Two', 'Three', 'Four'];
  String dropdownValue = 'One';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connect_mqtt();
    init_produce_map_from_db();

    data_map["weight"] = 0;
    data_map["price_per_100"] = "";
    data_map["produce_to_show"] = "";
    data_map["image_to_show"] = Image.asset("assets/images/put_produce_on_scale.png");
    data_map["price_to_display"] = 0;
    print(widget.app_config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      flex: 5,
                      child: Container(
                          // color: Colors.red,
                          child: Column(
                        children: [
                          Expanded(
                              flex: 6,
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                // color: Colors.blue,
                                child: data_map["image_to_show"],
                              )),
                          Expanded(
                              flex: 3,
                              child: Container(
                                  // color: Colors.yellow,
                                  child: Column(
                                children: [
                                  Container(
                                    // color: Colors.yellow,
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    child: Text(
                                      data_map["produce_to_show"].toString(),
                                      style: TextStyle(
                                          fontSize: 40, fontFamily: 'Playfair'),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),

                                  Container(
                                    // color: Colors.yellow,
                                    width: double.infinity,
                                    alignment: Alignment.center,

                                    child: Text(
                                      data_map["price_per_100"],
                                      style: TextStyle(
                                          fontSize: 40, fontFamily: 'Playfair'),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),

                                  FractionallySizedBox(
                                    widthFactor: 0.5,
                                    child: Container(
                                        height: 60,
                                        width: double.infinity,
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: dropdownValue,
                                          icon:
                                              const Icon(Icons.arrow_downward),
                                          elevation: 16,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 40,
                                              fontFamily: 'Playfair'),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          onChanged: (String? value) {
                                            // This is called when the user selects an item.
                                            if(mounted){
                                              setState(() {
                                                dropdownValue = value!;
                                              });
                                            }
                                          },
                                          items: list
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        )),
                                  )
// Step 2.
                                ],
                              ))),
                        ],
                      ))),
                  Expanded(
                      flex: 6,
                      child: Container(
                        child: Column(
                          children: [
                            Expanded(
                                flex: 6,
                                child: Container(
                                    child: Container(
                                  child: Column(
                                    children: [
                                      Expanded(
                                          flex: 10,
                                          child: Container(child: Text(""))),
                                      Expanded(
                                          flex: 4,
                                          child: Container(
                                              alignment: Alignment.center,
                                              width: double.infinity,
                                              child: Text(data_map["weight"].toString(),
                                                  style: play_fair(60)))),
                                      Expanded(
                                          flex: 4,
                                          child: Container(
                                              alignment: Alignment.center,
                                              width: double.infinity,
                                              child: Text(data_map["price_to_display"].toString(),
                                                  style: play_fair(60)))),
                                    ],
                                  ),
                                ))),
                            Expanded(
                                flex: 5,
                                child: Container(
                                  child: Column(
                                    children: [
                                      SizedBox(width: 20),
                                      Expanded(flex: 1, child: Container()),
                                      Expanded(
                                          flex: 8,
                                          child: Container(
                                            alignment: Alignment.topCenter,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      height: 60,
                                                      child: ElevatedButton(
                                                          onPressed: () {
                                                            String w = data_map["weight"].toString();
                                                            String n = data_map["produce_to_show"].toString();
                                                            String p = data_map["total_price"].toString();

                                                            Map m =  {
                                                              "produce" : data_map["produce_to_show"],
                                                              "total"   : data_map["total_price"],
                                                              "img"     : data_map["image_to_show"],
                                                              "weight"  : data_map["weight"],
                                                              "details" : json.encode({'Name':n ,'Weight':'$w g', 'Price': 'RM $p'})
                                                            };

                                                            Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(builder:(context) => ConfirmPayment(payment_detail: m)));
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  side:
                                                                      const BorderSide(
                                                                    width: 1.0,
                                                                  )),
                                                          child: Text(
                                                              'Payment',
                                                              style: play_fair(
                                                                  30))),
                                                    )),
                                                SizedBox(width: 20),
                                                Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      height: 60,
                                                      child: ElevatedButton(
                                                          onPressed: () {

                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  side:
                                                                      const BorderSide(
                                                                    width: 1.0,
                                                                  )),
                                                          child: Text(
                                                              'Home',
                                                              style: play_fair(
                                                                  30))),
                                                    )),
                                                SizedBox(width: 20),
                                              ],
                                            ),
                                          )),
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      ))
                ],
              )),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.settings),
        onPressed: () {
          // await DatabaseHelper.instance.add(
          //   Product(name: textController.text),
          // );
          // setState(() {
          //   textController.clear();
          // });
          // Navigator.pushNamed(context, "/maintenance");
        },
      ),
    );
  }

  Future<MqttServerClient> connect() async {
    // HARD CODE widget.app_config["10.10.0.157"]
    MqttServerClient client =
        MqttServerClient.withPort("192.168.0.195", 'flutter_client', 1883);
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;

    final connMessage = MqttConnectMessage()
        .keepAliveFor(60)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      // update the map
      
      // DEBUG LOG
      print("UPDATING");

      for (int i = 0; i < c.length; i++) {
        var msg = c[i].payload as MqttPublishMessage;

        if(mounted){
          setState(() {
            data_map[c[i].topic] =
                MqttPublishPayload.bytesToStringAsString(msg.payload.message);
          });
        }

      }

      print(data_map);

      // control logic
      if (data_map.keys.contains("weight")) {


        if (data_map.keys.contains("produce")){
          Map m = json.decode(data_map["produce"]);
          if(m.keys.length == 1){
            var ref_produce = m.keys.toList()[0].toString();


            if(ref_produce != data_map["produce_to_show"]){

              if(mounted){
                setState(() {
                  data_map["produce_to_show"] = m.keys.toList()[0].toString();
                  data_map["price_per_100"] = db_produce[data_map["produce_to_show"]]["unit_price"].toString()+" per 100g";
                  var img = db_produce[data_map["produce_to_show"]]["produce_image"];
                  data_map["image_to_show"]=get_image_widget_from_unit8_img(img);


                  double unit_price= db_produce[data_map["produce_to_show"]]["unit_price"];


                  int weight = int.parse(data_map["weight"].toString());
                  double total_price= unit_price * weight/100;
                  data_map["total_price"] = total_price.toStringAsFixed(2);
                  data_map["price_to_display"]= "RM "+total_price.toStringAsFixed(2);


                  log("price="+data_map["price_to_display"].toString());

                });
              }

            }

          }
        }
        // weight too less
        // // HARD CODE widget.app_config["min_weight"]
        // if (data_map["weight"] < 10) {
        //   Navigator.pushReplacement(
        //       context, MaterialPageRoute(builder: (context) => Home()));
        //   // detected produce + > min
        // } else if (data_map.keys.contains("produce")) {
        //   if (data_map["produce"] != "unknown") {

            // setState(() {
            //   print("IS IN = " + produce_is_in_db.toString());
            //
            // });
            //
            // if(produce_is_in_db){
            //   print("CAN NAVIGATE");
            // }else{
            //   print("CANNOT NAVIGATE");
            // }
          //}
        // }
      }

      print(data_map);
    });

    return client;
  }

  // connection succeeded
  void onConnected() {
    print('Connected');
  }

// unconnected
  void onDisconnected() {
    print('Disconnected');
  }

// subscribe to topic succeeded
  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

// subscribe to topic failed
  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

// unsubscribe succeeded
  void onUnsubscribed(String topic) {
    print('Unsubscribed topic: $topic');
  }

// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }

  Future<void> connect_mqtt() async {
    print("trying connecting...");
    client = await connect();
    client.subscribe("weight", MqttQos.atLeastOnce);
    client.subscribe("produce", MqttQos.atLeastOnce);
  }

  Future<void> init_produce_map_from_db() async {
    var data = await DatabaseHelper.instance.produce_name_map_with_details();
    if(mounted){
      setState(() {
        db_produce = data;
        print("MAP+++>" + db_produce.keys.toString());
        print(db_produce.toString());
      });
    }

  }
}
