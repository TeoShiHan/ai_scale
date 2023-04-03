import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_scale/Maintain.dart';
import 'package:smart_scale/ProduceDetect.dart';
import 'package:smart_scale/smart_scale/ProduceList.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();

}



class _HomeState extends State<Home> {
  final textController = TextEditingController();
  late MqttServerClient client;
  var mqtt_data = Map();
  var mqtt_data_string = "";
  var app_config = new Map();
  late Timer timer_g;

  @override
  void dispose(){
    timer_g.cancel();
    super.dispose();
  }

  void time_fullfill_nav_req() {
    final timer = Timer(
      const Duration(seconds: 3),
      () {
        mqtt_data["display_time"] = "allow_navigate";

        setState(() {
          mqtt_data_string = mqtt_data.toString();
        });

      },
    );
    timer_g = timer;
    print(timer.tick);
  }

  Future<void> connect_mqtt() async {
    print("trying connecting...");
    client = await connect();
    await client.subscribe("weight", MqttQos.atLeastOnce);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize_backend();
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
              flex: 4,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: const Text(
                        "Welcome, place the item on the scale...",
                        style: TextStyle(fontSize: 40, fontFamily: 'Playfair'),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                flex: 20,
                child: Center(
                    child:
                        Image.asset("assets/images/put_produce_on_scale.png"))),
            Expanded(
              flex: 3,
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                      onPressed: () {

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder:(context) => ProduceDetect(app_config: app_config)));
                      },
                      child: Text("nav")),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.yellow,
                      child: Text(mqtt_data_string),
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
          Navigator.push(
              context,
              MaterialPageRoute(builder:(context) => Maintain()));
        },
      ),
    );
  }

  Future<MqttServerClient> connect() async {
    MqttServerClient client = MqttServerClient.withPort(
        app_config["mqtt_host"], 'flutter_client', 1883);
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

        mqtt_data[c[i].topic] =
            MqttPublishPayload.bytesToStringAsString(msg.payload.message);

        setState(() {
          mqtt_data_string = mqtt_data.toString();
          print("new state");
        });
      }

      // control logic
      if (mqtt_data.keys.contains("weight")) {
        print("contain weight");
        if (mqtt_data["display_time"] == "allow_navigate" &&
            int.parse(mqtt_data["weight"]) > app_config["min_weight"]) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder:(context) => ProduceDetect(app_config: app_config)));
        }
      }
      print(mqtt_data);
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

  Future<void> init_config() async {
    final String response =
        await rootBundle.loadString('assets/app_config.json');
    final data = await json.decode(response);
    app_config = data;
    print(app_config);
  }

  Future <void> initialize_backend() async {
    await init_config();
    await connect_mqtt();
    mqtt_data["display_time"] = "not allowed";
    time_fullfill_nav_req();
  }
}
