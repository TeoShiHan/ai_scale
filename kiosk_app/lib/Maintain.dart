import 'package:flutter/material.dart';

// sql lite setup and usage : https://www.youtube.com/watch?v=noi6aYsP7Go

class Maintain extends StatefulWidget {
  const Maintain({Key? key}) : super(key: key);

  @override
  State<Maintain> createState() => _MaintainState();
}

class _MaintainState extends State<Maintain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
             "Maintenance"
          ),
        ),
        body:
        Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          widthFactor: 0.7,
                          child:
                            ElevatedButton(
                                onPressed: () { Navigator.pushNamed(context, "/produce_list"); },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(20)
                                ),
                                child: const Text(
                                  'View Produce',
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontFamily: 'Playfair'
                                  ),
                                ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Container(
                          child: Text("asdf"),
                          color: Colors.red,
                        ),
                      )
                    ])
            )
          ],
        )
    );
  }
}



