import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_scale/DatabaseHelper.dart';

import 'Home.dart';

class ProduceDetect extends StatefulWidget {
  static const route_name = "/produce_detect";

  const ProduceDetect({Key? key, required this.app_config}) : super(key: key);

  final Map app_config;

  @override
  State<ProduceDetect> createState() => _ProduceDetectState();
}

class _ProduceDetectState extends State<ProduceDetect> {
  final textController = TextEditingController();
  late MqttServerClient client;
  var data_map = new Map();
  late bool produce_is_in_db;

  Future<void> connect_mqtt() async {
    print("trying connecting...");
    client = await connect();
    client.subscribe("weight", MqttQos.atLeastOnce);
    client.subscribe("produce", MqttQos.atLeastOnce);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connect_mqtt();
    data_map["weight"] = 0;

    print(widget.app_config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: TextField(
      //      controller: textController,
      //   ),
      // ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 15,
              child: Container(
                padding: EdgeInsets.only(top: 120),
                child: Text(data_map["weight"].toString() + " g",
                    style: TextStyle(fontSize: 100, fontFamily: 'Playfair')),
              ),
            ),
            Expanded(
                flex: 10,
                child: Container(
                    padding: EdgeInsets.only(top: 0),
                    alignment: Alignment.topCenter,
                    child: LoadingAnimationWidget.waveDots(
                      size: 200,
                      color: Colors.grey.shade300,
                    ))),
            Expanded(
                flex: 10,
                child: AnimatedTextKit(
                  animatedTexts: [
                    ScaleAnimatedText(
                      duration: const Duration(milliseconds: 5000),
                      'Detecting produce...',
                      textStyle: const TextStyle(
                          fontSize: 60.0, fontFamily: "Playfair"),
                    ),
                  ],
                  repeatForever: true,
                )),
            Expanded(
              flex: 5,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.yellow,
                      child: Text("mqtt_data_string"),
                    ),
                  )
                ],
              ),
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
    MqttServerClient client = MqttServerClient.withPort(
        widget.app_config["mqtt_host"], 'flutter_client', 1883);
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
      for (int i = 0; i < c.length; i++) {
        var msg = c[i].payload as MqttPublishMessage;

        setState(() {
          // getting data
          data_map[c[i].topic] =
              MqttPublishPayload.bytesToStringAsString(msg.payload.message);
        });
      }

      // control logic
      if (data_map.keys.contains("weight")) {
        // weight too less
        if (int.parse(data_map["weight"]) < widget.app_config["min_weight"]) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));

          // weight is over minimum
        } else {
          if (data_map["produce"] != "{}") { // contain produce

            Map produce = json.decode(data_map["produce"]);
            
            if(produce.keys.length > 1){ // only 1 
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
            }else{

              setState(() {
                check_produce_in_db();
                print("IS IN = " + produce_is_in_db.toString());
              });

              if (produce_is_in_db) {
                print("CAN NAVIGATE");
              } else {
                print("CANNOT NAVIGATE");
              }
            }


          }
        }
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

  Future<void> check_produce_in_db() async {
    produce_is_in_db =
        await DatabaseHelper.instance.produce_in_database(data_map["produce"]);
  }
}
