import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_scale/DatabaseHelper.dart';
import 'dart:convert';
import '../models/Product.dart';


class ProduceList extends StatefulWidget {
  const ProduceList({Key? key}) : super(key: key);

  @override
  State<ProduceList> createState() => _ProduceListState();
}


class _ProduceListState extends State<ProduceList> {
  late List<Product> produce_list;

  Future<void> init_produce_list() async {
    produce_list = await DatabaseHelper.instance.getProducts();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init_produce_list();
  }

  void updateState() {
    init_produce_list();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maintenance"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FractionallySizedBox(
                      widthFactor: 0.9,
                      child: FutureBuilder<List<DataRow>>(
                        future: DatabaseHelper.instance.get_data_row(),
                        // async work
                        builder: (BuildContext context,
                            AsyncSnapshot<List<DataRow>> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Text('Loading....');
                            default:
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return DataTable(
                                    dataRowHeight: 200,
                                    headingTextStyle: const TextStyle(
                                        fontSize: 20, color: Colors.black),
                                    dataTextStyle: const TextStyle(
                                        fontSize: 20, color: Colors.black),
                                    columns: [
                                      DataColumn(
                                          label: Container(
                                              width: 30, //SET width
                                              child: Text('ID'))),
                                      DataColumn(
                                          label: Container(
                                              width: 100, //SET width
                                              child: Text('Name'))),
                                      DataColumn(
                                          label: Container(
                                              width: 100, //SET width
                                              child: Text('Unit Price'))),
                                      DataColumn(
                                          label: Container(
                                              width: 150, //SET width
                                              child: Text('Produce Type'))),
                                      DataColumn(
                                          label: Container(
                                              width: 200, //SET width
                                              child: Text('Produce Image'))),
                                    ],
                                    rows: get_produce_data_row(produce_list));
                              }
                          }
                        },
                      )),
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.download),
        onPressed: () async {
          await DatabaseHelper.instance.get_latest_data();
          setState(() {
            updateState();
          });
        },
      ),
    );
  }

  List<DataRow> get_produce_data_row(data) {
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
                child: Image.memory(
                    base64Decode(utf8.decode(product.produce_image))),
              )),
            ]))
        .toList();
  }
}

class CustomListItem extends StatelessWidget {
  const CustomListItem();

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: SizedBox(
          height: 100,
          width: 50,
          child: Text("sss"),
        ));
  }
}
