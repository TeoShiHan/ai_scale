import 'dart:convert';
import 'package:flutter/material.dart';

Image get_image_widget_from_unit8_img(dynamic img) {
  return Image.memory(base64Decode(utf8.decode(img)));
}

TextStyle play_fair(double font_size) {
  return TextStyle(fontSize: font_size, fontFamily: 'Playfair', color: Colors.black);
}

ElevatedButton black_border_bttn(Function f, String text, double font_size) {
  return ElevatedButton(
      onPressed: () {
        f();
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(
            width: 1.0,
          )),
      child: Text(text, style: play_fair(font_size)));
}

ElevatedButton black_border_bttn2( String text, double font_size) {
  return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(50),
          backgroundColor: Colors.white,
          side: const BorderSide(
            width: 1.0,
          )),
      child: Text(text, style: play_fair(font_size)));
}