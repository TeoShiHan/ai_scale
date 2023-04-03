import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_scale/HelperFunctions.dart';
import 'package:qr_flutter/qr_flutter.dart';


class ConfirmPayment extends StatefulWidget {
  const ConfirmPayment({Key? key, required this.payment_detail}) : super(key: key);
  static final String route_name = "/confirm_payment";
  final Map payment_detail;

  @override
  State<ConfirmPayment> createState() => _ConfirmPaymentState();

  @override
  void initState() {
    print(payment_detail.toString());

  }
}

// pass

class _ConfirmPaymentState extends State<ConfirmPayment> {




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: Row(
            children: [
              Expanded(
                  flex: 5,
                  child: Container(
                    // color: Colors.green,
                    child: Column(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Container(
                                alignment: Alignment.bottomCenter,
                                // color: Colors.blue,
                                child: widget.payment_detail["img"])),
                        Expanded(
                            flex: 1,
                            child: Container(
                              // color: Colors.purple,
                              child: Text(
                                widget.payment_detail["produce"],
                                style: play_fair(40),
                              ),
                            ))
                      ],
                    ),
                  )),
              Expanded(
                  flex: 6,
                  child: Container(
                    // color: Colors.red,
                    child: Column(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                              // color: Colors.black,
                            )),
                        Expanded(
                            flex: 1,
                            child: Container(
                              // color: Colors.orange,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Scan qr code and add to cart",
                                style: play_fair(40),
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.payment_detail["weight"]+"g / RM "+widget.payment_detail["total"],
                                style: play_fair(25),
                              ),
                              // color: Colors.yellow,
                            )),
                        Expanded(
                            flex: 9,
                            child: Container(
                              // color: Colors.red,
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 6,
                                      child: Container(
                                        // color: Colors.green,
                                        child: Column(
                                          children: [
                                            Expanded(
                                                flex: 3,
                                                child: Container(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  // color: Colors.purple,
                                                  child: QrImage(
                                                    data: json.encode(
                                                        {"total_price" : widget.payment_detail["total"], "produce" : widget.payment_detail["produce"], "details": widget.payment_detail["details"]}
                                                    ),
                                                    version: QrVersions.auto,
                                                    size: 350.0,
                                                  ),
                                                )),
                                            Expanded(
                                                flex: 1,
                                                child: Container(
                                                  // color: Colors.black,
                                                ))
                                          ],
                                        ),
                                      )),
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        // color: Colors.orangeAccent,
                                        child: Column(
                                          children: [
                                            Expanded(
                                                flex: 3,
                                                child: Container(
                                                  padding: EdgeInsets.only(left: 10, right: 10),
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    // color: Colors.red,
                                                    child: black_border_bttn2(
                                                        "OK", 30))),
                                            Expanded(
                                                flex: 1,
                                                child: Container(
                                                  // color: Colors.black,
                                                ))
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                            ))
                      ],
                    ),
                  ))
            ],
          ))
        ],
      ),
    );
  }
}
