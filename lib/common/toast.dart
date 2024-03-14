import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> alterShowToast(String msg) async {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 40,
      backgroundColor: Colors.black45,
      textColor: Colors.white,
      fontSize: 24.0);
}